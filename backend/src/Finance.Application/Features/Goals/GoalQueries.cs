using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Me;
using Finance.Domain.Budgets;
using Finance.Domain.Goals;
using Finance.Domain.Monetary;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Goals;

public sealed class GoalQueries(
    IAppDbContext db,
    MeService me,
    BalanceQueries balances,
    SpendingQueries spending,
    TimeProvider clock)
{
    public async Task<IReadOnlyList<SavingsGoalResponse>> ListAsync(bool includeCompleted, CancellationToken ct)
    {
        var query = db.SavingsGoals.AsNoTracking();
        if (!includeCompleted)
        {
            query = query.Where(g => !g.IsCompleted);
        }

        var goals = await query.OrderBy(g => g.IsCompleted).ThenBy(g => g.Priority).ThenBy(g => g.Name).ToListAsync(ct);
        var user = await me.GetUserAsync(ct);
        var today = user.LocalToday(clock.GetUtcNow());
        var month = FinancialMonth.Containing(today, user.FirstDayOfMonth);
        var progress = await ProgressAsync(goals, today, month, user.FirstDayOfMonth, ct);
        return goals.Select(g => SavingsGoalResponse.From(g, progress[g.Id])).ToList();
    }

    public async Task<SavingsGoalResponse> GetAsync(Guid id, CancellationToken ct)
    {
        var goal = await db.SavingsGoals.AsNoTracking().FirstOrDefaultAsync(g => g.Id == id, ct)
                   ?? throw new NotFoundException("SavingsGoal", id);
        var user = await me.GetUserAsync(ct);
        var today = user.LocalToday(clock.GetUtcNow());
        var progress = await ProgressAsync([goal], today, FinancialMonth.Containing(today, user.FirstDayOfMonth), user.FirstDayOfMonth, ct);
        return SavingsGoalResponse.From(goal, progress[goal.Id]);
    }

    /// <summary>Progress of each goal; the recommendation is computed for <paramref name="month"/>.</summary>
    public async Task<Dictionary<Guid, GoalProgress>> ProgressAsync(
        IReadOnlyList<SavingsGoal> goals,
        DateOnly today,
        FinancialMonth month,
        int firstDayOfMonth,
        CancellationToken ct)
    {
        var current = await CurrentAmountsAsync(goals, today, ct);
        return goals.ToDictionary(
            g => g.Id,
            g => SavingsGoalMath.Progress(g, current[g.Id], today, month, firstDayOfMonth));
    }

    /// <summary>Linked account balance (at today's rate) or the sum of marked transfers (at each transfer's rate).</summary>
    private async Task<Dictionary<Guid, long>> CurrentAmountsAsync(IReadOnlyList<SavingsGoal> goals, DateOnly today, CancellationToken ct)
    {
        var result = goals.ToDictionary(g => g.Id, _ => 0L);
        if (goals.Count == 0)
        {
            return result;
        }

        var table = await spending.RatesAsync(ct);
        var linkedIds = goals.Where(g => g.LinkedAccountId is not null).Select(g => g.LinkedAccountId!.Value).Distinct().ToList();
        if (linkedIds.Count > 0)
        {
            var accountBalances = await balances.GetBalancesAsync(linkedIds, asOf: null, ct);
            var currencies = await db.Accounts.AsNoTracking()
                .Where(a => linkedIds.Contains(a.Id))
                .ToDictionaryAsync(a => a.Id, a => a.Currency, ct);
            foreach (var goal in goals.Where(g => g.LinkedAccountId is { } id && currencies.ContainsKey(id)))
            {
                var accountId = goal.LinkedAccountId!.Value;
                var balance = new Money(accountBalances.GetValueOrDefault(accountId), Currency.FromCode(currencies[accountId]));
                result[goal.Id] = table.Convert(balance, Currency.FromCode(goal.Currency), today).Amount;
            }
        }

        var unlinked = goals.Where(g => g.LinkedAccountId is null).ToDictionary(g => g.Id);
        if (unlinked.Count > 0)
        {
            var contributions = (await spending.GoalContributionsAsync(ct)).Where(r => unlinked.ContainsKey(r.GoalId)).ToList();
            foreach (var group in contributions.GroupBy(r => r.GoalId))
            {
                var target = Currency.FromCode(unlinked[group.Key].Currency);
                result[group.Key] = SpendingQueries.Sum(
                    group, r => r.GoalId, r => new Money(r.Amount, Currency.FromCode(r.Currency)), r => r.Date, target, table)[group.Key];
            }
        }

        return result;
    }
}
