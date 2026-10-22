using Finance.Domain.Monetary;

namespace Finance.Domain.ExchangeRates;

/// <summary>A single known rate: BYN per one unit of <see cref="Currency"/> on <see cref="Date"/>.</summary>
public readonly record struct ExchangeRatePoint(string Currency, DateOnly Date, decimal RateToBase);

/// <summary>
/// Immutable in-memory rate history used for conversions. All conversions go through BYN.
/// For a date without a rate the closest earlier rate is used; when the date is before
/// the first known rate, the earliest known rate is used instead.
/// </summary>
public sealed class ExchangeRateTable
{
    private readonly Dictionary<string, Series> _series;

    public ExchangeRateTable(IEnumerable<ExchangeRatePoint> points)
    {
        _series = points
            .Where(p => p.Currency != Currency.BaseCode)
            .GroupBy(p => p.Currency, StringComparer.Ordinal)
            .ToDictionary(
                g => g.Key,
                g =>
                {
                    // Last write wins for duplicated dates.
                    var ordered = g.GroupBy(p => p.Date).Select(d => d.Last()).OrderBy(p => p.Date).ToArray();
                    return new Series(
                        ordered.Select(p => p.Date).ToArray(),
                        ordered.Select(p => Normalize(p.RateToBase)).ToArray());
                },
                StringComparer.Ordinal);
    }

    public static ExchangeRateTable Empty { get; } = new([]);

    public IEnumerable<string> Currencies => _series.Keys;

    /// <summary>BYN per one unit of <paramref name="currency"/> applicable on <paramref name="date"/>.</summary>
    public decimal GetRateToBase(string currency, DateOnly date) =>
        TryGetRate(currency, date, out var rate, out _) ? rate : throw new ExchangeRateNotFoundException(currency);

    public bool TryGetRate(string currency, DateOnly date, out decimal rate, out DateOnly rateDate)
    {
        if (currency == Currency.BaseCode)
        {
            rate = 1m;
            rateDate = date;
            return true;
        }

        if (!_series.TryGetValue(currency, out var series))
        {
            rate = 0;
            rateDate = default;
            return false;
        }

        var index = Array.BinarySearch(series.Dates, date);
        if (index < 0)
        {
            // ~index is the first element greater than date; the previous one is the closest earlier rate.
            index = ~index - 1;
            if (index < 0)
            {
                index = 0;
            }
        }

        rate = series.Rates[index];
        rateDate = series.Dates[index];
        return true;
    }

    /// <summary>Latest known rate per currency on or before <paramref name="date"/>.</summary>
    public IReadOnlyList<ExchangeRatePoint> RatesOn(DateOnly date) =>
        _series.Keys
            .Order(StringComparer.Ordinal)
            .Select(code =>
            {
                TryGetRate(code, date, out var rate, out var rateDate);
                return new ExchangeRatePoint(code, rateDate, rate);
            })
            .ToList();

    /// <summary>Converts through BYN using the rates applicable on <paramref name="date"/>. Rounds once, at the end.</summary>
    public Money Convert(Money money, Currency target, DateOnly date)
    {
        if (money.Currency == target)
        {
            return money;
        }

        var inBase = money.ToDecimal() * GetRateToBase(money.Currency.Code, date);
        var inTarget = inBase / GetRateToBase(target.Code, date);
        return Money.FromDecimal(inTarget, target);
    }

    /// <summary>Drops trailing zeros that come from the fixed database scale (0.80907000000000 → 0.80907).</summary>
    private static decimal Normalize(decimal value) => value / 1.000000000000000000000000000000000m;

    private sealed record Series(DateOnly[] Dates, decimal[] Rates);
}
