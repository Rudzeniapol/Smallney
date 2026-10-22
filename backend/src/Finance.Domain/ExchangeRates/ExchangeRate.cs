namespace Finance.Domain.ExchangeRates;

/// <summary>
/// Official rate of one unit of <see cref="FromCurrency"/> in <see cref="ToCurrency"/> (always BYN).
/// Global reference data, not owned by a user.
/// </summary>
public sealed class ExchangeRate
{
    public const string NbrbSource = "NBRB";

    /// <summary>Official rates are set for Minsk calendar dates.</summary>
    public const string NbrbTimezone = "Europe/Minsk";

    public DateOnly Date { get; set; }

    public string FromCurrency { get; set; } = string.Empty;

    public string ToCurrency { get; set; } = Monetary.Currency.BaseCode;

    /// <summary>BYN per ONE unit of <see cref="FromCurrency"/> (the NBRB scale is already divided out).</summary>
    public decimal Rate { get; set; }

    public string Source { get; set; } = NbrbSource;

    public DateTime FetchedAt { get; set; }

    /// <summary>
    /// NBRB publishes "Cur_OfficialRate BYN for Cur_Scale units" (e.g. 2.0123 BYN per 100 JPY).
    /// We store the per-unit rate.
    /// </summary>
    public static decimal PerUnit(decimal officialRate, int scale)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(scale);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(officialRate);
        return officialRate / scale;
    }
}
