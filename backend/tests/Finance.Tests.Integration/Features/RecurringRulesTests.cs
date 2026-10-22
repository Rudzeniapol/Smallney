using System.Net;
using Finance.Application.Common;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Recurring;
using Finance.Application.Features.Transactions;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using Finance.Infrastructure.Persistence;
using Finance.Tests.Integration.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Tests.Integration.Features;

public class RecurringRulesTests(ApiFactory factory)
{
    private static readonly DateOnly Today = TestApiExtensions.TodayFor();

    private static async Task<CreateRecurringRuleRequest> ExpenseRuleAsync(TestUser user, Guid accountId, DateOnly start,
        Frequency frequency = Frequency.Monthly, long amount = 1_850) => new()
    {
        Name = "Мобильная связь",
        AccountId = accountId,
        Type = TransactionType.Expense,
        Amount = amount,
        CategoryId = (await user.CategoryAsync("Связь и интернет")).Id,
        Frequency = frequency,
        StartDate = start,
    };

    private static async Task<List<TransactionResponse>> TransactionsAsync(TestUser user, string query = "") =>
        (await user.GetAsync<CursorPage<TransactionResponse>>($"/api/v1/transactions?limit=200{query}")).Items.ToList();

    [Fact]
    public async Task Crud_and_next_occurrence()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var request = await ExpenseRuleAsync(user, card.Id, Today.AddDays(1));

        var created = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", request);
        created.NextOccurrence.Should().Be(Today.AddDays(1));
        created.Interval.Should().Be(1);

        var updated = await user.PutAsync<RecurringRuleResponse>($"/api/v1/recurring-rules/{created.Id}",
            request with { Name = "Связь", Amount = 2_000, IsActive = false });
        updated.Name.Should().Be("Связь");
        updated.NextOccurrence.Should().BeNull("a paused rule has no next occurrence");

        (await user.GetAsync<List<RecurringRuleResponse>>("/api/v1/recurring-rules")).Should().BeEmpty();
        (await user.GetAsync<List<RecurringRuleResponse>>("/api/v1/recurring-rules?includeInactive=true")).Should().ContainSingle();

        (await user.Client.DeleteAsync($"/api/v1/recurring-rules/{created.Id}")).StatusCode.Should().Be(HttpStatusCode.NoContent);
        await (await user.Client.GetAsync($"/api/v1/recurring-rules/{created.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Schedule_fields_are_validated()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var request = await ExpenseRuleAsync(user, card.Id, Today);

        var weekdayOnMonthly = await user.PostAsync("/api/v1/recurring-rules", request with { DayOfWeek = DayOfWeek.Monday });
        await weekdayOnMonthly.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        var badEnd = await user.PostAsync("/api/v1/recurring-rules", request with { EndDate = Today.AddDays(-1) });
        await badEnd.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        var noName = await user.PostAsync("/api/v1/recurring-rules", request with { Name = " " });
        await noName.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        var wrongCategory = await user.PostAsync("/api/v1/recurring-rules",
            request with { CategoryId = (await user.CategoryAsync("Зарплата", Finance.Domain.Categories.CategoryKind.Income)).Id });
        await wrongCategory.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_kind_mismatch");
    }

    [Fact]
    public async Task Occurrence_due_today_becomes_a_planned_transaction_immediately()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync(initialBalance: 10_000);

        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", await ExpenseRuleAsync(user, card.Id, Today));

        var planned = (await TransactionsAsync(user, "&status=Planned")).Should().ContainSingle().Subject;
        planned.Id.Should().Be(RecurringRule.OccurrenceTransactionId(rule.Id, Today));
        planned.RecurringRuleId.Should().Be(rule.Id);
        planned.RecurrenceDate.Should().Be(Today);
        planned.Note.Should().Be("Мобильная связь");
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(10_000, "planned does not move the balance");
    }

    [Fact]
    public async Task Confirm_with_a_corrected_amount_clears_the_transaction()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync(initialBalance: 10_000);
        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", await ExpenseRuleAsync(user, card.Id, Today));
        var id = RecurringRule.OccurrenceTransactionId(rule.Id, Today);

        var confirmed = await user.PostAsync<TransactionResponse>($"/api/v1/transactions/{id}/confirm",
            new ConfirmTransactionRequest { Amount = 1_999 }, HttpStatusCode.OK);

