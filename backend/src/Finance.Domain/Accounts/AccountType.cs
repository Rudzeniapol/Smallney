namespace Finance.Domain.Accounts;

public enum AccountType
{
    Cash,
    DebitCard,
    CreditCard,
    Savings,
    Deposit,
    Investment,
}

public enum CapitalizationPeriod
{
    /// <summary>Simple interest, paid out (or accrued) without compounding.</summary>
    None,
    Monthly,
    Quarterly,

    /// <summary>Simple interest paid at maturity.</summary>
    AtEnd,
}
