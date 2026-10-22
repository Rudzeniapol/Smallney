using Finance.Domain.ExchangeRates;
using Finance.Domain.Monetary;

namespace Finance.Application.Abstractions;

/// <summary>Cached access to the full rate history.</summary>
public interface IExchangeRateProvider
{
    Task<ExchangeRateTable> GetTableAsync(CancellationToken cancellationToken = default);

    /// <summary>Drops the cache after new rates were stored.</summary>
    void Invalidate();
}

public interface ICurrencyConverter
{
    /// <summary>Converts through BYN using the closest rate on or before <paramref name="date"/>.</summary>
    Task<Money> ConvertAsync(Money money, Currency target, DateOnly date, CancellationToken cancellationToken = default);
}
