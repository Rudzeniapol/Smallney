using Finance.Domain.Common;

namespace Finance.Domain.Monetary;

/// <summary>
/// An amount of money in integer minor units (e.g. kopecks) of a given currency.
/// This is the only place where decimal values are turned into minor units.
/// </summary>
public readonly record struct Money(long Amount, Currency Currency) : IComparable<Money>
{
    public const MidpointRounding Rounding = MidpointRounding.ToEven;

    public static Money Zero(Currency currency) => new(0, currency);

    public static Money Of(long amount, string currencyCode) => new(amount, Currency.FromCode(currencyCode));

    /// <summary>Converts a major-unit decimal value (e.g. 12.345 BYN) to minor units using banker's rounding.</summary>
    public static Money FromDecimal(decimal value, Currency currency)
    {
        try
        {
            var minor = decimal.Round(value * currency.MinorUnitFactor, 0, Rounding);
            if (minor is >= long.MinValue and <= long.MaxValue)
            {
                return new Money((long)minor, currency);
            }
        }
        catch (OverflowException)
        {
            // Reported below.
        }

        throw new DomainException("money_overflow", $"Amount {value} {currency} does not fit into minor units.");
    }

    /// <summary>The value in major units, exact.</summary>
    public decimal ToDecimal() => Amount / Currency.MinorUnitFactor;

    public bool IsZero => Amount == 0;

    public bool IsNegative => Amount < 0;

    public Money Abs() => this with { Amount = Math.Abs(Amount) };

    public Money Negate() => this with { Amount = -Amount };

    /// <summary>Multiplies by a decimal factor (rate, percentage, ...) and rounds once.</summary>
    public Money Multiply(decimal factor) => FromDecimal(ToDecimal() * factor, Currency);

    /// <summary>
    /// Splits the amount into <paramref name="parts"/> parts that sum exactly to the original amount.
    /// The remainder goes to the first parts, one minor unit each.
    /// </summary>
    public Money[] Allocate(int parts)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(parts);
        var share = Amount / parts;
        var remainder = Amount % parts;
        var sign = Math.Sign(remainder);
        var result = new Money[parts];
        for (var i = 0; i < parts; i++)
        {
            result[i] = this with { Amount = share + (i < Math.Abs(remainder) ? sign : 0) };
        }

        return result;
    }

    public int CompareTo(Money other)
    {
        EnsureSameCurrency(this, other);
        return Amount.CompareTo(other.Amount);
    }

    public static Money operator +(Money left, Money right)
    {
        EnsureSameCurrency(left, right);
        return left with { Amount = checked(left.Amount + right.Amount) };
    }

    public static Money operator -(Money left, Money right)
    {
        EnsureSameCurrency(left, right);
        return left with { Amount = checked(left.Amount - right.Amount) };
    }

    public static Money operator -(Money money) => money.Negate();

    public static bool operator <(Money left, Money right) => left.CompareTo(right) < 0;

    public static bool operator >(Money left, Money right) => left.CompareTo(right) > 0;

    public static bool operator <=(Money left, Money right) => left.CompareTo(right) <= 0;

    public static bool operator >=(Money left, Money right) => left.CompareTo(right) >= 0;

    public override string ToString() =>
        $"{ToDecimal().ToString($"F{Currency.MinorUnitDigits}", System.Globalization.CultureInfo.InvariantCulture)} {Currency}";

    private static void EnsureSameCurrency(Money left, Money right)
    {
        if (left.Currency != right.Currency)
        {
            throw new DomainException(
                "currency_mismatch",
                $"Cannot combine {left.Currency} and {right.Currency} without conversion.");
        }
    }
}
