using Finance.Application.Abstractions;
using Finance.Application.Features.Rates;
using Finance.Domain.Monetary;
using Finance.Infrastructure.ExchangeRates;
using Finance.Infrastructure.Persistence;
using Finance.Tests.Integration.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Tests.Integration.Features;

public class ExchangeRatesTests(ApiFactory factory)
{
    // Old dates and currencies no other test uses, so global rate data stays deterministic.
    private static readonly DateOnly Day1 = new(2011, 3, 1);
    private static readonly DateOnly Day2 = new(2011, 3, 2);

    [Fact]
    public async Task Job_stores_per_unit_rates_and_is_idempotent()
    {
        factory.Nbrb.SetRatesFor(Day1, new NbrbRate("CHF", Day1, 1, 3.3m), new NbrbRate("ISK", Day1, 100, 2.4m));
        factory.Nbrb.SetRatesFor(Day2, new NbrbRate("CHF", Day2, 1, 3.4m), new NbrbRate("ISK", Day2, 100, 2.5m));

        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var job = scope.ServiceProvider.GetRequiredService<ExchangeRatesJob>();
            (await job.LoadAsync(Day1, CancellationToken.None)).Should().Be(2);
            (await job.LoadAsync(Day1, CancellationToken.None)).Should().Be(2);
            await job.LoadAsync(Day2, CancellationToken.None);
        }

        await using (var scope = factory.Services.CreateAsyncScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var stored = await db.ExchangeRates.Where(r => r.Date == Day1).OrderBy(r => r.FromCurrency).ToListAsync();
            stored.Select(r => (r.FromCurrency, r.ToCurrency, r.Rate, r.Source))
                .Should().Equal(("CHF", "BYN", 3.3m, "NBRB"), ("ISK", "BYN", 0.024m, "NBRB"));

            var converter = scope.ServiceProvider.GetRequiredService<ICurrencyConverter>();
            var isk = Currency.FromCode("ISK");
            var chf = Currency.FromCode("CHF");

            // 10 000 ISK * 0.024 = 240 BYN; on a later date without rates the latest earlier rate (Day2) is used.
            (await converter.ConvertAsync(new Money(10_000, isk), Currency.Byn, Day1)).Should().Be(new Money(24_000, Currency.Byn));
            (await converter.ConvertAsync(new Money(10_000, isk), Currency.Byn, Day2.AddDays(1))).Should().Be(new Money(25_000, Currency.Byn));
            // Cross rate through BYN: 100 CHF * 3.4 / 0.025 = 13 600 ISK.
            (await converter.ConvertAsync(new Money(10_000, chf), isk, Day2)).Should().Be(new Money(13_600, isk));
        }
    }

    [Fact]
    public async Task Backfill_only_requests_missing_days()
    {
        await using var scope = factory.Services.CreateAsyncScope();
        var job = scope.ServiceProvider.GetRequiredService<ExchangeRatesJob>();
        var today = job.NbrbToday;
        var yesterday = today.AddDays(-1);
        factory.Nbrb.SetRatesFor(yesterday, new NbrbRate("MDL", yesterday, 10, 1.8m));
        factory.Nbrb.SetRatesFor(today, new NbrbRate("MDL", today, 10, 1.9m));

        await job.BackfillDaysAsync(1, CancellationToken.None);
        var requestsAfterFirst = factory.Nbrb.Requests.Count;
        await job.BackfillDaysAsync(1, CancellationToken.None);

        factory.Nbrb.Requests.Count.Should().Be(requestsAfterFirst, "both days are stored now");
        (await job.HasRatesForTodayAsync(CancellationToken.None)).Should().BeTrue();
    }

    [Fact]
    public async Task Rates_endpoint_returns_latest_rate_on_or_before_the_date()
    {
        await Job_stores_per_unit_rates_and_is_idempotent();
        var user = await factory.RegisterUserAsync();

        var response = await user.GetAsync<RatesResponse>("/api/v1/rates?date=2011-03-05");

        response.BaseCurrency.Should().Be("BYN");
        response.Rates.Should().Contain(new RateResponse("ISK", 0.025m, Day2));
        response.Rates.Should().Contain(new RateResponse("CHF", 3.4m, Day2));
    }
}