        confirmed.Status.Should().Be(TransactionStatus.Cleared);
        confirmed.Amount.Should().Be(1_999);
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(8_001);

        var again = await user.PostAsync($"/api/v1/transactions/{id}/confirm", new ConfirmTransactionRequest());
        await again.ShouldBeProblemAsync(HttpStatusCode.Conflict, "transaction_not_planned");
    }

    [Fact]
    public async Task Skip_hides_the_occurrence_and_can_be_undone()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", await ExpenseRuleAsync(user, card.Id, Today));
        var id = RecurringRule.OccurrenceTransactionId(rule.Id, Today);

        var skipped = await user.PostAsync<TransactionResponse>($"/api/v1/transactions/{id}/skip", new { }, HttpStatusCode.OK);
        skipped.Status.Should().Be(TransactionStatus.Skipped);
        (await TransactionsAsync(user)).Should().BeEmpty("skipped transactions are not listed by default");
        (await TransactionsAsync(user, "&status=Skipped")).Should().ContainSingle();

        // Running the materializer again does not bring it back.
        await factory.InJobScopeAsync(sp => sp.GetRequiredService<RecurringMaterializer>().MaterializeForUserAsync(user.Id, default));
        (await TransactionsAsync(user, "&status=Skipped")).Should().ContainSingle();
        (await TransactionsAsync(user, "&status=Planned")).Should().BeEmpty();

        var undone = await user.PutAsync<TransactionResponse>($"/api/v1/transactions/{id}", new TransactionPayload
        {
            AccountId = skipped.AccountId, Type = skipped.Type, Amount = skipped.Amount, CategoryId = skipped.CategoryId,
            Date = skipped.Date, Note = skipped.Note, Status = TransactionStatus.Planned,
            RecurringRuleId = skipped.RecurringRuleId, RecurrenceDate = skipped.RecurrenceDate,
        });
        undone.Status.Should().Be(TransactionStatus.Planned);

        await (await user.PostAsync($"/api/v1/transactions/{id}/skip", new { })).EnsureStatusAsync(HttpStatusCode.OK);
        await (await user.PostAsync($"/api/v1/transactions/{id}/skip", new { })).ShouldBeProblemAsync(HttpStatusCode.Conflict, "transaction_not_planned");
    }

    [Fact]
    public async Task Past_start_date_does_not_flood_but_missed_days_are_caught_up()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();

        // Daily rule that "started" a month ago but was created now: only today's occurrence appears.
        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules",
            await ExpenseRuleAsync(user, card.Id, Today.AddDays(-30), Frequency.Daily, 300));
        (await TransactionsAsync(user, "&status=Planned")).Should().ContainSingle();

        // Pretend the rule was created 3 days ago and the job was down since then: the 3 missed days are added.
        await factory.InJobScopeAsync(async sp =>
        {
            var db = sp.GetRequiredService<AppDbContext>();
            return await db.RecurringRules.IgnoreQueryFilters().Where(r => r.Id == rule.Id)
                .ExecuteUpdateAsync(u => u.SetProperty(r => r.CreatedAt, DateTime.UtcNow.AddDays(-3)));
        });
        var created = await factory.InJobScopeAsync(sp => sp.GetRequiredService<RecurringMaterializer>().MaterializeAllAsync(default));

        created.Should().BeGreaterThanOrEqualTo(3);
        var planned = await TransactionsAsync(user, "&status=Planned");
        planned.Select(t => t.Date).Should().BeEquivalentTo([Today.AddDays(-3), Today.AddDays(-2), Today.AddDays(-1), Today]);

        // Idempotent.
        await factory.InJobScopeAsync(sp => sp.GetRequiredService<RecurringMaterializer>().MaterializeForUserAsync(user.Id, default));
        (await TransactionsAsync(user, "&status=Planned")).Should().HaveCount(4);
    }

    [Fact]
    public async Task Job_materializes_each_user_only_their_own_rules()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var aliceCard = await alice.CreateAccountAsync();
        var bobCard = await bob.CreateAccountAsync();
        var aliceRule = await alice.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules",
            await ExpenseRuleAsync(alice, aliceCard.Id, Today.AddDays(1), Frequency.Daily));
        await bob.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", await ExpenseRuleAsync(bob, bobCard.Id, Today));

        await factory.InJobScopeAsync(sp => sp.GetRequiredService<RecurringMaterializer>().MaterializeAllAsync(default));

        (await TransactionsAsync(alice)).Should().BeEmpty("alice's rule starts tomorrow");
        var bobs = await TransactionsAsync(bob);
        bobs.Should().ContainSingle().Which.AccountId.Should().Be(bobCard.Id);
        aliceRule.Should().NotBeNull();
    }

    [Fact]
    public async Task Occurrences_merge_materialized_and_upcoming()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules",
            await ExpenseRuleAsync(user, card.Id, Today, Frequency.Weekly));

        var occurrences = await user.GetAsync<List<OccurrenceResponse>>(
            $"/api/v1/recurring-rules/occurrences?from={Today:yyyy-MM-dd}&to={Today.AddDays(14):yyyy-MM-dd}");

        occurrences.Select(o => o.Date).Should().Equal(Today, Today.AddDays(7), Today.AddDays(14));
        occurrences[0].State.Should().Be(OccurrenceState.Planned);
        occurrences.Skip(1).Should().OnlyContain(o => o.State == OccurrenceState.Upcoming && o.RuleId == rule.Id);
        occurrences[1].TransactionId.Should().Be(RecurringRule.OccurrenceTransactionId(rule.Id, Today.AddDays(7)));

        var single = await user.GetAsync<List<OccurrenceResponse>>(
            $"/api/v1/recurring-rules/{rule.Id}/occurrences?from={Today:yyyy-MM-dd}&to={Today.AddDays(7):yyyy-MM-dd}");
        single.Should().HaveCount(2);

        var tooLong = await user.Client.GetAsync($"/api/v1/recurring-rules/occurrences?from=2026-01-01&to=2030-01-01");
        await tooLong.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
    }

    [Fact]
    public async Task Deleting_a_rule_removes_its_planned_but_keeps_cleared_transactions()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var daily = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules",
            await ExpenseRuleAsync(user, card.Id, Today.AddDays(-30), Frequency.Daily));
        await factory.InJobScopeAsync(async sp =>
            await sp.GetRequiredService<AppDbContext>().RecurringRules.IgnoreQueryFilters().Where(r => r.Id == daily.Id)
                .ExecuteUpdateAsync(u => u.SetProperty(r => r.CreatedAt, DateTime.UtcNow.AddDays(-1))));
        await factory.InJobScopeAsync(sp => sp.GetRequiredService<RecurringMaterializer>().MaterializeForUserAsync(user.Id, default));
        var yesterday = RecurringRule.OccurrenceTransactionId(daily.Id, Today.AddDays(-1));
        await user.PostAsync<TransactionResponse>($"/api/v1/transactions/{yesterday}/confirm", new { }, HttpStatusCode.OK);

        await user.Client.DeleteAsync($"/api/v1/recurring-rules/{daily.Id}");

        var remaining = await TransactionsAsync(user);
        remaining.Should().ContainSingle().Which.Id.Should().Be(yesterday);
    }

    [Fact]
    public async Task Rules_block_deleting_their_account_and_category()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var request = await ExpenseRuleAsync(user, card.Id, Today.AddDays(5));
        await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", request);

        await (await user.Client.DeleteAsync($"/api/v1/accounts/{card.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "account_has_recurring_rules");
        await (await user.Client.DeleteAsync($"/api/v1/categories/{request.CategoryId}"))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "category_has_recurring_rules");
    }

    [Fact]
    public async Task Other_users_rules_are_invisible()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var card = await alice.CreateAccountAsync();
        var rule = await alice.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", await ExpenseRuleAsync(alice, card.Id, Today.AddDays(3)));

        await (await bob.Client.GetAsync($"/api/v1/recurring-rules/{rule.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        (await bob.GetAsync<List<RecurringRuleResponse>>("/api/v1/recurring-rules?includeInactive=true")).Should().BeEmpty();
        await (await bob.Client.DeleteAsync($"/api/v1/recurring-rules/{rule.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");

        var bobCard = await bob.CreateAccountAsync();
        var bobCategory = await bob.CategoryAsync("Продукты");
        var claimsAliceRule = await bob.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = bobCard.Id, Type = TransactionType.Expense, Amount = 1, CategoryId = bobCategory.Id, Date = Today,
            RecurringRuleId = rule.Id, RecurrenceDate = Today,
        });
        await claimsAliceRule.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "recurring_rule_not_found");
    }
}
