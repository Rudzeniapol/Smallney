using System.Text.Json;
using Finance.Application.Abstractions;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Budgets;
using Finance.Application.Features.Categories;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Recurring;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Domain.Goals;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Sync;

/// <summary>How one entity type is read, written and serialized by sync. Writes go through the REST writers.</summary>
internal interface ISyncHandler
{
    string EntityType { get; }

    /// <summary>Dependency rank: upserts run in ascending, deletes in descending order.</summary>
    int Order { get; }

    /// <summary>Tie-breaker inside a type for upserts (parents before children).</summary>
    int SubOrder(JsonElement? payload);

    /// <summary>The same tie-breaker for deletes, taken from the stored entities (deletes have no payload).</summary>
    Task<Dictionary<Guid, int>> SubOrdersAsync(IReadOnlyCollection<Guid> ids, CancellationToken ct);

    Task<UserOwnedEntity?> FindAsync(Guid id, CancellationToken ct);

    Task<UserOwnedEntity> CreateAsync(Guid id, JsonElement payload, CancellationToken ct);

    Task<UserOwnedEntity> UpdateAsync(Guid id, JsonElement payload, CancellationToken ct);

    Task DeleteAsync(Guid id, CancellationToken ct);

    /// <summary>Changes with Version &gt; since, deleted rows included, oldest first.</summary>
    Task<List<UserOwnedEntity>> ChangesAsync(long since, int take, CancellationToken ct);

    object ToData(UserOwnedEntity entity);
}

internal sealed class SyncHandler<TEntity, TPayload>(
    string entityType,
    int order,
    Func<IAppDbContext, DbSet<TEntity>> set,
    IAppDbContext db,
    Func<Guid, TPayload, CancellationToken, Task<TEntity>> create,
    Func<Guid, TPayload, CancellationToken, Task<TEntity>> update,
    Func<Guid, CancellationToken, Task> delete,
    Func<TEntity, object> toData,
    Func<TPayload, int>? subOrder = null,
    Func<TEntity, int>? storedSubOrder = null) : ISyncHandler
    where TEntity : UserOwnedEntity
{
    public string EntityType => entityType;

    public int Order => order;

    public int SubOrder(JsonElement? payload)
    {
        if (subOrder is null || payload is null)
        {
            return 0;
        }

        try
        {
            return Parse(payload.Value) is { } p ? subOrder(p) : 0;
        }
        catch (JsonException)
        {
            return 0;
        }
    }

    public async Task<Dictionary<Guid, int>> SubOrdersAsync(IReadOnlyCollection<Guid> ids, CancellationToken ct)
    {
        if (storedSubOrder is null || ids.Count == 0)
        {
            return [];
        }

        var entities = await set(db).IgnoreQueryFilters([QueryFilters.SoftDelete]).AsNoTracking().Where(e => ids.Contains(e.Id)).ToListAsync(ct);
        return entities.ToDictionary(e => e.Id, storedSubOrder);
    }

    public async Task<UserOwnedEntity?> FindAsync(Guid id, CancellationToken ct) =>
        await set(db).IgnoreQueryFilters([QueryFilters.SoftDelete]).FirstOrDefaultAsync(e => e.Id == id, ct);

    public async Task<UserOwnedEntity> CreateAsync(Guid id, JsonElement payload, CancellationToken ct) =>
        await create(id, Parse(payload) ?? throw new JsonException("The payload is empty."), ct);

    public async Task<UserOwnedEntity> UpdateAsync(Guid id, JsonElement payload, CancellationToken ct) =>
        await update(id, Parse(payload) ?? throw new JsonException("The payload is empty."), ct);

    public Task DeleteAsync(Guid id, CancellationToken ct) => delete(id, ct);

    public async Task<List<UserOwnedEntity>> ChangesAsync(long since, int take, CancellationToken ct) =>
        (await set(db).IgnoreQueryFilters([QueryFilters.SoftDelete]).AsNoTracking()
            .Where(e => e.Version > since)
            .OrderBy(e => e.Version)
            .Take(take)
            .ToListAsync(ct))
        .Cast<UserOwnedEntity>()
        .ToList();

    public object ToData(UserOwnedEntity entity) => toData((TEntity)entity);

    private static TPayload? Parse(JsonElement payload) => payload.Deserialize<TPayload>(SyncJson.Options);
}

