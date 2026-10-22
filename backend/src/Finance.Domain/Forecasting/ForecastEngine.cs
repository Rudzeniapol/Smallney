using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Goals;
using Finance.Domain.Monetary;

namespace Finance.Domain.Forecasting;

/// <summary>
/// Deterministic day-by-day balance simulation. Starting from today's balances it applies, per day:
/// interest credited that day, the day's flows (scheduled, planned, recurring, variable spending spread evenly
/// over its days and charged to the spending account, what-if operations), then accrues the day's interest.
/// Totals and alarms use the base currency at the latest known rate.
/// </summary>
public static class ForecastEngine
{
    public const int MaxHorizonMonths = 24;

    public static DateOnly MaxEnd(DateOnly today) => today.AddMonths(MaxHorizonMonths);

    public static ForecastResult Run(ForecastInput input)
    {
        var today = input.Today;
        var from = input.From < today ? today : input.From;
        var to = input.To;
        var end = SimulationEnd(input);

        var accounts = input.Accounts.ToDictionary(a => a.Id);
        var balances = input.Accounts.ToDictionary(a => a.Id, a => a.StartBalance);
        var interest = input.Accounts
            .Select(a => InterestAccrual.For(a, today, end))
            .OfType<InterestAccrual>()
            .ToList();

        var flowsByDate = input.Flows
            .Concat(VariableFlows(input, end))
            .Where(f => accounts.ContainsKey(f.AccountId))
            .GroupBy(f => f.Date < today ? today : f.Date)
            .ToDictionary(g => g.Key, g => g.ToList());

        var rateToBase = input.Accounts
            .Select(a => a.Currency)
            .Distinct()
            .ToDictionary(c => c, c => (Func<long, long>)(amount =>
                input.Rates.Convert(new Money(amount, Currency.FromCode(c)), input.BaseCurrency, today).Amount));

        var goalTrackers = input.Goals.Select(g => new GoalTracker(g, input, accounts)).ToList();
        var days = new List<(DateOnly Date, Dictionary<Guid, long> Balances, long Total)>();

        for (var date = today; date <= end; date = date.AddDays(1))
        {
            foreach (var accrual in interest)
            {
                balances[accrual.AccountId] += accrual.CreditDue(date);
            }

            foreach (var flow in flowsByDate.GetValueOrDefault(date) ?? [])
            {
                balances[flow.AccountId] += flow.Amount;
                foreach (var tracker in goalTrackers)
                {
                    tracker.OnFlow(flow);
                }
            }

            foreach (var accrual in interest)
            {
                accrual.AccrueDay(date, balances[accrual.AccountId]);
            }

            var total = input.Accounts.Where(a => a.IncludeInTotals).Sum(a => rateToBase[a.Currency](balances[a.Id]));
            foreach (var tracker in goalTrackers)
            {
                tracker.OnDayEnd(date, balances);
            }

            if (date <= to)
            {
                days.Add((date, new Dictionary<Guid, long>(balances), total));
            }
        }

        var sampleDates = SampleDates(from, to, input.Granularity, input.FirstDayOfMonth).ToHashSet();
        var visible = days.Where(d => d.Date >= from).ToList();
        var series = input.Accounts
            .Where(a => a.IncludeInTotals)
            .Select(a =>
            {
                var points = visible.Select(d => new BalancePoint(d.Date, d.Balances[a.Id])).ToList();
                var minimum = points.MinBy(p => p.Balance) ?? new BalancePoint(from, a.StartBalance);
                return new AccountSeries(a.Id, a.Currency, points.Where(p => sampleDates.Contains(p.Date)).ToList(), minimum);
            })
            .ToList();
        var totals = visible.Where(d => sampleDates.Contains(d.Date)).Select(d => new BalancePoint(d.Date, d.Total)).ToList();

        return new ForecastResult(
            series,
            totals,
            Alarms(input, visible, rateToBase),
            goalTrackers.Select(t => t.Result(today, end, input.FirstDayOfMonth)).ToList());
    }

