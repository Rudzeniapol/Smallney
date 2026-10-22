using System.Diagnostics.CodeAnalysis;
using System.Globalization;

namespace Finance.Domain.Budgets;

/// <summary>
/// A financial month named after the calendar month it starts in. With FirstDayOfMonth = 5,
/// "2026-10" covers 5 Oct 2026 – 4 Nov 2026.
/// </summary>
public readonly record struct FinancialMonth : IParsable<FinancialMonth>, IComparable<FinancialMonth>
{
    public FinancialMonth(int year, int month)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(year, 1);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(year, 9998);
        ArgumentOutOfRangeException.ThrowIfLessThan(month, 1);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(month, 12);
        Year = year;
        Month = month;
    }

    public int Year { get; }

    public int Month { get; }

    /// <summary>First day of the calendar month; how a budget's month is stored.</summary>
    public DateOnly FirstCalendarDay => new(Year, Month, 1);

    public static FinancialMonth FromCalendarDay(DateOnly date) => new(date.Year, date.Month);

    /// <summary>The financial month containing <paramref name="date"/>.</summary>
    public static FinancialMonth Containing(DateOnly date, int firstDayOfMonth)
    {
        var month = new FinancialMonth(date.Year, date.Month);
        return date.Day >= firstDayOfMonth ? month : month.AddMonths(-1);
    }

    public DateOnly Start(int firstDayOfMonth) => new(Year, Month, firstDayOfMonth);

    public DateOnly End(int firstDayOfMonth) => AddMonths(1).Start(firstDayOfMonth).AddDays(-1);

    public FinancialMonth AddMonths(int months)
    {
        var index = (Year * 12) + Month - 1 + months;
        return new FinancialMonth(index / 12, (index % 12) + 1);
    }

    public FinancialMonth Previous => AddMonths(-1);

    public FinancialMonth Next => AddMonths(1);

    /// <summary>Whole months from this month to <paramref name="other"/> (negative when other is earlier).</summary>
    public int MonthsUntil(FinancialMonth other) => ((other.Year - Year) * 12) + other.Month - Month;

    public int CompareTo(FinancialMonth other) => MonthsUntil(other) switch
    {
        > 0 => -1,
        < 0 => 1,
        _ => 0,
    };

    public static bool operator <(FinancialMonth left, FinancialMonth right) => left.CompareTo(right) < 0;

    public static bool operator >(FinancialMonth left, FinancialMonth right) => left.CompareTo(right) > 0;

    public static bool operator <=(FinancialMonth left, FinancialMonth right) => left.CompareTo(right) <= 0;

    public static bool operator >=(FinancialMonth left, FinancialMonth right) => left.CompareTo(right) >= 0;

    public override string ToString() => $"{Year:D4}-{Month:D2}";

    public static FinancialMonth Parse(string s, IFormatProvider? provider) =>
        TryParse(s, provider, out var result) ? result : throw new FormatException($"'{s}' is not a month in yyyy-MM format.");

    public static bool TryParse([NotNullWhen(true)] string? s, IFormatProvider? provider, out FinancialMonth result)
    {
        if (s is { Length: 7 }
            && DateOnly.TryParseExact(s + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
        {
            result = new FinancialMonth(date.Year, date.Month);
            return true;
        }

        result = default;
        return false;
    }
}
