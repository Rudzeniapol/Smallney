using System.Reflection;
using Finance.Application.Abstractions;
using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Goals;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using Finance.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace Finance.Infrastructure.Persistence;

public sealed class AppDbContext(
    DbContextOptions<AppDbContext> options,
    ICurrentUser currentUser,
    TimeProvider clock) : DbContext(options), IAppDbContext
{
    public const string VersionSequence = "global_version_seq";

    /// <summary>
    /// Referenced by the tenant query filter; EF evaluates it per context instance.
    /// Without an authenticated user it is <see cref="Guid.Empty"/>, so nothing user-owned is visible.
    /// Background jobs opt out explicitly with IgnoreQueryFilters([QueryFilters.Tenant]).
    /// </summary>
    public Guid CurrentUserId => currentUser.UserId ?? Guid.Empty;

    public DbSet<User> Users => Set<User>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    public DbSet<Account> Accounts => Set<Account>();

    public DbSet<Category> Categories => Set<Category>();

    public DbSet<Transaction> Transactions => Set<Transaction>();

    public DbSet<RecurringRule> RecurringRules => Set<RecurringRule>();

    public DbSet<Budget> Budgets => Set<Budget>();

    public DbSet<BudgetLine> BudgetLines => Set<BudgetLine>();

    public DbSet<BudgetGoalAllocation> BudgetGoalAllocations => Set<BudgetGoalAllocation>();

    public DbSet<SavingsGoal> SavingsGoals => Set<SavingsGoal>();

    public DbSet<ExchangeRate> ExchangeRates => Set<ExchangeRate>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("pg_trgm");
        modelBuilder.HasSequence<long>(VersionSequence);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        var configure = typeof(AppDbContext).GetMethod(nameof(ConfigureUserOwned), BindingFlags.NonPublic | BindingFlags.Instance)!;
        foreach (var entityType in modelBuilder.Model.GetEntityTypes()
                     .Where(t => typeof(UserOwnedEntity).IsAssignableFrom(t.ClrType))
                     .ToList())
        {
            configure.MakeGenericMethod(entityType.ClrType).Invoke(this, [modelBuilder]);
        }
    }

    public override int SaveChanges(bool acceptAllChangesOnSuccess) =>
        throw new NotSupportedException("Use SaveChangesAsync: versions are assigned asynchronously.");

    /// <summary>
    /// Stamps timestamps and assigns a new <see cref="UserOwnedEntity.Version"/> from the global sequence to
    /// every changed user-owned row. Versions are taken under a per-user transaction-scoped advisory lock, so
    /// for any single user the commit order equals the version order and sync pull never skips a change.
    /// </summary>
    public override async Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
    {
        ChangeTracker.DetectChanges();
        var now = clock.GetUtcNow().UtcDateTime;

        foreach (var entry in ChangeTracker.Entries<IHasTimestamps>())
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        var owned = ChangeTracker.Entries<UserOwnedEntity>()
            .Where(e => e.State is EntityState.Added or EntityState.Modified or EntityState.Deleted)
            .ToList();
        if (owned.Count == 0)
        {
            return await base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
        }

        foreach (var entry in owned)
        {
            if (entry.State == EntityState.Deleted)
            {
                throw new InvalidOperationException(
                    $"{entry.Metadata.ClrType.Name} must be soft-deleted (MarkDeleted), not removed.");
            }

            if (currentUser.UserId is { } userId && entry.Entity.UserId != userId)
            {
                throw new InvalidOperationException("Attempt to write an entity that belongs to another user.");
            }
        }

        var ownTransaction = Database.CurrentTransaction is null
            ? await Database.BeginTransactionAsync(cancellationToken)
            : null;
        try
        {
            foreach (var userId in owned.Select(e => e.Entity.UserId).Distinct().Order())
            {
                await LockUserAsync(userId, cancellationToken);
            }

            var versions = await Database
                .SqlQueryRaw<long>(
                    $"SELECT nextval('{VersionSequence}') AS \"Value\" FROM generate_series(1, {{0}})",
                    owned.Count)
                .ToListAsync(cancellationToken);
            versions.Sort();
            for (var i = 0; i < owned.Count; i++)
            {
                owned[i].Entity.Version = versions[i];
            }

            var result = await base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
            if (ownTransaction is not null)
            {
                await ownTransaction.CommitAsync(cancellationToken);
            }

            return result;
        }
        finally
        {
            if (ownTransaction is not null)
            {
                await ownTransaction.DisposeAsync();
            }
        }
    }

    public async Task LockUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        if (Database.CurrentTransaction is null)
        {
            throw new InvalidOperationException("The user lock is transaction-scoped; begin a transaction first.");
        }

        var key = AdvisoryLockKey(userId);
        await Database.ExecuteSqlAsync($"SELECT pg_advisory_xact_lock({key})", cancellationToken);
    }

    private static long AdvisoryLockKey(Guid userId)
    {
        Span<byte> bytes = stackalloc byte[16];
        userId.TryWriteBytes(bytes);
        return BitConverter.ToInt64(bytes[..8]) ^ BitConverter.ToInt64(bytes[8..]);
    }

    private void ConfigureUserOwned<T>(ModelBuilder modelBuilder)
        where T : UserOwnedEntity
    {
        var entity = modelBuilder.Entity<T>();
        entity.HasQueryFilter(QueryFilters.Tenant, e => e.UserId == CurrentUserId);
        entity.HasQueryFilter(QueryFilters.SoftDelete, e => e.DeletedAt == null);
        entity.Property(e => e.Id).ValueGeneratedNever();
        entity.HasIndex(e => new { e.UserId, e.Version });
        entity.HasOne<User>().WithMany().HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
