namespace Finance.Domain.Recurring;

public enum Frequency
{
    Daily,
    Weekly,
    Monthly,
    Yearly,
}

/// <summary>
/// When a recurring rule fires. Periods are anchored at <see cref="StartDate"/>:
/// <list type="bullet">
/// <item>Daily: every <see cref="Interval"/> days from StartDate.</item>
/// <item>Weekly: on <see cref="DayOfWeek"/> (default: StartDate's) every Interval weeks, first one on or after StartDate.</item>
/// <item>Monthly: on <see cref="DayOfMonth"/> (default: StartDate's day) every Interval months counted from StartDate's month.</item>
/// <item>Yearly: on DayOfMonth of StartDate's month every Interval years.</item>
/// </list>
/// A day past the end of a month falls on the month's last day (31 → 30 Apr, 29 Feb → 28 Feb).
/// Occurrences before StartDate (possible in the first month) and after EndDate are dropped.
/// </summary>
public sealed record RecurrenceSchedule(
    Frequency Frequency,
    int Interval,
    DateOnly StartDate,
    DateOnly? EndDate = null,
    int? DayOfMonth = null,
    DayOfWeek? DayOfWeek = null)
{
    public const int MaxInterval = 1000;

    /// <summary>All occurrences in [<paramref name="from"/>, <paramref name="to"/>], ascending.</summary>
    public IEnumerable<DateOnly> Occurrences(DateOnly from, DateOnly to)
    {
        if (Interval < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(Interval), Interval, "Interval must be at least 1.");
        }

        var first = from > StartDate ? from : StartDate;
        var last = EndDate is { } end && end < to ? end : to;
        if (first > last)
        {
            return [];
        }

        return Frequency switch
        {
            Frequency.Daily => Daily(first, last),
            Frequency.Weekly => Weekly(first, last),
            Frequency.Monthly => Monthly(first, last, monthsStep: Interval),
            Frequency.Yearly => Monthly(first, last, monthsStep: Interval * 12),
            _ => throw new ArgumentOutOfRangeException(nameof(Frequency), Frequency, null),
        };
    }

    /// <summary>The first occurrence on or after <paramref name="date"/>, if any.</summary>
    public DateOnly? NextOccurrence(DateOnly date) =>
        Occurrences(date, EndDate ?? DateOnly.MaxValue).Cast<DateOnly?>().FirstOrDefault();

    private IEnumerable<DateOnly> Daily(DateOnly first, DateOnly last)
    {
        // Skip ahead to the first step on or after `first` instead of walking from StartDate.
        var offset = first.DayNumber - StartDate.DayNumber;
        var steps = (offset + Interval - 1) / Interval;
        for (var day = StartDate.DayNumber + (steps * Interval); day <= last.DayNumber; day += Interval)
        {
            yield return DateOnly.FromDayNumber(day);
        }
    }

    private IEnumerable<DateOnly> Weekly(DateOnly first, DateOnly last)
    {
        var weekday = DayOfWeek ?? StartDate.DayOfWeek;
        var anchor = StartDate.AddDays(((int)weekday - (int)StartDate.DayOfWeek + 7) % 7);
        var period = Interval * 7;
        var offset = first.DayNumber - anchor.DayNumber;
        var steps = offset <= 0 ? 0 : (offset + period - 1) / period;
        for (var day = anchor.DayNumber + (steps * period); day <= last.DayNumber; day += period)
        {
            yield return DateOnly.FromDayNumber(day);
        }
    }

    private IEnumerable<DateOnly> Monthly(DateOnly first, DateOnly last, int monthsStep)
    {
        var day = DayOfMonth ?? StartDate.Day;
        var startIndex = MonthIndex(StartDate);

        // First period whose month is not before `first`'s month.
        var offset = MonthIndex(first) - startIndex;
        var steps = offset <= 0 ? 0 : (offset + monthsStep - 1) / monthsStep;
        for (var index = startIndex + (steps * monthsStep); index <= MonthIndex(last); index += monthsStep)
        {
            var year = index / 12;
            var month = (index % 12) + 1;
            var date = new DateOnly(year, month, Math.Min(day, DateTime.DaysInMonth(year, month)));
            if (date >= first && date <= last)
            {
                yield return date;
            }
        }
    }

    private static int MonthIndex(DateOnly date) => (date.Year * 12) + date.Month - 1;
}
