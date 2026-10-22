using System.Globalization;
using System.Net.Http.Json;
using System.Text.Json.Serialization;

namespace Finance.Infrastructure.ExchangeRates;

/// <summary>An official NBRB rate: <see cref="OfficialRate"/> BYN for <see cref="Scale"/> units of the currency.</summary>
public sealed record NbrbRate(string Currency, DateOnly Date, int Scale, decimal OfficialRate);

public interface INbrbClient
{
    /// <summary>Daily rates (periodicity=0) for <paramref name="onDate"/>, or for today when null.</summary>
    Task<IReadOnlyList<NbrbRate>> GetDailyRatesAsync(DateOnly? onDate, CancellationToken ct);
}

internal sealed class NbrbClient(HttpClient http) : INbrbClient
{
    public async Task<IReadOnlyList<NbrbRate>> GetDailyRatesAsync(DateOnly? onDate, CancellationToken ct)
    {
        var url = "exrates/rates?periodicity=0";
        if (onDate is { } date)
        {
            url += "&ondate=" + date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }

        var items = await http.GetFromJsonAsync<List<NbrbRateDto>>(url, ct) ?? [];
        return items
            .Where(i => !string.IsNullOrWhiteSpace(i.Abbreviation) && i.Scale > 0 && i.OfficialRate > 0)
            .Select(i => new NbrbRate(i.Abbreviation!.Trim().ToUpperInvariant(), DateOnly.FromDateTime(i.Date), i.Scale, i.OfficialRate))
            .ToList();
    }

    private sealed record NbrbRateDto(
        [property: JsonPropertyName("Cur_Abbreviation")] string? Abbreviation,
        [property: JsonPropertyName("Date")] DateTime Date,
        [property: JsonPropertyName("Cur_Scale")] int Scale,
        [property: JsonPropertyName("Cur_OfficialRate")] decimal OfficialRate);
}
