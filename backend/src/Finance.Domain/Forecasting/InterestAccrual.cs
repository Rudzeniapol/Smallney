using Finance.Domain.Accounts;
using Finance.Domain.Monetary;
using Finance.Domain.Recurring;

namespace Finance.Domain.Forecasting;

/// <summary>
/// Interest of a deposit or savings account, day count actual/365.
/// <list type="bullet">
/// <item>Monthly / Quarterly: compound — interest accrues daily on the whole balance and is added to it
/// every 1 / 3 months from OpenDate.</item>
/// <item>None: simple — accrues daily on the balance without interest earned during the forecast,
/// paid out monthly from OpenDate and never compounded.</item>
/// <item>AtEnd: simple, paid at MaturityDate (yearly from OpenDate when there is no maturity date).</item>
/// </list>
/// Nothing accrues before OpenDate or from MaturityDate on; the remainder is paid on MaturityDate.
/// Interest for the part of the current period before today is estimated on today's balance.
/// </summary>
public sealed class InterestAccrual
{
    public const decimal DaysInYear = 365m;

    private readonly ForecastAccount _account;
    private readonly Currency _currency;
    private readonly decimal _dailyRate;
    private readonly HashSet<DateOnly> _creditDates;
    private readonly bool _compound;
    private decimal _accrued;
    private long _paidDuringForecast;

    private InterestAccrual(ForecastAccount account, DateOnly today, DateOnly end)
    {
        _account = account;
        _currency = Currency.FromCode(account.Currency);
        _dailyRate = account.InterestRatePercent!.Value / 100m / DaysInYear;
        _compound = account.Capitalization is CapitalizationPeriod.Monthly or CapitalizationPeriod.Quarterly;

        var open = account.OpenDate!.Value;
        var schedule = CreditSchedule(account.Capitalization!.Value, open, account.MaturityDate);
        var credits = schedule.Occurrences(open.AddDays(1), end).ToList();
        if (account.MaturityDate is { } maturity && maturity > open && maturity <= end)
        {
            credits.Add(maturity);
        }

        _creditDates = credits.Where(d => d >= today).ToHashSet();

        // The current period started at the last credit date (or OpenDate) before today.
        var periodStart = schedule.Occurrences(open.AddDays(1), today.AddDays(-1)).Cast<DateOnly?>().LastOrDefault() ?? open;
        var lastAccrualDay = account.MaturityDate is { } m && m <= today ? m : today;
        var accruedDays = lastAccrualDay.DayNumber - periodStart.DayNumber;
        if (accruedDays > 0 && today > open)
        {
            _accrued = DailyInterest(account.StartBalance) * accruedDays;
        }
    }

    public Guid AccountId => _account.Id;

    /// <summary>Null when the account does not earn interest.</summary>
    public static InterestAccrual? For(ForecastAccount account, DateOnly today, DateOnly end) =>
        account is { InterestRatePercent: > 0, Capitalization: not null, OpenDate: not null }
        && Account.SupportsInterest(account.Type)
        && (account.MaturityDate is null || account.MaturityDate >= today)
            ? new InterestAccrual(account, today, end)
            : null;

    /// <summary>Interest to credit at the start of <paramref name="date"/> (0 on other days).</summary>
    public long CreditDue(DateOnly date)
    {
        if (!_creditDates.Contains(date) || _accrued <= 0)
        {
            return 0;
        }

        var credit = Money.FromDecimal(_accrued, _currency).Amount;
        _accrued = 0;
        _paidDuringForecast += credit;
        return credit;
    }

    /// <summary>Accrues one day of interest on the end-of-day <paramref name="balance"/>.</summary>
    public void AccrueDay(DateOnly date, long balance)
    {
        if (date < _account.OpenDate || (_account.MaturityDate is { } maturity && date >= maturity))
        {
            return;
        }

        var basis = _compound ? balance : balance - _paidDuringForecast;
        _accrued += DailyInterest(basis);
    }

    private decimal DailyInterest(long balance) =>
        balance <= 0 ? 0 : new Money(balance, _currency).ToDecimal() * _dailyRate;

    private static RecurrenceSchedule CreditSchedule(CapitalizationPeriod period, DateOnly open, DateOnly? maturity) =>
        period switch
        {
            CapitalizationPeriod.Quarterly => new RecurrenceSchedule(Frequency.Monthly, 3, open, maturity),
            CapitalizationPeriod.AtEnd when maturity is not null => new RecurrenceSchedule(Frequency.Yearly, 1, open, open),
            CapitalizationPeriod.AtEnd => new RecurrenceSchedule(Frequency.Yearly, 1, open),
            _ => new RecurrenceSchedule(Frequency.Monthly, 1, open, maturity),
        };
}
