using Finance.Domain.Common;

namespace Finance.Domain.Budgets;

/// <summary>Plan for one financial month. All amounts are minor units of <see cref="Currency"/>.</summary>
public sealed class Budget : UserOwnedEntity
{
    /// <summary>First calendar day of the month the financial month is named after (see <see cref="FinancialMonth"/>).</summary>
    public DateOnly Month { get; set; }

    /// <summary>The user's base currency when the budget was created. Changing the base currency later does not convert it.</summary>
    public string Currency { get; set; } = Monetary.Currency.BaseCode;

    public long ExpectedIncome { get; set; }

    public FinancialMonth Period => FinancialMonth.FromCalendarDay(Month);
}

/// <summary>Spending limit for an expense category (root or child).</summary>
public sealed class BudgetLine : UserOwnedEntity
{
    public Guid BudgetId { get; set; }

    public Guid CategoryId { get; set; }

    public long PlannedAmount { get; set; }

    /// <summary>Carry the unspent remainder of this line into the next month's line of the same category.</summary>
    public bool Rollover { get; set; }
}

/// <summary>Money planned to go to a savings goal this month.</summary>
public sealed class BudgetGoalAllocation : UserOwnedEntity
{
    public Guid BudgetId { get; set; }

    public Guid SavingsGoalId { get; set; }

    public long PlannedAmount { get; set; }
}
