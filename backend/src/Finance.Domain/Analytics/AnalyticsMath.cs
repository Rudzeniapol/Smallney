using Finance.Domain.Budgets;
using Finance.Domain.Monetary;

namespace Finance.Domain.Analytics;

public readonly record struct Period(DateOnly From, DateOnly To)
{
    public int Days => To.DayNumber - From.DayNumber + 1;
}

public sealed record SpendingAverages(long Total, int Days, long PerDay, long PerWeek, long PerMonth);

public static class AnalyticsMath
{
    /// <summary>Average month length used to scale daily spending (365.25 / 12).</summary>
    public const decimal DaysPerMonth = 30.4375m;

    /// <summary>
    /// The period to compare with:
    /// <list type="bullet">
    /// <item>whole financial months → the same number of months right before;</item>
    /// <item>a period starting on a month start (e.g. month to date) → the same days of the previous month(s):
    /// 5–22 Oct is compared with 5–22 Sep;</item>
    /// <item>anything else → the same number of days right before.</item>
    /// </list>
    /// </summary>
    public static Period PreviousPeriod(Period period, int firstDayOfMonth)
    {
        var startMonth = FinancialMonth.Containing(period.From, firstDayOfMonth);
        if (period.From != startMonth.Start(firstDayOfMonth))
        {
            return new Period(period.From.AddDays(-period.Days), period.From.AddDays(-1));
        }

        var endMonth = FinancialMonth.Containing(period.To, firstDayOfMonth);
        var months = startMonth.MonthsUntil(endMonth) + 1;
        var previousFrom = startMonth.AddMonths(-months).Start(firstDayOfMonth);
        var limit = period.From.AddDays(-1);
        if (period.To == endMonth.End(firstDayOfMonth))
        {
            return new Period(previousFrom, limit);
        }

        var previousTo = previousFrom.AddDays(period.Days - 1);
        return new Period(previousFrom, previousTo > limit ? limit : previousTo);
    }

    /// <summary>(current − previous) / |previous| × 100 with one decimal; null when there is nothing to compare with.</summary>
    public static decimal? ChangePercent(long current, long previous) =>
        previous == 0 ? null : Math.Round((current - previous) * 100m / Math.Abs(previous), 1, MidpointRounding.ToEven);

    /// <summary>Share of <paramref name="part"/> in <paramref name="total"/>, percent with one decimal.</summary>
    public static decimal Share(long part, long total) =>
        total == 0 ? 0 : Math.Round(part * 100m / total, 1, MidpointRounding.ToEven);

    /// <summary>
    /// Averages over the elapsed part of the period (days after <paramref name="today"/> do not count yet).
    /// Per week = per day × 7, per month = per day × 30.4375.
    /// </summary>
    public static SpendingAverages Averages(Money total, Period period, DateOnly today)
    {
        var to = period.To < today ? period.To : today;
        var days = Math.Max(1, to.DayNumber - period.From.DayNumber + 1);
        var perDay = total.ToDecimal() / days;
        return new SpendingAverages(
            total.Amount,
            days,
            Money.FromDecimal(perDay, total.Currency).Amount,
            Money.FromDecimal(perDay * 7, total.Currency).Amount,
            Money.FromDecimal(perDay * DaysPerMonth, total.Currency).Amount);
    }
}
