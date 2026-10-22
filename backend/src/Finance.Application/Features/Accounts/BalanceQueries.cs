using Finance.Application.Abstractions;
using Finance.Domain.Transactions;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Accounts;

/// <summary>
/// Balance = InitialBalance + Σ cleared transactions, computed in SQL.
/// Served by partial covering indexes on (account_id, date) and (to_account_id, date).
/// </summary>
public sealed class BalanceQueries(IAppDbContext db)
{
    public async Task<Dictionary<Guid, long>> GetBalancesAsync(
        IReadOnlyCollection<Guid>? accountIds,
        DateOnly? asOf,
        CancellationToken ct)
    {
        var accounts = db.Accounts.AsQueryable();
        if (accountIds is not null)
        {
            accounts = accounts.Where(a => accountIds.Contains(a.Id));
        }

        var balances = await accounts.ToDictionaryAsync(a => a.Id, a => a.InitialBalance, ct);
        if (balances.Count == 0)
        {
            return balances;
        }

        var cleared = db.Transactions.Where(t => t.Status == TransactionStatus.Cleared);
        if (asOf is { } date)
        {
            cleared = cleared.Where(t => t.Date <= date);
        }

        var ids = balances.Keys.ToList();
        var outgoing = await cleared
            .Where(t => ids.Contains(t.AccountId))
            .GroupBy(t => t.AccountId)
            .Select(g => new { AccountId = g.Key, Sum = g.Sum(t => t.Type == TransactionType.Income ? t.Amount : -t.Amount) })
            .ToListAsync(ct);

        var incoming = await cleared
            .Where(t => t.ToAccountId != null && ids.Contains(t.ToAccountId.Value))
            .GroupBy(t => t.ToAccountId!.Value)
            .Select(g => new { AccountId = g.Key, Sum = g.Sum(t => t.ToAmount ?? 0) })
            .ToListAsync(ct);

        foreach (var row in outgoing.Concat(incoming))
        {
            balances[row.AccountId] += row.Sum;
        }

        return balances;
    }

    public async Task<long> GetBalanceAsync(Guid accountId, DateOnly? asOf, CancellationToken ct)
    {
        var balances = await GetBalancesAsync([accountId], asOf, ct);
        return balances.TryGetValue(accountId, out var balance) ? balance : 0;
    }
}