    /// <summary>The horizon, extended to dated goals (never beyond <see cref="MaxHorizonMonths"/>).</summary>
    public static DateOnly SimulationEnd(ForecastInput input)
    {
        var end = input.Goals.Select(g => g.TargetDate).OfType<DateOnly>().Append(input.To).Max();
        var max = MaxEnd(input.Today);
        return end > max ? max : end;
    }

    /// <summary>Daily points, or month ends (of the user's financial month) plus the first and last day.</summary>
    public static IEnumerable<DateOnly> SampleDates(DateOnly from, DateOnly to, ForecastGranularity granularity, int firstDayOfMonth)
    {
        if (granularity == ForecastGranularity.Day)
        {
            for (var d = from; d <= to; d = d.AddDays(1))
            {
                yield return d;
            }

            yield break;
        }

        yield return from;
        for (var month = FinancialMonth.Containing(from, firstDayOfMonth); month.End(firstDayOfMonth) < to; month = month.Next)
        {
            var monthEnd = month.End(firstDayOfMonth);
            if (monthEnd > from)
            {
                yield return monthEnd;
            }
        }

        if (to > from)
        {
            yield return to;
        }
    }

    private static IEnumerable<ForecastFlow> VariableFlows(ForecastInput input, DateOnly end)
    {
        if (input.SpendingAccountId is not { } accountId || input.Accounts.FirstOrDefault(a => a.Id == accountId) is not { } account)
        {
            yield break;
        }

        var currency = Currency.FromCode(account.Currency);
        foreach (var month in input.VariableSpending.Where(m => m.Total > 0))
        {
            var total = input.Rates.Convert(new Money(month.Total, input.BaseCurrency), currency, input.Today);
            var days = month.End.DayNumber - month.Start.DayNumber + 1;
            var parts = total.Allocate(days);
            for (var i = 0; i < days; i++)
            {
                var date = month.Start.AddDays(i);
                if (date > end)
                {
                    yield break;
                }

                if (parts[i].Amount != 0)
                {
                    yield return new ForecastFlow(date, accountId, -parts[i].Amount, FlowKind.VariableSpending);
                }
            }
        }
    }

    private static List<ForecastAlarm> Alarms(
        ForecastInput input,
        List<(DateOnly Date, Dictionary<Guid, long> Balances, long Total)> days,
        Dictionary<string, Func<long, long>> toBase)
    {
        var detectors = new List<AlarmDetector>
        {
            new(AlarmKind.TotalBelowThreshold, null, d => d.Total, v => v < input.LowBalanceThreshold),
        };

        if (input.LowBalanceThreshold > 0 && input.SpendingAccountId is { } spendingId
                                          && input.Accounts.FirstOrDefault(a => a.Id == spendingId) is { IncludeInTotals: true } spending)
        {
            detectors.Add(new(AlarmKind.SpendingAccountBelowThreshold, spendingId,
                d => toBase[spending.Currency](d.Balances[spendingId]), v => v < input.LowBalanceThreshold));
        }

        foreach (var account in input.Accounts.Where(a => a.IncludeInTotals))
        {
            if (account.Type != AccountType.CreditCard)
            {
                detectors.Add(new(AlarmKind.AccountNegative, account.Id, d => d.Balances[account.Id], v => v < 0));
            }
            else if (account.CreditLimit is { } limit)
            {
                detectors.Add(new(AlarmKind.CreditLimitExceeded, account.Id, d => d.Balances[account.Id], v => v < -limit));
            }
        }

        foreach (var day in days)
        {
            foreach (var detector in detectors)
            {
                detector.Observe(day.Date, detector.Value(day));
            }
        }

        return detectors.SelectMany(d => d.Finish()).OrderBy(a => a.From).ThenBy(a => a.Kind).ToList();
    }

