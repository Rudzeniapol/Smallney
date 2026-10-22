using Finance.Domain.Common;
using Finance.Domain.Monetary;

namespace Finance.Tests.Unit.Domain;

public class CurrencyTests
{
    [Theory]
    [InlineData("BYN", 2)]
    [InlineData("USD", 2)]
    [InlineData("EUR", 2)]
    [InlineData("RUB", 2)]
    [InlineData("JPY", 0)]
    [InlineData("KRW", 0)]
    [InlineData("KWD", 3)]
    [InlineData("BHD", 3)]
    public void Knows_minor_unit_digits(string code, int digits)
    {
        var currency = Currency.FromCode(code);

        currency.Code.Should().Be(code);
        currency.MinorUnitDigits.Should().Be(digits);
        currency.MinorUnitFactor.Should().Be((decimal)Math.Pow(10, digits));
    }

    [Theory]
    [InlineData("byn")]
    [InlineData("XXX")]
    [InlineData("")]
    [InlineData(null)]
    public void Rejects_unknown_codes(string? code)
    {
        Currency.IsSupported(code).Should().BeFalse();
        Currency.TryFromCode(code, out _).Should().BeFalse();
    }

    [Fact]
    public void FromCode_throws_domain_exception_for_unknown_code()
    {
        var act = () => Currency.FromCode("ABC");
        act.Should().Throw<DomainException>().Which.Code.Should().Be("unsupported_currency");
    }

    [Fact]
    public void Byn_is_the_base_currency()
    {
        Currency.Byn.Should().Be(Currency.FromCode(Currency.BaseCode));
        Currency.Byn.ToString().Should().Be("BYN");
        Currency.SupportedCodes.Should().Contain(["BYN", "USD", "EUR", "RUB", "PLN", "CNY"]);
    }
}
