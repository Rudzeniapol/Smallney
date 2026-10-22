using Finance.Domain.Common;

namespace Finance.Domain.ExchangeRates;

public sealed class ExchangeRateNotFoundException(string currency)
    : DomainException("exchange_rate_not_found", $"No exchange rate is known for currency '{currency}'.")
{
    public string Currency { get; } = currency;
}
