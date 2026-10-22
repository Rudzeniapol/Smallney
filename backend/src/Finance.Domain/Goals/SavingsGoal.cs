using Finance.Domain.Common;

namespace Finance.Domain.Goals;

/// <summary>
/// Progress is the balance of <see cref="LinkedAccountId"/> when set, otherwise the sum of transfers marked with the goal.
/// </summary>
public sealed class SavingsGoal : UserOwnedEntity
{
    public string Name { get; set; } = string.Empty;

    /// <summary>Minor units of <see cref="Currency"/>.</summary>
    public long TargetAmount { get; set; }

    public string Currency { get; set; } = Monetary.Currency.BaseCode;

    public DateOnly? TargetDate { get; set; }

    public Guid? LinkedAccountId { get; set; }

    /// <summary>Lower number = more important.</summary>
    public int Priority { get; set; }

    public bool IsCompleted { get; set; }

    /// <summary>When the goal was marked completed.</summary>
    public DateOnly? CompletedOn { get; set; }

    public string? Color { get; set; }

    public string? Icon { get; set; }
}
