using Finance.Domain.Common;
using Finance.Domain.Monetary;

namespace Finance.Tests.Unit.Domain;

public class MoneyTests
{
    private static readonly Currency Byn = Currency.FromCode("BYN");
    private static readonly Currency Usd = Currency.FromCode("USD");

    [Theory]
    [InlineData("2.345", 234)] // midpoint → even
    [InlineData("2.355", 236)] // midpoint → even
    [InlineData("2.3451", 235)]
    [InlineData("-2.345", -234)]
    [InlineData("-2.355", -236)]
    [InlineData("0.005", 0)]
    [InlineData("0.015", 2)]
    [InlineData("12480.35", 1248035)]
    public void FromDecimal_rounds_half_to_even(string value, long expectedMinor)
    {
        Money.FromDecimal(decimal.Parse(value, System.Globalization.CultureInfo.InvariantCulture), Byn)
            .Should().Be(new Money(expectedMinor, Byn));
    }

    [Fact]
    public void FromDecimal_respects_currency_exponent()
    {
        Money.FromDecimal(1234.5m, Currency.FromCode("JPY")).Amount.Should().Be(1234); // 0 digits, .5 → even
        Money.FromDecimal(1235.5m, Currency.FromCode("JPY")).Amount.Should().Be(1236);
        Money.FromDecimal(1.2345m, Currency.FromCode("KWD")).Amount.Should().Be(1234); // 3 digits
    }

    [Fact]
    public void FromDecimal_throws_on_overflow()
    {
        var act = () => Money.FromDecimal(decimal.MaxValue / 10, Byn);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("money_overflow");
    }

    [Fact]
    public void ToDecimal_is_exact()
    {
        new Money(1248035, Byn).ToDecimal().Should().Be(12480.35m);
        new Money(-999, Usd).ToDecimal().Should().Be(-9.99m);
        new Money(1500, Currency.FromCode("JPY")).ToDecimal().Should().Be(1500m);
    }

    [Fact]
    public void Arithmetic_works_within_one_currency()
    {
        var a = new Money(1000, Byn);
        var b = new Money(250, Byn);

        (a + b).Should().Be(new Money(1250, Byn));
        (a - b).Should().Be(new Money(750, Byn));
        (-a).Should().Be(new Money(-1000, Byn));
        new Money(-5, Byn).Abs().Should().Be(new Money(5, Byn));
        (a > b).Should().BeTrue();
        (b < a).Should().BeTrue();
        (a >= new Money(1000, Byn)).Should().BeTrue();
        (b <= a).Should().BeTrue();
        a.IsZero.Should().BeFalse();
        Money.Zero(Byn).IsZero.Should().BeTrue();
        (-a).IsNegative.Should().BeTrue();
    }

    [Fact]
    public void Mixing_currencies_throws()
    {
        var act = () => new Money(1, Byn) + new Money(1, Usd);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("currency_mismatch");

        var compare = () => new Money(1, Byn) < new Money(1, Usd);
        compare.Should().Throw<DomainException>();
    }

    [Fact]
    public void Addition_overflow_is_detected()
    {
        var act = () => new Money(long.MaxValue, Byn) + new Money(1, Byn);
        act.Should().Throw<OverflowException>();
    }

    [Theory]
    [InlineData(1000, "0.1", 100)]
    [InlineData(1005, "0.5", 502)] // 5.025 → 5.02 (even)
    [InlineData(1015, "0.5", 508)] // 5.075 → 5.08 (even)
    public void Multiply_rounds_once(long amount, string factor, long expected)
    {
        new Money(amount, Byn).Multiply(decimal.Parse(factor, System.Globalization.CultureInfo.InvariantCulture))
            .Amount.Should().Be(expected);
    }

    [Theory]
    [InlineData(1000, 3, new long[] { 334, 333, 333 })]
    [InlineData(-1000, 3, new long[] { -334, -333, -333 })]
    [InlineData(2, 5, new long[] { 1, 1, 0, 0, 0 })]
    [InlineData(0, 2, new long[] { 0, 0 })]
    public void Allocate_splits_without_losing_minor_units(long amount, int parts, long[] expected)
    {
        var result = new Money(amount, Byn).Allocate(parts);

        result.Select(m => m.Amount).Should().Equal(expected);
        result.Sum(m => m.Amount).Should().Be(amount);
    }

    [Fact]
    public void Allocate_rejects_non_positive_parts()
    {
        var act = () => new Money(1, Byn).Allocate(0);
        act.Should().Throw<ArgumentOutOfRangeException>();
    }

    [Fact]
    public void ToString_uses_major_units()
    {
        new Money(1248035, Byn).ToString().Should().Be("12480.35 BYN");
        new Money(5, Currency.FromCode("KWD")).ToString().Should().Be("0.005 KWD");
    }

    [Fact]
    public void Of_parses_currency_code()
    {
        Money.Of(100, "EUR").Currency.Code.Should().Be("EUR");
    }
}
