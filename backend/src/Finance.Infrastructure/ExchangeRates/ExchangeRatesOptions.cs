namespace Finance.Infrastructure.ExchangeRates;

public sealed class ExchangeRatesOptions
{
    public const string SectionName = "ExchangeRates";

    public string NbrbBaseUrl { get; set; } = "https://api.nbrb.by/";

    /// <summary>Cron (UTC) of the recurring import. Idempotent, so running it several times a day is safe.</summary>
    public string Cron { get; set; } = "15 */6 * * *";

    /// <summary>On startup, load missing daily rates for this many past days (0 = off).</summary>
    public int BackfillDays { get; set; } = 30;
}
