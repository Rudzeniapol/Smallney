using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Transactions;
using Finance.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace Finance.Application.Abstractions;

/// <summary>
/// Unit of work over the database. User-owned sets are automatically filtered to the current user
/// and exclude soft-deleted rows (named query filters <see cref="QueryFilters"/>).
/// </summary>
public interface IAppDbContext
{
    DbSet<User> Users { get; }

    DbSet<RefreshToken> RefreshTokens { get; }

    DbSet<Account> Accounts { get; }

    DbSet<Category> Categories { get; }

    DbSet<Transaction> Transactions { get; }

    DbSet<ExchangeRate> ExchangeRates { get; }

    DatabaseFacade Database { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}

public static class QueryFilters
{
    /// <summary>Restricts user-owned entities to the current user.</summary>
    public const string Tenant = "Tenant";

    /// <summary>Hides soft-deleted rows.</summary>
    public const string SoftDelete = "SoftDelete";
}
