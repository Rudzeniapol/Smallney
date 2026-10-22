using System.Net;
using Finance.Application.Common;
using Finance.Application.Features.Transactions;
using Finance.Domain.Common;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class TransactionsTests(ApiFactory factory)
{
    [Fact]
    public async Task Create_get_update_delete()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var created = await user.ExpenseAsync(card.Id, 2_450, new DateOnly(2026, 10, 22), note: " Евроопт ", tags: ["еда", "Еда", " дом "]);

        created.Note.Should().Be("Евроопт");
        created.Tags.Should().Equal("еда", "дом");
        created.Status.Should().Be(TransactionStatus.Cleared);

        var cafe = await user.CategoryAsync("Кафе и рестораны");
        var updated = await user.PutAsync<TransactionResponse>($"/api/v1/transactions/{created.Id}", new TransactionPayload
        {
            AccountId = card.Id, Type = TransactionType.Expense, Amount = 3_000, CategoryId = cafe.Id, Date = new DateOnly(2026, 10, 21),
        });
        updated.Amount.Should().Be(3_000);
        updated.CategoryId.Should().Be(cafe.Id);
        updated.Version.Should().BeGreaterThan(created.Version);

        (await user.Client.DeleteAsync($"/api/v1/transactions/{created.Id}")).StatusCode.Should().Be(HttpStatusCode.NoContent);
        await (await user.Client.GetAsync($"/api/v1/transactions/{created.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        await (await user.Client.DeleteAsync($"/api/v1/transactions/{created.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Business_rules_are_enforced()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var usd = await user.CreateAccountAsync("USD", "USD");
        var salary = await user.CategoryAsync("Зарплата", Finance.Domain.Categories.CategoryKind.Income);
        var day = new DateOnly(2026, 10, 1);

        var wrongKind = await user.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = card.Id, Type = TransactionType.Expense, Amount = 100, CategoryId = salary.Id, Date = day,
        });
        await wrongKind.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_kind_mismatch");

        var crossCurrencyWithoutToAmount = await user.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = card.Id, ToAccountId = usd.Id, Type = TransactionType.Transfer, Amount = 32_000, Date = day,
        });
        await crossCurrencyWithoutToAmount.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "transfer_to_amount_required");

        var unknownAccount = await user.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = UuidV7.New(), Type = TransactionType.Income, Amount = 100, CategoryId = salary.Id, Date = day,
        });
        await unknownAccount.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "account_not_found");

        var invalid = await user.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = card.Id, Type = TransactionType.Expense, Amount = -5, Date = day,
        });
        await invalid.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        var transfer = await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card.Id, ToAccountId = usd.Id, Type = TransactionType.Transfer, Amount = 32_000, ToAmount = 10_000, Date = day,
        });
        transfer.ToAmount.Should().Be(10_000);
        transfer.CategoryId.Should().BeNull();
    }

    [Fact]
    public async Task List_filters()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта");
        var cash = await user.CreateAccountAsync("Наличные");
        var transport = await user.CategoryAsync("Транспорт");

        var food = await user.ExpenseAsync(card.Id, 1_000, new DateOnly(2026, 9, 30), "Продукты", note: "Гиппо, молоко", tags: ["семья"]);
        var taxi = await user.ExpenseAsync(card.Id, 900, new DateOnly(2026, 10, 2), "Такси", note: "Такси домой");
        var bus = await user.ExpenseAsync(cash.Id, 80, new DateOnly(2026, 10, 3), "Общественный транспорт", tags: ["Семья"]);
        var salary = await user.IncomeAsync(card.Id, 300_000, new DateOnly(2026, 10, 5));
        var planned = await user.ExpenseAsync(card.Id, 5_000, new DateOnly(2026, 10, 10), status: TransactionStatus.Planned);
        var transfer = await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card.Id, ToAccountId = cash.Id, Type = TransactionType.Transfer, Amount = 10_000, Date = new DateOnly(2026, 10, 4),
        });

        async Task<IEnumerable<Guid>> Ids(string query) =>
            (await user.GetAsync<CursorPage<TransactionResponse>>($"/api/v1/transactions?{query}")).Items.Select(t => t.Id);

        (await Ids("")).Should().Equal(planned.Id, salary.Id, transfer.Id, bus.Id, taxi.Id, food.Id);
        (await Ids("from=2026-10-01&to=2026-10-04")).Should().BeEquivalentTo([taxi.Id, bus.Id, transfer.Id]);
        (await Ids($"accountId={cash.Id}")).Should().BeEquivalentTo([bus.Id, transfer.Id], "transfers into the account are included");
        (await Ids($"categoryId={transport.Id}")).Should().BeEquivalentTo([taxi.Id, bus.Id], "subcategories are included");
        (await Ids("type=Income")).Should().Equal(salary.Id);
        (await Ids("status=Planned")).Should().Equal(planned.Id);
        (await Ids("tag=Семья")).Should().Equal(bus.Id, food.Id);
        (await Ids($"search={Uri.EscapeDataString("МОЛОКО")}")).Should().Equal(food.Id);
        (await Ids($"search={Uri.EscapeDataString("100%_")}")).Should().BeEmpty();
    }

    [Fact]
    public async Task Cursor_pagination_walks_all_pages_without_duplicates()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var created = new List<Guid>();
        for (var i = 0; i < 7; i++)
        {
            // Several transactions share a date, so the id tiebreaker matters.
            created.Add((await user.ExpenseAsync(card.Id, 100 + i, new DateOnly(2026, 10, 1 + (i / 3)))).Id);
        }

        var seen = new List<Guid>();
        string? cursor = null;
        var pages = 0;
        do
        {
            var url = "/api/v1/transactions?limit=3" + (cursor is null ? string.Empty : $"&cursor={cursor}");
            var page = await user.GetAsync<CursorPage<TransactionResponse>>(url);
            seen.AddRange(page.Items.Select(t => t.Id));
            page.HasMore.Should().Be(page.NextCursor is not null);
            cursor = page.NextCursor;
            pages++;
        }
        while (cursor is not null);

        pages.Should().Be(3);
        seen.Should().OnlyHaveUniqueItems().And.BeEquivalentTo(created);
    }

    [Fact]
    public async Task Bad_cursor_and_limit_are_validation_errors()
    {
        var user = await factory.RegisterUserAsync();

        await (await user.Client.GetAsync("/api/v1/transactions?cursor=nope")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.Client.GetAsync("/api/v1/transactions?limit=1000")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
    }
}
