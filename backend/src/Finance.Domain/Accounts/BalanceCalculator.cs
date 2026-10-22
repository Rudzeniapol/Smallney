using Finance.Domain.Transactions;

namespace Finance.Domain.Accounts;

/// <summary>
/// Reference implementation of the balance rule. The server computes the same thing in SQL
/// (see BalanceQueries), the forecast and the mobile client use this logic directly.
/// </summary>
public static class BalanceCalculator
{
    /// <summary>InitialBalance + Σ effects of cleared, non-deleted transactions dated on or before <paramref name="asOf"/>.</summary>
    public static long Balance(Account account, IEnumerable<Transaction> transactions, DateOnly? asOf = null) =>
        account.InitialBalance + transactions
            .Where(t => t.Status == TransactionStatus.Cleared && !t.IsDeleted && (asOf is null || t.Date <= asOf))
            .Sum(t => t.BalanceEffect(account.Id));
}
