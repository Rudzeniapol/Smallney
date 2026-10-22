using System.Net;
using Finance.Application.Common;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Categories;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.Transactions;
using Finance.Infrastructure.Persistence;
using Finance.Tests.Integration.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Tests.Integration.Features;

/// <summary>A user must never see or touch another user's data.</summary>
public class TenantIsolationTests(ApiFactory factory)
{
    private static readonly DateOnly Day = new(2026, 10, 1);

    [Fact]
    public async Task Lists_contain_only_own_data()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var aliceAccount = await alice.CreateAccountAsync("Alice");
        var aliceTx = await alice.ExpenseAsync(aliceAccount.Id, 100, Day);
        await bob.CreateAccountAsync("Bob");

        (await bob.GetAsync<List<AccountResponse>>("/api/v1/accounts?includeArchived=true"))
            .Should().ContainSingle().Which.Name.Should().Be("Bob");
        (await bob.GetAsync<CursorPage<TransactionResponse>>("/api/v1/transactions")).Items.Should().BeEmpty();
        (await bob.GetAsync<CursorPage<TransactionResponse>>($"/api/v1/transactions?accountId={aliceAccount.Id}")).Items.Should().BeEmpty();

        var aliceCategories = (await alice.GetAsync<List<CategoryResponse>>("/api/v1/categories")).Select(c => c.Id).ToHashSet();
        var bobCategories = await bob.GetAsync<List<CategoryResponse>>("/api/v1/categories");
        bobCategories.Should().NotBeEmpty().And.OnlyContain(c => !aliceCategories.Contains(c.Id));
        (await bob.GetAsync<AccountsSummaryResponse>("/api/v1/accounts/summary")).Accounts.Should().ContainSingle();

        aliceTx.Should().NotBeNull();
    }

    [Fact]
    public async Task Foreign_entities_are_not_found_by_id()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var account = await alice.CreateAccountAsync();
        var transaction = await alice.ExpenseAsync(account.Id, 100, Day);
        var category = await alice.CategoryAsync("Продукты");

        await (await bob.Client.GetAsync($"/api/v1/accounts/{account.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        await (await bob.Client.GetAsync($"/api/v1/transactions/{transaction.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        await (await bob.Client.GetAsync($"/api/v1/categories/{category.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Foreign_entities_cannot_be_modified_or_deleted()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var account = await alice.CreateAccountAsync(initialBalance: 1_000);
        var transaction = await alice.ExpenseAsync(account.Id, 100, Day);
        var category = await alice.CategoryAsync("Продукты");

        var putAccount = await bob.PutAsync($"/api/v1/accounts/{account.Id}",
            new AccountPayload { Name = "hacked", Type = AccountType.Cash, Currency = "BYN" });
        await putAccount.ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        await (await bob.Client.DeleteAsync($"/api/v1/accounts/{account.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");

        var bobCategory = await bob.CategoryAsync("Продукты");
        var bobAccount = await bob.CreateAccountAsync();
        var putTx = await bob.PutAsync($"/api/v1/transactions/{transaction.Id}", new TransactionPayload
        {
            AccountId = bobAccount.Id, Type = TransactionType.Expense, Amount = 1, CategoryId = bobCategory.Id, Date = Day,
        });
        await putTx.ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        await (await bob.Client.DeleteAsync($"/api/v1/transactions/{transaction.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");

        var putCategory = await bob.PutAsync($"/api/v1/categories/{category.Id}",
            new CategoryPayload { Name = "hacked", Kind = CategoryKind.Expense });
        await putCategory.ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");

        var aliceView = await alice.GetAsync<AccountResponse>($"/api/v1/accounts/{account.Id}");
        aliceView.Name.Should().Be("Карта");
        aliceView.Balance.Should().Be(900);
        (await alice.GetAsync<TransactionResponse>($"/api/v1/transactions/{transaction.Id}")).Amount.Should().Be(100);
    }

    [Fact]
    public async Task Foreign_accounts_and_categories_cannot_be_referenced()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var aliceAccount = await alice.CreateAccountAsync();
        var aliceCategory = await alice.CategoryAsync("Продукты");
        var bobAccount = await bob.CreateAccountAsync();
        var bobCategory = await bob.CategoryAsync("Продукты");

        var intoForeignAccount = await bob.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = aliceAccount.Id, Type = TransactionType.Expense, Amount = 1, CategoryId = bobCategory.Id, Date = Day,
        });
        await intoForeignAccount.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "account_not_found");

        var foreignCategory = await bob.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = bobAccount.Id, Type = TransactionType.Expense, Amount = 1, CategoryId = aliceCategory.Id, Date = Day,
        });
        await foreignCategory.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_not_found");

        var transferToForeign = await bob.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = bobAccount.Id, ToAccountId = aliceAccount.Id, Type = TransactionType.Transfer, Amount = 1, Date = Day,
        });
        await transferToForeign.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "account_not_found");

        var foreignParent = await bob.PostAsync("/api/v1/categories",
            new CreateCategoryRequest { Name = "x", Kind = CategoryKind.Expense, ParentId = aliceCategory.Id });
        await foreignParent.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "parent_not_found");

        (await alice.GetAsync<AccountResponse>($"/api/v1/accounts/{aliceAccount.Id}")).Balance.Should().Be(0);
    }

    [Fact]
    public async Task Taking_a_foreign_id_is_a_conflict_that_reveals_nothing()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var account = await alice.CreateAccountAsync();

        var response = await bob.PostAsync("/api/v1/accounts", new CreateAccountRequest
        {
            Id = account.Id, Name = "Mine", Type = AccountType.Cash, Currency = "BYN",
        });

        var problem = await response.ShouldBeProblemAsync(HttpStatusCode.Conflict, "id_conflict");
        problem.Detail.Should().NotContain(alice.Email);
        (await alice.GetAsync<AccountResponse>($"/api/v1/accounts/{account.Id}")).Name.Should().Be("Карта");
    }

    [Fact]
    public async Task Without_a_user_the_tenant_filter_hides_everything()
    {
        var alice = await factory.RegisterUserAsync();
        await alice.CreateAccountAsync();

        // A scope without an HTTP user (like a background job) sees no user-owned rows...
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        (await db.Accounts.AnyAsync(a => a.UserId == alice.Id)).Should().BeFalse();

        // ...unless it opts out of the tenant filter explicitly.
        (await db.Accounts.IgnoreQueryFilters([Finance.Application.Abstractions.QueryFilters.Tenant])
            .AnyAsync(a => a.UserId == alice.Id)).Should().BeTrue();
    }
}
