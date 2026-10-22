using Finance.Application.Abstractions;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Monetary;
using Finance.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Infrastructure.ExchangeRates;

/// <summary>Keeps the whole (small) rate history in memory; refreshed after imports and hourly.</summary>
internal sealed class ExchangeRateProvider(IServiceScopeFactory scopes, IMemoryCache cache) : IExchangeRateProvider
{
    private const string CacheKey = "exchange-rate-table";

    public async Task<ExchangeRateTable> GetTableAsync(CancellationToken cancellationToken = default) =>
        (await cache.GetOrCreateAsync(CacheKey, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1);
            await using var scope = scopes.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var points = await db.ExchangeRates
                .AsNoTracking()
                .Where(r => r.ToCurrency == Currency.BaseCode)
                .Select(r => new ExchangeRatePoint(r.FromCurrency, r.Date, r.Rate))
                .ToListAsync(cancellationToken);
            return new ExchangeRateTable(points);
        }))!;

    public void Invalidate() => cache.Remove(CacheKey);
}

internal sealed class CurrencyConverter(IExchangeRateProvider provider) : ICurrencyConverter
{
    public async Task<Money> ConvertAsync(Money money, Currency target, DateOnly date, CancellationToken cancellationToken = default)
    {
        if (money.Currency == target)
        {
            return money;
        }

        var table = await provider.GetTableAsync(cancellationToken);
        return table.Convert(money, target, date);
    }
}