    private sealed class AlarmDetector(
        AlarmKind kind,
        Guid? accountId,
        Func<(DateOnly Date, Dictionary<Guid, long> Balances, long Total), long> value,
        Func<long, bool> isAlarming)
    {
        private readonly List<ForecastAlarm> _alarms = [];
        private (DateOnly From, DateOnly Until, DateOnly LowestDate, long Lowest)? _open;

        public Func<(DateOnly Date, Dictionary<Guid, long> Balances, long Total), long> Value { get; } = value;

        public void Observe(DateOnly date, long balance)
        {
            if (!isAlarming(balance))
            {
                Close();
                return;
            }

            _open = _open is { } o
                ? (o.From, date, balance < o.Lowest ? date : o.LowestDate, Math.Min(balance, o.Lowest))
                : (date, date, date, balance);
        }

        public IEnumerable<ForecastAlarm> Finish()
        {
            Close();
            return _alarms;
        }

        private void Close()
        {
            if (_open is { } o)
            {
                _alarms.Add(new ForecastAlarm(kind, accountId, o.From, o.Until, o.LowestDate, o.Lowest));
                _open = null;
            }
        }
    }

    /// <summary>Follows one goal: the linked account's balance, or the current amount plus marked contributions.</summary>
    private sealed class GoalTracker(ForecastGoal goal, ForecastInput input, Dictionary<Guid, ForecastAccount> accounts)
    {
        private readonly Currency _currency = Currency.FromCode(goal.Currency);
        private readonly bool _linked = goal.LinkedAccountId is { } id && accounts.ContainsKey(id);
        private readonly Dictionary<DateOnly, long> _snapshots = [];
        private long _contributed;
        private DateOnly? _reachedOn;

        public void OnFlow(ForecastFlow flow)
        {
            if (!_linked && flow.SavingsGoalId == goal.Id && flow.Amount > 0)
            {
                _contributed += Convert(flow.Amount, accounts[flow.AccountId].Currency);
            }
        }

        public void OnDayEnd(DateOnly date, Dictionary<Guid, long> balances)
        {
            var projected = _linked
                ? Convert(balances[goal.LinkedAccountId!.Value], accounts[goal.LinkedAccountId.Value].Currency)
                : goal.CurrentAmount + _contributed;
            if (_reachedOn is null && projected >= goal.TargetAmount)
            {
                _reachedOn = date;
            }

            _snapshots[date] = projected;
        }

        public GoalForecast Result(DateOnly today, DateOnly end, int firstDayOfMonth)
        {
            // Evaluated on the target date; an overdue goal today; a goal without a date at the end of the horizon.
            var evaluatedOn = goal.TargetDate switch
            {
                null => input.To < end ? input.To : end,
                { } t when t < today => today,
                { } t when t > end => end,
                { } t => t,
            };
            var projected = _snapshots[evaluatedOn];
            var shortfall = Math.Max(0, goal.TargetAmount - projected);
            var reachedOn = _reachedOn is { } r && r <= end ? r : (DateOnly?)null;
            int? margin = reachedOn is { } reached && goal.TargetDate is { } target && reached <= target
                ? target.DayNumber - reached.DayNumber
                : null;
            long? extra = shortfall > 0 && goal.TargetDate is { } due
                ? SavingsGoalMath.RecommendedMonthly(shortfall, 0, SavingsGoalMath.MonthsLeft(
                    FinancialMonth.Containing(today, firstDayOfMonth), due, firstDayOfMonth))
                : null;

            return new GoalForecast(goal.Id, goal.TargetDate, goal.TargetAmount, evaluatedOn, projected,
                OnTrack: shortfall == 0, shortfall, reachedOn, margin, extra, TargetBeyondHorizon: goal.TargetDate > end);
        }

        private long Convert(long amount, string currency) =>
            input.Rates.Convert(new Money(amount, Currency.FromCode(currency)), _currency, input.Today).Amount;
    }
}
