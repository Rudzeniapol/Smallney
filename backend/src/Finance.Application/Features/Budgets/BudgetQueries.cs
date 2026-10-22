using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Me;
using Finance.Domain.Budgets;
using Finance.Domain.Goals;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Budgets;

public sealed class BudgetQueries(IAppDbContext db, MeService me, GoalQueries goals, TimeProvider clock)
{
    public const int MaxListMonths = 36;

    public async Task<IReadOnlyList<BudgetResponse>> ListAsync(FinancialMonth from, FinancialMonth to, CancellationToken ct)
    {
        if (to < from || from.MonthsUntil(to) >= MaxListMonths)
        {
            throw new FluentValidation.ValidationException(
                [new FluentValidation.Results.ValidationFailure("to", $"Use a range of 1 to {MaxListMonths} months.")]);
        }

        var (first, last) = (from.FirstCalendarDay, to.FirstCalendarDay);
        var budgets = await db.Budgets.AsNoTracking().Where(b => b.Month >= first && b.Month <= last).OrderBy(b => b.Month).ToListAsync(ct);
        return await ToResponsesAsync(budgets, ct);
    }

    public async Task<BudgetResponse> GetAsync(FinancialMonth month, CancellationToken ct)
    {
        var day = month.FirstCalendarDay;
        var budget = await db.Budgets.AsNoTracking().FirstOrDefaultAsync(b => b.Month == day, ct)
                     ?? throw new NotFoundException("Budget", month);
        return (await ToResponsesAsync([budget], ct))[0];
    }

    /// <summary>
    /// A starting point for a new month: the previous month's income and lines, and for every open goal with a
    /// target date the recommended monthly contribution (other goals keep the previous allocation).
    /// </summary>
    public async Task<BudgetTemplateResponse> TemplateAsync(FinancialMonth month, CancellationToken ct)
    {
        var user = await me.GetUserAsync(ct);
        var previousDay = month.Previous.FirstCalendarDay;
        var previous = await db.Budgets.AsNoTracking().FirstOrDefaultAsync(b => b.Month == previousDay, ct);

        var lines = new List<BudgetLinePayload>();
        var previousAllocations = new Dictionary<Guid, long>();
        if (previous is not null)
        {
            lines = await db.BudgetLines.AsNoTracking()
                .Where(l => l.BudgetId == previous.Id)
                .OrderBy(l => l.CategoryId)
                .Select(l => new BudgetLinePayload { CategoryId = l.CategoryId, PlannedAmount = l.PlannedAmount, Rollover = l.Rollover })
                .ToListAsync(ct);
            previousAllocations = await db.BudgetGoalAllocations.AsNoTracking()
                .Where(a => a.BudgetId == previous.Id)
                .ToDictionaryAsync(a => a.SavingsGoalId, a => a.PlannedAmount, ct);
        }

        var openGoals = await db.SavingsGoals.AsNoTracking().Where(g => !g.IsCompleted).OrderBy(g => g.Priority).ToListAsync(ct);
        var today = user.LocalToday(clock.GetUtcNow());
        var progress = await goals.ProgressAsync(openGoals, today, month, user.FirstDayOfMonth, ct);
        var allocations = new List<BudgetAllocationPayload>();
        foreach (var goal in openGoals)
        {
            var amount = progress[goal.Id].RecommendedMonthly ?? previousAllocations.GetValueOrDefault(goal.Id);
            if (amount > 0 || previousAllocations.ContainsKey(goal.Id))
            {
                allocations.Add(new BudgetAllocationPayload { SavingsGoalId = goal.Id, PlannedAmount = amount });
            }
        }

        return new BudgetTemplateResponse(
            month.ToString(),
            previous?.Currency ?? user.BaseCurrency,
            BasedOnPrevious: previous is not null,
            previous?.ExpectedIncome ?? 0,
            lines,
            allocations);
    }

    private async Task<List<BudgetResponse>> ToResponsesAsync(IReadOnlyList<Budget> budgets, CancellationToken ct)
    {
        var firstDay = (await me.GetUserAsync(ct)).FirstDayOfMonth;
        var ids = budgets.Select(b => b.Id).ToList();
        var lines = (await db.BudgetLines.AsNoTracking().Where(l => ids.Contains(l.BudgetId)).ToListAsync(ct))
            .ToLookup(l => l.BudgetId);
        var allocations = (await db.BudgetGoalAllocations.AsNoTracking().Where(a => ids.Contains(a.BudgetId)).ToListAsync(ct))
            .ToLookup(a => a.BudgetId);

        return budgets.Select(b => new BudgetResponse(
                b.Id,
                b.Period.ToString(),
                b.Period.Start(firstDay),
                b.Period.End(firstDay),
                b.Currency,
                b.ExpectedIncome,
                lines[b.Id].Select(l => new BudgetLineResponse(l.Id, l.CategoryId, l.PlannedAmount, l.Rollover, l.Version)).ToList(),
                allocations[b.Id].Select(a => new BudgetAllocationResponse(a.Id, a.SavingsGoalId, a.PlannedAmount, a.Version)).ToList(),
                b.Version,
                b.CreatedAt,
                b.UpdatedAt))
            .ToList();
    }
}