/// <summary>The registry of synced entity types.</summary>
public sealed class SyncHandlers(
    IAppDbContext db,
    AccountWriter accounts,
    CategoryWriter categories,
    GoalWriter goals,
    RecurringRuleWriter rules,
    BudgetPartsWriter budgets,
    TransactionWriter transactions)
{
    private Dictionary<string, ISyncHandler>? _handlers;

    internal IReadOnlyDictionary<string, ISyncHandler> All => _handlers ??= Build().ToDictionary(h => h.EntityType, StringComparer.Ordinal);

    private IEnumerable<ISyncHandler> Build()
    {
        yield return new SyncHandler<Account, AccountPayload>(
            SyncEntityTypes.Account, 10, d => d.Accounts, db,
            async (id, p, ct) => await accounts.CreateAsync(id, p, ct),
            async (id, p, ct) => await accounts.UpdateAsync(id, p, ct),
            accounts.DeleteAsync,
            a => new AccountPayload
            {
                Name = a.Name, Type = a.Type, Currency = a.Currency, InitialBalance = a.InitialBalance, IncludeInTotals = a.IncludeInTotals,
                IsArchived = a.IsArchived, SortOrder = a.SortOrder, Color = a.Color, Icon = a.Icon, CreditLimit = a.CreditLimit,
                InterestRatePercent = a.InterestRatePercent, CapitalizationPeriod = a.CapitalizationPeriod, OpenDate = a.OpenDate,
                MaturityDate = a.MaturityDate,
            });

        yield return new SyncHandler<Category, CategoryPayload>(
            SyncEntityTypes.Category, 20, d => d.Categories, db,
            async (id, p, ct) => await categories.CreateAsync(id, p, ct),
            async (id, p, ct) => await categories.UpdateAsync(id, p, ct),
            categories.DeleteAsync,
            c => new CategorySyncData
            {
                Name = c.Name, Kind = c.Kind, ParentId = c.ParentId, Icon = c.Icon, Color = c.Color, IsArchived = c.IsArchived,
                SystemCode = c.SystemCode,
            },
            p => p.ParentId is null ? 0 : 1,
            c => c.ParentId is null ? 0 : 1);

        yield return new SyncHandler<SavingsGoal, SavingsGoalPayload>(
            SyncEntityTypes.SavingsGoal, 30, d => d.SavingsGoals, db,
            async (id, p, ct) => await goals.CreateAsync(id, p, ct),
            async (id, p, ct) => await goals.UpdateAsync(id, p, ct),
            goals.DeleteAsync,
            g => new SavingsGoalPayload
            {
                Name = g.Name, TargetAmount = g.TargetAmount, Currency = g.Currency, TargetDate = g.TargetDate,
                LinkedAccountId = g.LinkedAccountId, Priority = g.Priority, IsCompleted = g.IsCompleted, CompletedOn = g.CompletedOn,
                Color = g.Color, Icon = g.Icon,
            });

        yield return new SyncHandler<RecurringRule, RecurringRulePayload>(
            SyncEntityTypes.RecurringRule, 40, d => d.RecurringRules, db,
            async (id, p, ct) => await rules.CreateAsync(id, p, ct),
            async (id, p, ct) => await rules.UpdateAsync(id, p, ct),
            rules.DeleteAsync,
            r => new RecurringRulePayload
            {
                Name = r.Name, AccountId = r.AccountId, Type = r.Type, Amount = r.Amount, CategoryId = r.CategoryId, Note = r.Note,
                Tags = r.Tags, ToAccountId = r.ToAccountId, ToAmount = r.ToAmount, SavingsGoalId = r.SavingsGoalId,
                Frequency = r.Frequency, Interval = r.Interval, DayOfMonth = r.DayOfMonth, DayOfWeek = r.DayOfWeek,
                StartDate = r.StartDate, EndDate = r.EndDate, IsActive = r.IsActive,
            });

        yield return new SyncHandler<Budget, BudgetSyncPayload>(
            SyncEntityTypes.Budget, 50, d => d.Budgets, db,
            async (id, p, ct) => await budgets.CreateBudgetAsync(id, p, ct),
            async (id, p, ct) => await budgets.UpdateBudgetAsync(id, p, ct),
            budgets.DeleteBudgetAsync,
            b => new BudgetSyncPayload { Month = b.Period.ToString(), Currency = b.Currency, ExpectedIncome = b.ExpectedIncome });

        yield return new SyncHandler<BudgetLine, BudgetLineSyncPayload>(
            SyncEntityTypes.BudgetLine, 60, d => d.BudgetLines, db,
            async (id, p, ct) => await budgets.CreateLineAsync(id, p, ct),
            async (id, p, ct) => await budgets.UpdateLineAsync(id, p, ct),
            budgets.DeleteLineAsync,
            l => new BudgetLineSyncPayload { BudgetId = l.BudgetId, CategoryId = l.CategoryId, PlannedAmount = l.PlannedAmount, Rollover = l.Rollover });

        yield return new SyncHandler<BudgetGoalAllocation, BudgetAllocationSyncPayload>(
            SyncEntityTypes.BudgetGoalAllocation, 70, d => d.BudgetGoalAllocations, db,
            async (id, p, ct) => await budgets.CreateAllocationAsync(id, p, ct),
            async (id, p, ct) => await budgets.UpdateAllocationAsync(id, p, ct),
            budgets.DeleteAllocationAsync,
            a => new BudgetAllocationSyncPayload { BudgetId = a.BudgetId, SavingsGoalId = a.SavingsGoalId, PlannedAmount = a.PlannedAmount });

        yield return new SyncHandler<Transaction, TransactionPayload>(
            SyncEntityTypes.Transaction, 80, d => d.Transactions, db,
            async (id, p, ct) => await transactions.CreateAsync(id, p, ct),
            async (id, p, ct) => await transactions.UpdateAsync(id, p, ct),
            transactions.DeleteAsync,
            t => new TransactionPayload
            {
                AccountId = t.AccountId, Type = t.Type, Amount = t.Amount, CategoryId = t.CategoryId, Date = t.Date, Note = t.Note,
                Tags = t.Tags, Status = t.Status, ToAccountId = t.ToAccountId, ToAmount = t.ToAmount, SavingsGoalId = t.SavingsGoalId,
                RecurringRuleId = t.RecurringRuleId, RecurrenceDate = t.RecurrenceDate,
            });
    }
}
