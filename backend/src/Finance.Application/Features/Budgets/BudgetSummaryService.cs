using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Me;
using Finance.Domain.Budgets;
using Finance.Domain.Monetary;
using Finance.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Budgets;

/// <summary>Loads a month (and the rollover chain before it) and runs <see cref="BudgetCalculator"/>.</summary>
public sealed class BudgetSummaryService(
    IAppDbContext db,
    MeService me,
    SpendingQueries spending,
    GoalQueries goals,
    TimeProvider clock)
{
    /// <summary>How far back unspent remainders are carried over.</summary>
    public const int MaxRolloverMonths = 12;

    public async Task<BudgetSummaryResponse> GetAsync(FinancialMonth month, CancellationToken ct)
    {
        var user = await me.GetUserAsync(ct);
        var firstDay = user.FirstDayOfMonth;

        var oldest = month.AddMonths(-MaxRolloverMonths);
        var (fromDay, toDay) = (oldest.FirstCalendarDay, month.FirstCalendarDay);
        var budgets = (await db.Budgets.AsNoTracking().Where(b => b.Month >= fromDay && b.Month <= toDay).ToListAsync(ct))
            .ToDictionary(b => b.Period);
        if (!budgets.TryGetValue(month, out var budget))
        {
            throw new NotFoundException("Budget", month);
        }

        // Consecutive budgets in the same currency ending at the requested month.
        var chain = new List<FinancialMonth> { month };
        for (var m = month.Previous; m >= oldest && budgets.TryGetValue(m, out var b) && b.Currency == budget.Currency; m = m.Previous)
        {
            chain.Insert(0, m);
        }

        var budgetIds = chain.Select(m => budgets[m].Id).ToList();
        var lines = (await db.BudgetLines.AsNoTracking().Where(l => budgetIds.Contains(l.BudgetId)).ToListAsync(ct)).ToLookup(l => l.BudgetId);
        var allocations = (await db.BudgetGoalAllocations.AsNoTracking().Where(a => budgetIds.Contains(a.BudgetId)).ToListAsync(ct))
            .ToLookup(a => a.BudgetId);
        var parents = await db.Categories.AsNoTracking()
            .IgnoreQueryFilters([QueryFilters.SoftDelete])
            .ToDictionaryAsync(c => c.Id, c => c.ParentId, ct);

        var flows = await spending.FlowsAsync(chain[0].Start(firstDay), month.End(firstDay), ct);
        var table = await spending.RatesAsync(ct);
        var currency = Currency.FromCode(budget.Currency);
        var byMonth = flows.ToLookup(f => FinancialMonth.Containing(f.Date, firstDay));

        var inputs = chain.Select(m =>
        {
            var b = budgets[m];
            var monthFlows = byMonth[m].ToList();
            var spent = SpendingQueries.Sum(
                monthFlows.Where(f => f.Type == TransactionType.Expense), f => f.CategoryId, Money, f => f.Date, currency, table);
            var income = SpendingQueries.Sum(
                monthFlows.Where(f => f.Type == TransactionType.Income), _ => 0, Money, f => f.Date, currency, table);
            return (BudgetMonthInput?)new BudgetMonthInput(
                b.ExpectedIncome,
                income.GetValueOrDefault(0),
                lines[b.Id].Select(l => new BudgetLineInput(l.Id, l.CategoryId, l.PlannedAmount, l.Rollover)).ToList(),
                allocations[b.Id].Select(a => new BudgetAllocationInput(a.Id, a.SavingsGoalId, a.PlannedAmount)).ToList(),
                spent,
                parents);
        }).ToList();

        var result = BudgetCalculator.CalculateChain(inputs)!;
        var recommended = await RecommendedAsync(allocations[budget.Id].Select(a => a.SavingsGoalId).ToList(), month, ct);

        return new BudgetSummaryResponse(
            budget.Id,
            month.ToString(),
            month.Start(firstDay),
            month.End(firstDay),
            budget.Currency,
            result.ExpectedIncome,
            result.ActualIncome,
            result.ToSavings,
            result.Allocated,
            result.Unallocated,
            result.IsOverAllocated,
            result.TotalSpent,
            result.OffBudgetTotal,
            result.Lines
                .Select(l => new BudgetLineSummary(
                    l.LineId, l.CategoryId, l.Planned, l.CarriedOver, l.Limit, l.Spent, l.Remaining, l.Percent, l.Status, l.Rollover))
                .OrderByDescending(l => l.Percent ?? 0)
                .ToList(),
            allocations[budget.Id]
                .Select(a => new GoalAllocationSummary(a.Id, a.SavingsGoalId, a.PlannedAmount, recommended.GetValueOrDefault(a.SavingsGoalId)))
                .ToList(),
            result.OffBudget.Select(o => new OffBudgetItem(o.CategoryId, o.Spent)).ToList());
    }

    private static Money Money(FlowRow row) => new(row.Amount, Currency.FromCode(row.Currency));

    private async Task<Dictionary<Guid, long?>> RecommendedAsync(IReadOnlyList<Guid> goalIds, FinancialMonth month, CancellationToken ct)
    {
        var user = await me.GetUserAsync(ct);
        var list = await db.SavingsGoals.AsNoTracking().Where(g => goalIds.Contains(g.Id)).ToListAsync(ct);
        var progress = await goals.ProgressAsync(list, user.LocalToday(clock.GetUtcNow()), month, user.FirstDayOfMonth, ct);
        return progress.ToDictionary(p => p.Key, p => p.Value.RecommendedMonthly);
    }
}
