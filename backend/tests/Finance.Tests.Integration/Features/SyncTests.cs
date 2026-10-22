using System.Net;
using System.Text;
using System.Text.Json;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Recurring;
using Finance.Application.Features.Sync;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Common;
using Finance.Domain.Recurring;
using Finance.Domain.Sync;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class SyncTests(ApiFactory factory)
{
    private static readonly DateOnly Today = TestApiExtensions.TodayFor();
    private static DateTime _clock = DateTime.UtcNow;

    /// <summary>Strictly increasing client timestamps, like a real device clock.</summary>
    private static DateTime Now() => _clock = _clock.AddMilliseconds(1);

    private static SyncChange Upsert(string type, Guid id, object payload, DateTime? at = null) => new()
    {
        EntityType = type,
        Id = id,
        Operation = SyncOperation.Upsert,
        Payload = JsonSerializer.SerializeToElement(payload, Json.Options),
        ClientUpdatedAt = at ?? Now(),
    };

    private static SyncChange Delete(string type, Guid id, DateTime? at = null) => new()
    {
        EntityType = type, Id = id, Operation = SyncOperation.Delete, ClientUpdatedAt = at ?? Now(),
    };

    private static Task<SyncPushResponse> PushAsync(TestUser user, params SyncChange[] changes) =>
        user.PostAsync<SyncPushResponse>("/api/v1/sync/push", new SyncPushRequest(changes), HttpStatusCode.OK);

    private static Task<SyncPullResponse> PullAsync(TestUser user, long since = 0, int limit = 1000) =>
        user.GetAsync<SyncPullResponse>($"/api/v1/sync/pull?since={since}&limit={limit}");

    private static async Task<Guid> CategoryIdAsync(TestUser user, string name) => (await user.CategoryAsync(name)).Id;

    [Fact]
    public async Task Push_applies_all_entity_types_in_dependency_order()
    {
        var user = await factory.RegisterUserAsync();
        var (account, savings, parent, child, goal, rule, budget, line, allocation, tx) =
            (UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New());

        // Deliberately children before parents.
        var response = await PushAsync(user,
            Upsert(SyncEntityTypes.Transaction, tx, new TransactionPayload
            {
                AccountId = account, Type = TransactionType.Expense, Amount = 2_450, CategoryId = child, Date = Today, Note = "Кофе",
            }),
            Upsert(SyncEntityTypes.BudgetGoalAllocation, allocation, new { budgetId = budget, savingsGoalId = goal, plannedAmount = 15_000 }),
            Upsert(SyncEntityTypes.BudgetLine, line, new { budgetId = budget, categoryId = parent, plannedAmount = 30_000, rollover = true }),
            Upsert(SyncEntityTypes.Budget, budget, new { month = "2026-10", expectedIncome = 290_000 }),
            Upsert(SyncEntityTypes.RecurringRule, rule, new RecurringRulePayload
            {
                Name = "Пополнение", AccountId = account, ToAccountId = savings, Type = TransactionType.Transfer, Amount = 10_000,
                SavingsGoalId = goal, Frequency = Frequency.Monthly, StartDate = Today.AddDays(1),
            }),
            Upsert(SyncEntityTypes.Settings, user.Id, new { baseCurrency = "BYN", timezone = "Europe/Minsk", firstDayOfMonth = 5, defaultSpendingAccountId = account, lowBalanceThreshold = 5_000 }),
            Upsert(SyncEntityTypes.SavingsGoal, goal, new { name = "Отпуск", targetAmount = 400_000, currency = "BYN", linkedAccountId = savings }),
            Upsert(SyncEntityTypes.Category, child, new { name = "Кофейни", kind = "Expense", parentId = parent }),
            Upsert(SyncEntityTypes.Category, parent, new { name = "Кафе", kind = "Expense" }),
            Upsert(SyncEntityTypes.Account, savings, new { name = "Копилка", type = "Savings", currency = "BYN" }),
            Upsert(SyncEntityTypes.Account, account, new AccountPayload { Name = "Карта", Type = AccountType.DebitCard, Currency = "BYN", InitialBalance = 10_000 }));

        response.Rejected.Should().BeEmpty();
        response.Accepted.Should().HaveCount(11).And.OnlyContain(a => a.Status == SyncAcceptStatus.Applied && a.Version > 0);
        response.Accepted.Select(a => a.EntityType).Should().Equal(
            SyncEntityTypes.Account, SyncEntityTypes.Account, SyncEntityTypes.Settings, SyncEntityTypes.Category, SyncEntityTypes.Category,
            SyncEntityTypes.SavingsGoal, SyncEntityTypes.RecurringRule, SyncEntityTypes.Budget, SyncEntityTypes.BudgetLine,
            SyncEntityTypes.BudgetGoalAllocation, SyncEntityTypes.Transaction);
        response.Accepted[3].Id.Should().Be(parent, "a parent category goes before its child");
        response.Accepted.Select(a => a.Version).Should().BeInAscendingOrder();

        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{account}")).Balance.Should().Be(7_550);
        (await user.GetAsync<Finance.Application.Features.Me.MeResponse>("/api/v1/me")).FirstDayOfMonth.Should().Be(5);
        (await user.GetAsync<Finance.Application.Features.Budgets.BudgetResponse>("/api/v1/budgets/2026-10")).Lines.Should().ContainSingle();
    }

    [Fact]
    public async Task Pull_returns_every_change_with_data_in_the_push_shape()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync("Карта", initialBalance: 1_000);
        var tx = await user.ExpenseAsync(account.Id, 300, Today, note: "Хлеб", tags: ["еда"]);

        var pull = await PullAsync(user);

        pull.HasMore.Should().BeFalse();
        pull.Changes.Select(c => c.Version).Should().BeInAscendingOrder().And.OnlyHaveUniqueItems();
        pull.NextCursor.Should().Be(pull.Changes[^1].Version);
        pull.Changes.Should().Contain(c => c.EntityType == SyncEntityTypes.Settings && c.Id == user.Id);
        pull.Changes.Count(c => c.EntityType == SyncEntityTypes.Category).Should().BeGreaterThan(10, "default categories");

        var pulledTx = pull.Changes.Single(c => c.EntityType == SyncEntityTypes.Transaction);
        pulledTx.Id.Should().Be(tx.Id);
        var data = ((JsonElement)pulledTx.Data!).Deserialize<TransactionPayload>(Json.Options)!;
        data.Should().Match<TransactionPayload>(t => t.Amount == 300 && t.Note == "Хлеб" && t.AccountId == account.Id && t.Status == TransactionStatus.Cleared);
        data.Tags.Should().Equal("еда");

        // The pulled data can be pushed back unchanged.
        var echo = await PushAsync(user, Upsert(SyncEntityTypes.Transaction, tx.Id, (JsonElement)pulledTx.Data!));
        echo.Accepted.Single().Status.Should().Be(SyncAcceptStatus.Unchanged);
        (await PullAsync(user, pull.NextCursor)).Changes.Should().BeEmpty();
    }

    [Fact]
    public async Task Pull_pages_with_the_cursor_and_includes_deletions()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync();
        var tx = await user.ExpenseAsync(account.Id, 100, Today);
        await user.Client.DeleteAsync($"/api/v1/transactions/{tx.Id}");

        var all = new List<PulledChange>();
        long cursor = 0;
        var pages = 0;
        while (true)
        {
            var page = await PullAsync(user, cursor, limit: 5);
            all.AddRange(page.Changes);
            pages++;
            if (!page.HasMore)
            {
                break;
            }

            page.Changes.Should().HaveCount(5);
            cursor = page.NextCursor;
        }

        pages.Should().BeGreaterThan(1);
        all.Select(c => (c.EntityType, c.Id)).Should().OnlyHaveUniqueItems();
        var deleted = all.Single(c => c.Id == tx.Id);
        deleted.Deleted.Should().BeTrue();
        deleted.DeletedAt.Should().NotBeNull();
        deleted.Data.Should().BeNull();

        var tail = await PullAsync(user, all[^1].Version);
        tail.Changes.Should().BeEmpty();
        tail.NextCursor.Should().Be(all[^1].Version);
        tail.HasMore.Should().BeFalse();
    }

    [Fact]
    public async Task Push_is_idempotent_by_id_and_client_timestamp()
    {
        var user = await factory.RegisterUserAsync();
        var id = UuidV7.New();
        var at = Now();
        var change = Upsert(SyncEntityTypes.Account, id, new { name = "Наличные", type = "Cash", currency = "BYN" }, at);

        var first = await PushAsync(user, change);
        var cursor = (await PullAsync(user)).NextCursor;
        var retry = await PushAsync(user, change with
        {
            // A retry of the same change is not applied again, even if the payload differs.
            Payload = JsonSerializer.SerializeToElement(new { name = "Другое", type = "Cash", currency = "BYN" }, Json.Options),
        });

        retry.Accepted.Single().Should().Be(first.Accepted.Single() with { Status = SyncAcceptStatus.Duplicate });
        (await PullAsync(user, cursor)).Changes.Should().BeEmpty();
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{id}")).Name.Should().Be("Наличные");
    }

    [Fact]
    public async Task Last_write_wins_in_arrival_order()
    {
        var user = await factory.RegisterUserAsync();
        var id = UuidV7.New();
        var older = Now();
        var newer = Now();

        var a = await PushAsync(user, Upsert(SyncEntityTypes.Account, id, new { name = "Новое имя", type = "Cash", currency = "BYN" }, newer));
        // A change made earlier on another device arrives later: it still wins.
        var b = await PushAsync(user, Upsert(SyncEntityTypes.Account, id, new { name = "Старое имя", type = "Cash", currency = "BYN" }, older));

        b.Accepted.Single().Version.Should().BeGreaterThan(a.Accepted.Single().Version!.Value);
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{id}")).Name.Should().Be("Старое имя");
    }

    [Fact]
    public async Task Deletion_wins_over_later_changes()
    {
        var user = await factory.RegisterUserAsync();
        var id = UuidV7.New();
        await PushAsync(user, Upsert(SyncEntityTypes.Account, id, new { name = "Карта", type = "DebitCard", currency = "BYN" }));

        var deleted = await PushAsync(user, Delete(SyncEntityTypes.Account, id));
        var update = await PushAsync(user, Upsert(SyncEntityTypes.Account, id, new { name = "Ожила", type = "DebitCard", currency = "BYN" }));
        var again = await PushAsync(user, Delete(SyncEntityTypes.Account, id));
        var unknown = await PushAsync(user, Delete(SyncEntityTypes.Account, UuidV7.New()));

        deleted.Accepted.Single().Status.Should().Be(SyncAcceptStatus.Applied);
        update.Rejected.Single().Code.Should().Be("entity_deleted");
        again.Accepted.Single().Should().Match<AcceptedChange>(c => c.Status == SyncAcceptStatus.AlreadyDeleted && c.Version == deleted.Accepted.Single().Version);
        unknown.Accepted.Single().Should().Match<AcceptedChange>(c => c.Status == SyncAcceptStatus.Ignored && c.Version == null);
    }

    [Fact]
    public async Task Deletes_run_children_first()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync();
        var tx = await user.ExpenseAsync(account.Id, 100, Today);
        var parent = UuidV7.New();
        var child = UuidV7.New();
        await PushAsync(user,
            Upsert(SyncEntityTypes.Category, parent, new { name = "Хобби", kind = "Expense" }),
            Upsert(SyncEntityTypes.Category, child, new { name = "Фото", kind = "Expense", parentId = parent }));

        var response = await PushAsync(user,
            Delete(SyncEntityTypes.Account, account.Id),
            Delete(SyncEntityTypes.Category, parent),
            Delete(SyncEntityTypes.Transaction, tx.Id),
            Delete(SyncEntityTypes.Category, child));

        response.Rejected.Should().BeEmpty();
        response.Accepted.Select(a => a.Id).Should().Equal(tx.Id, child, parent, account.Id);
    }

    [Fact]
    public async Task One_rejected_change_does_not_affect_the_others()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync();
        var food = await CategoryIdAsync(user, "Продукты");
        var salary = (await user.CategoryAsync("Зарплата", Finance.Domain.Categories.CategoryKind.Income)).Id;
        var (good, invalid, wrongKind, orphan) = (UuidV7.New(), UuidV7.New(), UuidV7.New(), UuidV7.New());

        var response = await PushAsync(user,
            Upsert(SyncEntityTypes.Transaction, invalid, new { accountId = account.Id, type = "Expense", amount = 0, categoryId = food, date = Today }),
            Upsert(SyncEntityTypes.Transaction, good, new { accountId = account.Id, type = "Expense", amount = 500, categoryId = food, date = Today }),
            Upsert(SyncEntityTypes.Transaction, wrongKind, new { accountId = account.Id, type = "Expense", amount = 1, categoryId = salary, date = Today }),
            Upsert(SyncEntityTypes.Transaction, orphan, new { accountId = UuidV7.New(), type = "Expense", amount = 1, categoryId = food, date = Today }),
            Upsert(SyncEntityTypes.Transaction, UuidV7.New(), new { accountId = account.Id, type = "Expense", amount = "lots" }),
            Delete(SyncEntityTypes.Account, account.Id));

        response.Accepted.Should().ContainSingle().Which.Id.Should().Be(good);
        var reasons = response.Rejected.ToDictionary(r => r.Id, r => r.Code);
        reasons[invalid].Should().Be("validation_failed");
        response.Rejected.Single(r => r.Id == invalid).Errors!.Should().ContainKey("amount");
        reasons[wrongKind].Should().Be("category_kind_mismatch");
        reasons[orphan].Should().Be("account_not_found");
        reasons.Values.Should().Contain("invalid_payload");
        reasons[account.Id].Should().Be("account_has_transactions");
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{account.Id}")).Balance.Should().Be(-500);
    }

    [Fact]
    public async Task Envelope_problems_are_rejected()
    {
        var user = await factory.RegisterUserAsync();

        var response = await PushAsync(user,
            Upsert("wallet", UuidV7.New(), new { }),
            new SyncChange { EntityType = SyncEntityTypes.Account, Id = UuidV7.New(), Operation = SyncOperation.Upsert, ClientUpdatedAt = Now() },
            Upsert(SyncEntityTypes.Account, UuidV7.New(), new { name = "x", type = "Cash", currency = "BYN" }, at: default(DateTime)),
            Delete(SyncEntityTypes.Settings, user.Id),
            Upsert(SyncEntityTypes.Settings, UuidV7.New(), new { baseCurrency = "BYN", timezone = "Europe/Minsk", firstDayOfMonth = 1 }),
            Upsert(SyncEntityTypes.Account, Guid.NewGuid(), new { name = "v4", type = "Cash", currency = "BYN" }));

        response.Accepted.Should().BeEmpty();
        response.Rejected.Select(r => r.Code).Should().BeEquivalentTo(
            ["unknown_entity_type", "invalid_payload", "client_updated_at_required", "operation_not_allowed", "not_found", "invalid_id"]);

        await (await user.PostAsync("/api/v1/sync/push", new SyncPushRequest([]))).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.Client.GetAsync("/api/v1/sync/pull?limit=5000")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
    }

    [Fact]
    public async Task Other_users_entities_cannot_be_touched()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var account = await alice.CreateAccountAsync("Alice");

        var response = await PushAsync(bob,
            Upsert(SyncEntityTypes.Account, account.Id, new { name = "Bob", type = "Cash", currency = "BYN" }),
            Delete(SyncEntityTypes.Account, account.Id));

        response.Rejected.Single().Code.Should().Be("id_conflict");
        response.Accepted.Single().Status.Should().Be(SyncAcceptStatus.Ignored);
        (await alice.GetAsync<AccountResponse>($"/api/v1/accounts/{account.Id}")).Name.Should().Be("Alice");
        (await PullAsync(bob)).Changes.Should().NotContain(c => c.Id == account.Id);
    }

    [Fact]
    public async Task Budget_parts_keep_their_constraints()
    {
        var user = await factory.RegisterUserAsync();
        var food = await CategoryIdAsync(user, "Продукты");
        var salary = (await user.CategoryAsync("Зарплата", Finance.Domain.Categories.CategoryKind.Income)).Id;
        var budget = UuidV7.New();
        await PushAsync(user,
            Upsert(SyncEntityTypes.Budget, budget, new { month = "2026-11", expectedIncome = 100 }),
            Upsert(SyncEntityTypes.BudgetLine, UuidV7.New(), new { budgetId = budget, categoryId = food, plannedAmount = 10 }));

        var response = await PushAsync(user,
            Upsert(SyncEntityTypes.Budget, UuidV7.New(), new { month = "2026-11", expectedIncome = 1 }),
            Upsert(SyncEntityTypes.Budget, budget, new { month = "2026-12", expectedIncome = 1 }),
            Upsert(SyncEntityTypes.BudgetLine, UuidV7.New(), new { budgetId = budget, categoryId = food, plannedAmount = 20 }),
            Upsert(SyncEntityTypes.BudgetLine, UuidV7.New(), new { budgetId = budget, categoryId = salary, plannedAmount = 20 }),
            Upsert(SyncEntityTypes.BudgetLine, UuidV7.New(), new { budgetId = UuidV7.New(), categoryId = food, plannedAmount = 20 }));

        response.Rejected.Select(r => r.Code).Should().BeEquivalentTo(
            ["budget_exists", "budget_month_locked", "duplicate_category", "category_kind_mismatch", "budget_not_found"]);

        var deleted = await PushAsync(user, Delete(SyncEntityTypes.Budget, budget));
        deleted.Accepted.Single().Status.Should().Be(SyncAcceptStatus.Applied);
        var tombstones = (await PullAsync(user)).Changes.Where(c => c.EntityType is SyncEntityTypes.Budget or SyncEntityTypes.BudgetLine).ToList();
        tombstones.Should().HaveCount(2).And.OnlyContain(c => c.Deleted, "deleting a budget deletes its lines");
    }

    [Fact]
    public async Task Offline_confirmation_of_a_materialized_occurrence_merges_by_its_deterministic_id()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync(initialBalance: 10_000);
        var phone = await CategoryIdAsync(user, "Связь и интернет");
        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "Связь", AccountId = card.Id, Type = TransactionType.Expense, Amount = 1_850, CategoryId = phone,
            Frequency = Frequency.Monthly, StartDate = Today,
        });
        var occurrenceId = RecurringRule.OccurrenceTransactionId(rule.Id, Today);

        // Two devices confirm the same occurrence at the same time.
        var confirm = new TransactionPayload
        {
            AccountId = card.Id, Type = TransactionType.Expense, Amount = 1_999, CategoryId = phone, Date = Today,
            Status = TransactionStatus.Cleared, RecurringRuleId = rule.Id, RecurrenceDate = Today,
        };
        var results = await Task.WhenAll(
            PushAsync(user, Upsert(SyncEntityTypes.Transaction, occurrenceId, confirm)),
            PushAsync(user, Upsert(SyncEntityTypes.Transaction, occurrenceId, confirm)));

        results.SelectMany(r => r.Rejected).Should().BeEmpty();
        results.SelectMany(r => r.Accepted).Select(a => a.Status).Should().BeEquivalentTo([SyncAcceptStatus.Applied, SyncAcceptStatus.Unchanged]);
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(10_000 - 1_999);
    }

    [Fact]
    public async Task Settings_changes_are_synced_both_ways()
    {
        var user = await factory.RegisterUserAsync();
        var cursor = (await PullAsync(user)).NextCursor;

        await user.Client.PatchAsync("/api/v1/me", new StringContent("""{"firstDayOfMonth": 15}""", Encoding.UTF8, "application/json"));
        var settings = (await PullAsync(user, cursor)).Changes.Should().ContainSingle().Subject;
        settings.EntityType.Should().Be(SyncEntityTypes.Settings);
        ((JsonElement)settings.Data!).GetProperty("firstDayOfMonth").GetInt32().Should().Be(15);

        var pushed = await PushAsync(user, Upsert(SyncEntityTypes.Settings, user.Id,
            new { baseCurrency = "usd", timezone = "Europe/Warsaw", firstDayOfMonth = 10, lowBalanceThreshold = 100 }));
        pushed.Accepted.Single().Version.Should().BeGreaterThan(settings.Version);
        var me = await user.GetAsync<Finance.Application.Features.Me.MeResponse>("/api/v1/me");
        me.Should().Match<Finance.Application.Features.Me.MeResponse>(m =>
            m.BaseCurrency == "USD" && m.Timezone == "Europe/Warsaw" && m.FirstDayOfMonth == 10 && m.LowBalanceThreshold == 100);

        var invalid = await PushAsync(user, Upsert(SyncEntityTypes.Settings, user.Id, new { baseCurrency = "BYN", timezone = "Nowhere", firstDayOfMonth = 40 }));
        invalid.Rejected.Single().Code.Should().Be("invalid_timezone");
    }

    [Fact]
    public async Task Pulling_while_writes_happen_never_skips_a_change()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync(initialBalance: 1_000_000);
        var food = await CategoryIdAsync(user, "Продукты");
        var created = new System.Collections.Concurrent.ConcurrentBag<Guid>();

        // Parallel writers: REST and sync push, several requests in flight at once.
        var writers = Enumerable.Range(0, 4).Select(w => Task.Run(async () =>
        {
            for (var i = 0; i < 10; i++)
            {
                var id = UuidV7.New();
                if (i % 2 == 0)
                {
                    await user.PostAsync<TransactionResponse>("/api/v1/transactions", new CreateTransactionRequest
                    {
                        Id = id, AccountId = account.Id, Type = TransactionType.Expense, Amount = 1 + i, CategoryId = food, Date = Today,
                    });
                }
                else
                {
                    var r = await PushAsync(user, Upsert(SyncEntityTypes.Transaction, id,
                        new { accountId = account.Id, type = "Expense", amount = 1 + i, categoryId = food, date = Today }));
                    r.Rejected.Should().BeEmpty();
                }

                created.Add(id);
            }
        })).ToArray();

        var seen = new HashSet<Guid>();
        long cursor = 0;
        var done = Task.WhenAll(writers);
        while (!done.IsCompleted)
        {
            var page = await PullAsync(user, cursor, limit: 7);
            page.Changes.All(c => c.Version > cursor).Should().BeTrue();
            seen.UnionWith(page.Changes.Select(c => c.Id));
            cursor = page.NextCursor;
        }

        await done;
        SyncPullResponse last;
        do
        {
            last = await PullAsync(user, cursor, limit: 7);
            seen.UnionWith(last.Changes.Select(c => c.Id));
            cursor = last.NextCursor;
        }
        while (last.HasMore);

        created.Should().HaveCount(40);
        seen.Should().Contain(created);
    }
}
