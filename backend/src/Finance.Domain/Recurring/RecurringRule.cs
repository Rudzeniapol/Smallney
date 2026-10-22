using Finance.Domain.Common;
using Finance.Domain.Transactions;

namespace Finance.Domain.Recurring;

/// <summary>A template transaction plus a schedule. Occurrences are materialized as Planned transactions.</summary>
public sealed class RecurringRule : UserOwnedEntity
{
    /// <summary>Display name, e.g. "Мобильная связь".</summary>
    public string Name { get; set; } = string.Empty;

    // Transaction template.
    public Guid AccountId { get; set; }

    public TransactionType Type { get; set; }

    public long Amount { get; set; }

    public Guid? CategoryId { get; set; }

    public string? Note { get; set; }

    public string[] Tags { get; set; } = [];

    public Guid? ToAccountId { get; set; }

    public long? ToAmount { get; set; }

    public Guid? SavingsGoalId { get; set; }

    // Schedule.
    public Frequency Frequency { get; set; }

    public int Interval { get; set; } = 1;

    public int? DayOfMonth { get; set; }

    public DayOfWeek? DayOfWeek { get; set; }

    public DateOnly StartDate { get; set; }

    public DateOnly? EndDate { get; set; }

    public bool IsActive { get; set; } = true;

    public RecurrenceSchedule Schedule => new(Frequency, Interval, StartDate, EndDate, DayOfMonth, DayOfWeek);

    /// <summary>
    /// Id of the transaction materialized for an occurrence. Deterministic, so the server job and an offline
    /// client produce the same id for the same occurrence and never create duplicates.
    /// </summary>
    public static Guid OccurrenceTransactionId(Guid ruleId, DateOnly date) =>
        UuidV7.Deterministic(date, $"{ruleId:D}|{date:yyyy-MM-dd}");

    /// <summary>A Planned transaction for the occurrence on <paramref name="date"/>.</summary>
    public Transaction Materialize(DateOnly date) => new()
    {
        Id = OccurrenceTransactionId(Id, date),
        UserId = UserId,
        AccountId = AccountId,
        Type = Type,
        Amount = Amount,
        CategoryId = CategoryId,
        Date = date,
        Note = Note ?? Name,
        Tags = [.. Tags],
        Status = TransactionStatus.Planned,
        ToAccountId = ToAccountId,
        ToAmount = ToAmount,
        SavingsGoalId = SavingsGoalId,
        RecurringRuleId = Id,
        RecurrenceDate = date,
    };
}
