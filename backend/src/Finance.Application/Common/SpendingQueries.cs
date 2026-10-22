using Finance.Application.Abstractions;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Monetary;
using Finance.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Common;

/// <summary>Cleared income/expense pre-aggregated per (category, type, account currency, date).</summary>
public sealed record FlowRow(Guid CategoryId, TransactionType Type, string Currency, DateOnly Date, long Amount);

/// <summary>A cleared transfer into a goal, in the destination account currency.</summary>
public sealed record GoalContributionRow(Guid GoalId, string Currency, DateOnly Date, long Amount);

/// <summary>
/// Spending and income for budgets and analytics. SQL aggregates per day and currency; conversion to the
/// target currency happens in memory at the rate of each transaction date.
/// </summary>
public sealed class SpendingQueries(IAppDbContext db, IExchangeRateProvider rates)
{
    public async Task<IReadOnlyList<FlowRow>> FlowsAsync(DateOnly start, DateOnly end, CancellationToken ct) =>
        await (
                from t in db.Transactions
                join a in db.Accounts on t.AccountId equals a.Id
                where t.Status == TransactionStatus.Cleared
                      && t.Type != TransactionType.Transfer
                      && t.Date >= start && t.Date <= end
                group t by new { CategoryId = t.CategoryId!.Value, t.Type, a.Currency, t.Date } into g
                select new FlowRow(g.Key.CategoryId, g.Key.Type, g.Key.Currency, g.Key.Date, g.Sum(x => x.Amount)))
            .ToListAsync(ct);

    public async Task<IReadOnlyList<GoalContributionRow>> GoalContributionsAsync(CancellationToken ct) =>
        await (
                from t in db.Transactions
                join a in db.Accounts on t.ToAccountId equals a.Id
                where t.Status == TransactionStatus.Cleared && t.SavingsGoalId != null
                group t by new { GoalId = t.SavingsGoalId!.Value, a.Currency, t.Date } into g
                select new GoalContributionRow(g.Key.GoalId, g.Key.Currency, g.Key.Date, g.Sum(x => x.ToAmount ?? 0)))
            .ToListAsync(ct);

    public Task<ExchangeRateTable> RatesAsync(CancellationToken ct) => rates.GetTableAsync(ct);

    /// <summary>Converts each row at its date and sums per key.</summary>
    public static Dictionary<TKey, long> Sum<TRow, TKey>(
        IEnumerable<TRow> rows,
        Func<TRow, TKey> key,
        Func<TRow, Money> money,
        Func<TRow, DateOnly> date,
        Currency target,
        ExchangeRateTable table)
        where TKey : notnull
    {
        var result = new Dictionary<TKey, long>();
        foreach (var row in rows)
        {
            var converted = table.Convert(money(row), target, date(row));
            var k = key(row);
            result[k] = result.GetValueOrDefault(k) + converted.Amount;
        }

        return result;
    }
}
