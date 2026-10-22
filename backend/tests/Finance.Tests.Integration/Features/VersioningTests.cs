using Finance.Application.Features.Accounts;
using Finance.Domain.Accounts;
using Finance.Infrastructure.Persistence;
using Finance.Tests.Integration.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Tests.Integration.Features;

/// <summary>Every change gets a fresh version from the global sequence; soft-deleted rows keep a version for sync.</summary>
public class VersioningTests(ApiFactory factory)
{
    [Fact]
    public async Task Versions_grow_on_every_change_including_soft_delete()
    {
        var user = await factory.RegisterUserAsync();
        var account = await user.CreateAccountAsync();
        var updated = await user.PutAsync<AccountResponse>($"/api/v1/accounts/{account.Id}",
            new AccountPayload { Name = "Другое имя", Type = AccountType.DebitCard, Currency = "BYN" });
        await user.Client.DeleteAsync($"/api/v1/accounts/{account.Id}");

        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var row = await db.Accounts.IgnoreQueryFilters().SingleAsync(a => a.Id == account.Id);

        updated.Version.Should().BeGreaterThan(account.Version);
        row.Version.Should().BeGreaterThan(updated.Version);
        row.DeletedAt.Should().NotBeNull();
        row.UpdatedAt.Should().BeOnOrAfter(row.CreatedAt);
    }

    [Fact]
    public async Task Concurrent_writes_of_one_user_get_distinct_versions()
    {
        var user = await factory.RegisterUserAsync();

        var accounts = await Task.WhenAll(Enumerable.Range(0, 10).Select(i => user.CreateAccountAsync($"Счёт {i}")));

        accounts.Select(a => a.Version).Should().OnlyHaveUniqueItems();
    }

    [Fact]
    public async Task Registration_versions_default_categories()
    {
        var user = await factory.RegisterUserAsync();

        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var versions = await db.Categories.IgnoreQueryFilters()
            .Where(c => c.UserId == user.Id)
            .Select(c => c.Version)
            .ToListAsync();

        versions.Should().NotBeEmpty().And.OnlyHaveUniqueItems().And.OnlyContain(v => v > 0);
    }
}
