using Finance.Domain.ExchangeRates;
using Finance.Domain.Monetary;

namespace Finance.Tests.Unit.Domain;

public class ExchangeRateTableTests
{
    private static readonly Currency Byn = Currency.Byn;
    private static readonly Currency Usd = Currency.FromCode("USD");
    private static readonly Currency Eur = Currency.FromCode("EUR");
    private static readonly Currency Jpy = Currency.FromCode("JPY");

    private static readonly ExchangeRateTable Table = new(
    [
        new("USD", new DateOnly(2026, 1, 10), 3.0m),
        new("USD", new DateOnly(2026, 1, 12), 3.2m),
        new("EUR", new DateOnly(2026, 1, 10), 3.5m),
        new("JPY", new DateOnly(2026, 1, 10), ExchangeRate.PerUnit(2.0123m, 100)),
    ]);

    [Fact]
    public void Uses_the_rate_of_the_exact_date()
    {
        Table.GetRateToBase("USD", new DateOnly(2026, 1, 12)).Should().Be(3.2m);
    }

    [Fact]
    public void Uses_the_closest_previous_rate_when_the_date_has_none()
    {
        Table.GetRateToBase("USD", new DateOnly(2026, 1, 11)).Should().Be(3.0m);
        Table.GetRateToBase("USD", new DateOnly(2026, 6, 1)).Should().Be(3.2m);
    }

    [Fact]
    public void Falls_back_to_the_earliest_rate_before_history_starts()
    {
        Table.TryGetRate("USD", new DateOnly(2025, 1, 1), out var rate, out var rateDate).Should().BeTrue();
        rate.Should().Be(3.0m);
        rateDate.Should().Be(new DateOnly(2026, 1, 10));
    }

    [Fact]
    public void Base_currency_rate_is_one()
    {
        Table.GetRateToBase("BYN", new DateOnly(2000, 1, 1)).Should().Be(1m);
    }

    [Fact]
    public void Unknown_currency_throws()
    {
        var act = () => Table.GetRateToBase("GBP", new DateOnly(2026, 1, 10));
        act.Should().Throw<ExchangeRateNotFoundException>().Which.Code.Should().Be("exchange_rate_not_found");
    }

    [Fact]
    public void Converts_to_byn()
    {
        Table.Convert(new Money(10000, Usd), Byn, new DateOnly(2026, 1, 12)).Should().Be(new Money(32000, Byn));
    }

    [Fact]
    public void Converts_from_byn()
    {
        // 100 BYN / 3.0 = 33.333… USD → 33.33
        Table.Convert(new Money(10000, Byn), Usd, new DateOnly(2026, 1, 10)).Should().Be(new Money(3333, Usd));
    }

    [Fact]
    public void Cross_rates_go_through_byn_and_round_once()
    {
        // 100 USD * 3.0 = 300 BYN; 300 / 3.5 = 85.714… EUR → 85.71
        Table.Convert(new Money(10000, Usd), Eur, new DateOnly(2026, 1, 10)).Should().Be(new Money(8571, Eur));
    }

    [Fact]
    public void Respects_nbrb_scale()
    {
        // 2.0123 BYN per 100 JPY → 10 000 JPY = 201.23 BYN
        Table.Convert(new Money(10000, Jpy), Byn, new DateOnly(2026, 1, 10)).Should().Be(new Money(20123, Byn));
    }

    [Fact]
    public void Same_currency_is_returned_unchanged_even_without_rates()
    {
        var money = new Money(123, Currency.FromCode("GBP"));
        ExchangeRateTable.Empty.Convert(money, money.Currency, new DateOnly(2026, 1, 1)).Should().Be(money);
    }

    [Fact]
    public void RatesOn_returns_latest_rate_per_currency()
    {
        var rates = Table.RatesOn(new DateOnly(2026, 1, 11));

        rates.Select(r => r.Currency).Should().Equal("EUR", "JPY", "USD");
        rates.Single(r => r.Currency == "USD").Should().Be(new ExchangeRatePoint("USD", new DateOnly(2026, 1, 10), 3.0m));
        Table.Currencies.Should().HaveCount(3);
    }

    [Fact]
    public void Duplicate_dates_keep_the_last_value()
    {
        var table = new ExchangeRateTable(
        [
            new("USD", new DateOnly(2026, 1, 10), 3.0m),
            new("USD", new DateOnly(2026, 1, 10), 3.1m),
        ]);

        table.GetRateToBase("USD", new DateOnly(2026, 1, 10)).Should().Be(3.1m);
    }

    [Theory]
    [InlineData("3.2150", 1, "3.2150")]
    [InlineData("2.0123", 100, "0.020123")]
    [InlineData("8.2335", 1000, "0.0082335")]
    public void PerUnit_divides_out_the_scale(string official, int scale, string expected)
    {
        var inv = System.Globalization.CultureInfo.InvariantCulture;
        ExchangeRate.PerUnit(decimal.Parse(official, inv), scale).Should().Be(decimal.Parse(expected, inv));
    }

    [Fact]
    public void PerUnit_rejects_invalid_input()
    {
        ((Action)(() => ExchangeRate.PerUnit(1m, 0))).Should().Throw<ArgumentOutOfRangeException>();
        ((Action)(() => ExchangeRate.PerUnit(0m, 1))).Should().Throw<ArgumentOutOfRangeException>();
    }
}

public class ExchangeRateNormalizationTests
{
    [Fact]
    public void Trailing_zeros_from_the_database_scale_are_dropped()
    {
        var table = new ExchangeRateTable([new("AED", new DateOnly(2026, 10, 22), 0.80907000000000m)]);

        table.GetRateToBase("AED", new DateOnly(2026, 10, 22)).ToString(System.Globalization.CultureInfo.InvariantCulture)
            .Should().Be("0.80907");
    }
}
