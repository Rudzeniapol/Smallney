using Finance.Domain.Common;

namespace Finance.Domain.Transactions;

public enum TransactionType
{
    Income,
    Expense,
    Transfer,
}

public enum TransactionStatus
{
    /// <summary>Happened; affects balances.</summary>
    Cleared,

    /// <summary>Expected (e.g. materialized from a recurring rule); does not affect balances until confirmed.</summary>
    Planned,

    /// <summary>A planned occurrence the user skipped. Kept (not deleted) so it is not materialized again and can be undone.</summary>
    Skipped,
}

public sealed class Transaction : UserOwnedEntity
{
    public Guid AccountId { get; set; }

    public TransactionType Type { get; set; }

    /// <summary>Positive, minor units of the account currency.</summary>
    public long Amount { get; set; }

    /// <summary>Required for Income/Expense, null for Transfer.</summary>
    public Guid? CategoryId { get; set; }

    /// <summary>The user's local date.</summary>
    public DateOnly Date { get; set; }

    public string? Note { get; set; }

    public string[] Tags { get; set; } = [];

    public TransactionStatus Status { get; set; } = TransactionStatus.Cleared;

    /// <summary>Transfer only: destination account.</summary>
    public Guid? ToAccountId { get; set; }

    /// <summary>Transfer only: amount credited to the destination, in its currency.</summary>
    public long? ToAmount { get; set; }

    /// <summary>Transfer only: contribution to a savings goal.</summary>
    public Guid? SavingsGoalId { get; set; }

    /// <summary>Rule this transaction was materialized from.</summary>
    public Guid? RecurringRuleId { get; set; }

    /// <summary>The rule occurrence it stands for (Date may be moved by the user, this stays).</summary>
    public DateOnly? RecurrenceDate { get; set; }

    /// <summary>Signed effect on the balance of <paramref name="accountId"/>, ignoring status.</summary>
    public long BalanceEffect(Guid accountId)
    {
        long effect = 0;
        if (AccountId == accountId)
        {
            effect += Type == TransactionType.Income ? Amount : -Amount;
        }

        if (Type == TransactionType.Transfer && ToAccountId == accountId)
        {
            effect += ToAmount ?? 0;
        }

        return effect;
    }
}
