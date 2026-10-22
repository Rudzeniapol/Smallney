using Finance.Domain.Categories;
using Finance.Domain.Transactions;

namespace Finance.Application.Features.Analytics;

/// <param name="Amount">Including subcategories.</param>
/// <param name="DirectAmount">Recorded on the category itself.</param>
/// <param name="ChangePercent">Against the previous period; null when it had nothing (shown as "new").</param>
public sealed record CategoryBreakdownItem(
    Guid CategoryId,
    long Amount,
    long DirectAmount,
    decimal SharePercent,
    long PreviousAmount,
    decimal? ChangePercent,
    IReadOnlyList<CategoryBreakdownItem> Children);

public sealed record CategoryBreakdownResponse(
    DateOnly From,
    DateOnly To,
    DateOnly PreviousFrom,
    DateOnly PreviousTo,
    CategoryKind Kind,
    string Currency,
    long Total,
    long PreviousTotal,
    decimal? ChangePercent,
    IReadOnlyList<CategoryBreakdownItem> Categories);

/// <param name="IsCurrent">The month in progress (drawn hatched).</param>
public sealed record MonthlyPoint(string Month, DateOnly Start, DateOnly End, long Income, long Expense, long Net, bool IsCurrent);

public sealed record MonthlyDynamicsResponse(string Currency, Guid? CategoryId, IReadOnlyList<MonthlyPoint> Months);

public sealed record PeriodTotals(DateOnly From, DateOnly To, long Income, long Expense, long Net);

public sealed record Change(long Absolute, decimal? Percent);

public sealed record PeriodComparisonResponse(
    string Currency,
    PeriodTotals Current,
    PeriodTotals Previous,
    Change Income,
    Change Expense,
    Change Net);

/// <param name="Date">Month end, or today for the month in progress.</param>
public sealed record NetWorthPoint(string Month, DateOnly Date, long NetWorth, long Change);

public sealed record NetWorthResponse(string Currency, bool IncludesExcludedAccounts, IReadOnlyList<NetWorthPoint> Months);

public sealed record TopExpense(
    Guid TransactionId,
    DateOnly Date,
    Guid AccountId,
    Guid? CategoryId,
    string? Note,
    long Amount,
    string Currency,
    long AmountInBase);

public sealed record TopExpensesResponse(DateOnly From, DateOnly To, string Currency, IReadOnlyList<TopExpense> Items);

/// <param name="Days">Elapsed days of the period used for the averages.</param>
public sealed record AveragesResponse(DateOnly From, DateOnly To, string Currency, long Total, int Days, long PerDay, long PerWeek, long PerMonth);

public static class AnalyticsTypes
{
    public static TransactionType ToTransactionType(this CategoryKind kind) =>
        kind == CategoryKind.Income ? TransactionType.Income : TransactionType.Expense;
}
