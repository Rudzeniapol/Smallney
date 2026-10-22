using Finance.Domain.Monetary;

namespace Finance.Application.Common;

/// <summary>Money on the wire: integer minor units plus ISO 4217 code.</summary>
public sealed record MoneyDto(long Amount, string Currency)
{
    public static MoneyDto From(Money money) => new(money.Amount, money.Currency.Code);
}
