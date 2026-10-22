using System.Net;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Me;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Common;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class AccountsTests(ApiFactory factory)
{
    private static readonly DateOnly Day = new(2026, 10, 1);

    [Fact]
    public async Task Create_get_update_list_and_delete()
    {
        var user = await factory.RegisterUserAsync();
        var id = UuidV7.New();

        var created = await user.PostAsync<AccountResponse>("/api/v1/accounts", new CreateAccountRequest
        {
            Id = id,
            Name = "  Вклад  ",
            Type = AccountType.Deposit,
            Currency = "BYN",
            InitialBalance = 500_000,
            InterestRatePercent = 11.5m,
            CapitalizationPeriod = CapitalizationPeriod.Monthly,
            OpenDate = new DateOnly(2026, 1, 15),
            MaturityDate = new DateOnly(2027, 1, 15),
            Color = "#85BB65",
            Icon = "bank",
        });

        created.Id.Should().Be(id);
        created.Name.Should().Be("Вклад");
        created.Balance.Should().Be(500_000);
        created.Version.Should().BePositive();

        var updated = await user.PutAsync<AccountResponse>($"/api/v1/accounts/{id}", new AccountPayload
        {
            Name = "Вклад 12%",
            Type = AccountType.Deposit,
            Currency = "BYN",
            InitialBalance = 500_000,
            InterestRatePercent = 12m,
            CapitalizationPeriod = CapitalizationPeriod.Quarterly,
            OpenDate = new DateOnly(2026, 1, 15),
            IsArchived = true,
        });
        updated.Name.Should().Be("Вклад 12%");
        updated.InterestRatePercent.Should().Be(12m);
        updated.Version.Should().BeGreaterThan(created.Version);

        (await user.GetAsync<List<AccountResponse>>("/api/v1/accounts")).Should().NotContain(a => a.Id == id, "archived accounts are hidden");
        (await user.GetAsync<List<AccountResponse>>("/api/v1/accounts?includeArchived=true")).Should().Contain(a => a.Id == id);

        (await user.Client.DeleteAsync($"/api/v1/accounts/{id}")).StatusCode.Should().Be(HttpStatusCode.NoContent);
        await (await user.Client.GetAsync($"/api/v1/accounts/{id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        (await user.GetAsync<List<AccountResponse>>("/api/v1/accounts?includeArchived=true")).Should().NotContain(a => a.Id == id);
    }

    [Fact]
    public async Task Id_is_generated_when_omitted_and_must_be_v7_when_given()
    {
        var user = await factory.RegisterUserAsync();

        var generated = await user.PostAsync<AccountResponse>("/api/v1/accounts",
            new CreateAccountRequest { Name = "Наличные", Type = AccountType.Cash, Currency = "BYN" });
        UuidV7.IsValid(generated.Id).Should().BeTrue();

        var v4 = await user.PostAsync("/api/v1/accounts",
            new CreateAccountRequest { Id = Guid.NewGuid(), Name = "x", Type = AccountType.Cash, Currency = "BYN" });
        await v4.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        var duplicate = await user.PostAsync("/api/v1/accounts",
            new CreateAccountRequest { Id = generated.Id, Name = "x", Type = AccountType.Cash, Currency = "BYN" });
        await duplicate.ShouldBeProblemAsync(HttpStatusCode.Conflict, "id_conflict");
    }

    [Fact]
    public async Task Type_specific_fields_are_validated()
    {
        var user = await factory.RegisterUserAsync();

        var response = await user.PostAsync("/api/v1/accounts", new CreateAccountRequest
        {
            Name = "Карта",
            Type = AccountType.DebitCard,
            Currency = "BYN",
            CreditLimit = 100_000,
            InterestRatePercent = 5,
        });

        var problem = await response.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        problem.Extensions["errors"]!.ToString().Should().Contain("creditLimit").And.Contain("interestRatePercent");
    }

    [Fact]
    public async Task Balance_is_initial_plus_cleared_transactions()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 100_000);
        var cash = await user.CreateAccountAsync("Наличные", initialBalance: 5_000);

        await user.IncomeAsync(card.Id, 250_000, Day);
        await user.ExpenseAsync(card.Id, 2_450, Day);
        var deleted = await user.ExpenseAsync(card.Id, 99_999, Day);
        await user.ExpenseAsync(card.Id, 30_000, Day, status: TransactionStatus.Planned);
        await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card.Id,
            ToAccountId = cash.Id,
            Type = TransactionType.Transfer,
            Amount = 20_000,
            Date = Day,
        });
        await user.Client.DeleteAsync($"/api/v1/transactions/{deleted.Id}");

        var accounts = (await user.GetAsync<List<AccountResponse>>("/api/v1/accounts")).ToDictionary(a => a.Id);
        accounts[card.Id].Balance.Should().Be(100_000 + 250_000 - 2_450 - 20_000);
        accounts[cash.Id].Balance.Should().Be(5_000 + 20_000);
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(accounts[card.Id].Balance);
    }

    [Fact]
    public async Task Confirming_a_planned_transaction_changes_the_balance()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync(initialBalance: 10_000);
        var planned = await user.ExpenseAsync(card.Id, 3_000, Day, status: TransactionStatus.Planned);
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(10_000);

        await user.PutAsync<TransactionResponse>($"/api/v1/transactions/{planned.Id}", new TransactionPayload
        {
            AccountId = card.Id,
            Type = TransactionType.Expense,
            Amount = 3_000,
            CategoryId = planned.CategoryId,
            Date = Day,
            Status = TransactionStatus.Cleared,
        });

        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(7_000);
    }

    [Fact]
    public async Task Account_with_transactions_cannot_be_deleted_or_change_currency()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        await user.ExpenseAsync(card.Id, 100, Day);

        await (await user.Client.DeleteAsync($"/api/v1/accounts/{card.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "account_has_transactions");

        var response = await user.PutAsync($"/api/v1/accounts/{card.Id}",
            new AccountPayload { Name = card.Name, Type = card.Type, Currency = "USD" });
        await response.ShouldBeProblemAsync(HttpStatusCode.Conflict, "account_currency_locked");
    }

    [Fact]
    public async Task Deleting_the_default_spending_account_clears_the_setting()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        await user.Client.PatchAsync("/api/v1/me", new StringContent(
            $$"""{"defaultSpendingAccountId": "{{card.Id}}"}""", System.Text.Encoding.UTF8, "application/json"));

        await user.Client.DeleteAsync($"/api/v1/accounts/{card.Id}");

        (await user.GetAsync<MeResponse>("/api/v1/me")).DefaultSpendingAccountId.Should().BeNull();
    }

    [Fact]
    public async Task Summary_converts_balances_to_the_base_currency()
    {
        await factory.SeedStandardRatesAsync();
        var user = await factory.RegisterUserAsync();
        await user.CreateAccountAsync("BYN", "BYN", 10_000);
        await user.CreateAccountAsync("USD", "USD", 10_000);
        var excluded = await user.PostAsync<AccountResponse>("/api/v1/accounts", new CreateAccountRequest
        {
            Name = "Вне итога", Type = AccountType.Cash, Currency = "EUR", InitialBalance = 99_999, IncludeInTotals = false,
        });

        var summary = await user.GetAsync<AccountsSummaryResponse>("/api/v1/accounts/summary");

        summary.Total.Currency.Should().Be("BYN");
        summary.Total.Amount.Should().Be(10_000 + 30_000);
        summary.Accounts.Should().HaveCount(2).And.NotContain(a => a.AccountId == excluded.Id);
    }
}
