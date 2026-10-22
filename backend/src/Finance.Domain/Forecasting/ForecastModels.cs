using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Monetary;

namespace Finance.Domain.Forecasting;

public enum ForecastGranularity
{
    Day,
    Month,
}

public enum FlowKind
{
    /// <summary>A cleared transaction dated in the future.</summary>
    Scheduled,

    /// <summary>A Planned transaction (overdue ones are moved to today).</summary>
    Planned,

    /// <summary>A not yet materialized occurrence of a recurring rule.</summary>
    Recurring,

    VariableSpending,

    Interest,

    /// <summary>An unsaved one-off operation of a "what if" scenario.</summary>
    WhatIf,
}

/// <summary>A dated change of one account's balance, in minor units of that account's currency.</summary>
public sealed record ForecastFlow(
    DateOnly Date,
    Guid AccountId,
    long Amount,
    FlowKind Kind,
    Guid? SavingsGoalId = null,
    string? Label = null);

/// <summary>An account as the simulation sees it; <see cref="StartBalance"/> is the balance at the start of today.</summary>
public sealed record ForecastAccount(
    Guid Id,
    string Currency,
    long StartBalance,
    bool IncludeInTotals,
    AccountType Type = AccountType.DebitCard,
    long? CreditLimit = null,
    decimal? InterestRatePercent = null,
    CapitalizationPeriod? Capitalization = null,
    DateOnly? OpenDate = null,
    DateOnly? MaturityDate = null);

/// <param name="CurrentAmount">Saved so far in the goal currency (used when the goal has no linked account).</param>
public sealed record ForecastGoal(
    Guid Id,
    long TargetAmount,
    string Currency,
    DateOnly? TargetDate,
    Guid? LinkedAccountId,
    long CurrentAmount);

public enum VariableSpendingSource
{
    /// <summary>Remaining limits of the current month's budget.</summary>
    CurrentBudget,

    /// <summary>Planned lines of that month's budget.</summary>
    Budget,

    /// <summary>Median of the last full months.</summary>
    History,
}

/// <summary>Expected day-to-day spending of one financial month, spread evenly over [Start, End].</summary>
public sealed record VariableSpendingMonth(
    FinancialMonth Month,
    DateOnly Start,
    DateOnly End,
    long Total,
    VariableSpendingSource Source);

public sealed record ForecastInput(
    DateOnly Today,
    DateOnly From,
    DateOnly To,
    ForecastGranularity Granularity,
    Currency BaseCurrency,
    int FirstDayOfMonth,
    long LowBalanceThreshold,
    Guid? SpendingAccountId,
    IReadOnlyList<ForecastAccount> Accounts,
    IReadOnlyList<ForecastFlow> Flows,
    IReadOnlyList<VariableSpendingMonth> VariableSpending,
    IReadOnlyList<ForecastGoal> Goals,
    ExchangeRateTable Rates);

public sealed record BalancePoint(DateOnly Date, long Balance);

public sealed record AccountSeries(Guid AccountId, string Currency, IReadOnlyList<BalancePoint> Points, BalancePoint Minimum);

public enum AlarmKind
{
    /// <summary>All accounts together, in the base currency, below the user's threshold.</summary>
    TotalBelowThreshold,

    /// <summary>The spending account, converted to the base currency, below the user's threshold.</summary>
    SpendingAccountBelowThreshold,

    /// <summary>A non-credit account below zero.</summary>
    AccountNegative,

    /// <summary>A credit card beyond its limit.</summary>
    CreditLimitExceeded,
}

/// <summary>
/// One episode of consecutive alarming days. Balances are in the account currency, or in the base currency
/// for <see cref="AlarmKind.TotalBelowThreshold"/> and <see cref="AlarmKind.SpendingAccountBelowThreshold"/>.
/// </summary>
public sealed record ForecastAlarm(
    AlarmKind Kind,
    Guid? AccountId,
    DateOnly From,
    DateOnly Until,
    DateOnly LowestDate,
    long LowestBalance);

/// <param name="EvaluatedOn">TargetDate, or the end of the simulation when the date is beyond it or missing.</param>
/// <param name="MarginDays">Days between reaching the target and the target date.</param>
/// <param name="ExtraMonthlyNeeded">Additional monthly contribution that closes the shortfall by the target date.</param>
public sealed record GoalForecast(
    Guid GoalId,
    DateOnly? TargetDate,
    long TargetAmount,
    DateOnly EvaluatedOn,
    long ProjectedAmount,
    bool OnTrack,
    long Shortfall,
    DateOnly? ReachedOn,
    int? MarginDays,
    long? ExtraMonthlyNeeded,
    bool TargetBeyondHorizon);

public sealed record ForecastResult(
    IReadOnlyList<AccountSeries> Accounts,
    IReadOnlyList<BalancePoint> Total,
    IReadOnlyList<ForecastAlarm> Alarms,
    IReadOnlyList<GoalForecast> Goals);
