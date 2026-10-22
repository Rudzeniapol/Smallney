using Finance.Domain.Common;
using Finance.Domain.Monetary;

namespace Finance.Domain.Accounts;

/// <summary>
/// A place where money is kept. The balance is never stored: it is
/// <c>InitialBalance + Σ cleared transactions</c> (see <see cref="BalanceCalculator"/>).
/// </summary>
public sealed class Account : UserOwnedEntity
{
    public string Name { get; set; } = string.Empty;

    public AccountType Type { get; set; }

    public string Currency { get; set; } = Monetary.Currency.BaseCode;

    /// <summary>Minor units of <see cref="Currency"/>. May be negative (e.g. existing credit card debt).</summary>
    public long InitialBalance { get; set; }

    public bool IncludeInTotals { get; set; } = true;

    public bool IsArchived { get; set; }

    public int SortOrder { get; set; }

    public string? Color { get; set; }

    public string? Icon { get; set; }

    /// <summary>CreditCard only. Minor units, non-negative.</summary>
    public long? CreditLimit { get; set; }

    /// <summary>Deposit/Savings only. Annual nominal rate in percent, e.g. 12.5.</summary>
    public decimal? InterestRatePercent { get; set; }

    public CapitalizationPeriod? CapitalizationPeriod { get; set; }

    public DateOnly? OpenDate { get; set; }

    public DateOnly? MaturityDate { get; set; }

    public static bool SupportsInterest(AccountType type) => type is AccountType.Deposit or AccountType.Savings;

    public Money InitialMoney => new(InitialBalance, Monetary.Currency.FromCode(Currency));
}
