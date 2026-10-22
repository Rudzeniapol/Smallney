using Finance.Application.Abstractions;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Users;
using Finance.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Finance.Infrastructure.ExchangeRates;

/// <summary>Loads official NBRB rates into <c>exchange_rates</c>. Every method is idempotent.</summary>
public sealed class ExchangeRatesJob(
    AppDbContext db,
    INbrbClient nbrb,
    IExchangeRateProvider cache,
    TimeProvider clock,
    ILogger<ExchangeRatesJob> logger)
{
    public DateOnly NbrbToday => UserClock.LocalDate(ExchangeRate.NbrbTimezone, clock.GetUtcNow());

    /// <summary>Hangfire entry point: today's rates.</summary>
    public Task LoadLatestAsync(CancellationToken ct) => LoadAsync(onDate: null, ct);

    /// <summary>Hangfire entry point: rates for every day of the last <paramref name="days"/> days that is not stored yet.</summary>
    public Task BackfillAsync(int days, CancellationToken ct) => BackfillDaysAsync(days, ct);

    public async Task<int> BackfillDaysAsync(int days, CancellationToken ct)
    {
        var today = NbrbToday;
        var from = today.AddDays(-days);
        var known = (await db.ExchangeRates
                .Where(r => r.Date >= from)
                .Select(r => r.Date)
                .Distinct()
                .ToListAsync(ct))
            .ToHashSet();

        var stored = 0;
        for (var date = from; date <= today; date = date.AddDays(1))
        {
            if (!known.Contains(date))
            {
                stored += await LoadAsync(date, ct);
            }
        }

        return stored;
    }

    public async Task<int> LoadAsync(DateOnly? onDate, CancellationToken ct)
    {
        var rates = await nbrb.GetDailyRatesAsync(onDate, ct);
        if (rates.Count == 0)
        {
            logger.LogWarning("NBRB returned no rates for {Date}", onDate?.ToString("O") ?? "today");
            return 0;
        }

        var dates = rates.Select(r => r.Date).Distinct().ToList();
        var existing = await db.ExchangeRates
            .Where(r => dates.Contains(r.Date))
            .ToDictionaryAsync(r => (r.FromCurrency, r.Date), ct);

        var now = clock.GetUtcNow().UtcDateTime;
        foreach (var rate in rates)
        {
            var perUnit = ExchangeRate.PerUnit(rate.OfficialRate, rate.Scale);
            if (existing.TryGetValue((rate.Currency, rate.Date), out var row))
            {
                row.Rate = perUnit;
                row.FetchedAt = now;
            }
            else
            {
                db.ExchangeRates.Add(new ExchangeRate
                {
                    Date = rate.Date,
                    FromCurrency = rate.Currency,
                    Rate = perUnit,
                    Source = ExchangeRate.NbrbSource,
                    FetchedAt = now,
                });
            }
        }

        await db.SaveChangesAsync(ct);
        cache.Invalidate();
        logger.LogInformation("Stored {Count} NBRB rates for {Dates}", rates.Count, string.Join(", ", dates.Select(d => d.ToString("O"))));
        return rates.Count;
    }

    public Task<bool> HasRatesForTodayAsync(CancellationToken ct)
    {
        var today = NbrbToday;
        return db.ExchangeRates.AnyAsync(r => r.Date == today, ct);
    }
}
