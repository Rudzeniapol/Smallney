using Finance.Application.Abstractions;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Monetary;
using Finance.Domain.Users;

namespace Finance.Application.Features.Rates;

public sealed record RateResponse(string Currency, decimal Rate, DateOnly Date);

/// <summary>Rates are BYN per one unit of <c>currency</c>, the latest known on or before <c>date</c>.</summary>
public sealed record RatesResponse(string BaseCurrency, DateOnly Date, IReadOnlyList<RateResponse> Rates);

public sealed class RatesQueries(IExchangeRateProvider provider, TimeProvider clock)
{
    public async Task<RatesResponse> GetAsync(DateOnly? date, CancellationToken ct)
    {
        var table = await provider.GetTableAsync(ct);
        var on = date ?? UserClock.LocalDate(ExchangeRate.NbrbTimezone, clock.GetUtcNow());
        var rates = table.RatesOn(on).Select(p => new RateResponse(p.Currency, p.RateToBase, p.Date)).ToList();
        return new RatesResponse(Currency.BaseCode, on, rates);
    }
}
