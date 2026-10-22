using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Common;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Forecasting;
using Finance.Domain.Monetary;

namespace Finance.Tests.Unit.Domain;

public class ForecastEngineTests
{
    private static readonly DateOnly Today = new(2026, 10, 22);
    private static readonly ExchangeRateTable Rates = new([new("USD", new DateOnly(2026, 10, 1), 3.0m)]);
    private static readonly Guid Card = UuidV7.New();
    private static readonly Guid Cash = UuidV7.New();

    private static ForecastAccount Account(Guid id, long balance, string currency = "BYN", bool include = true,
        AccountType type = AccountType.DebitCard, long? creditLimit = null) => new(id, currency, balance, include, type, creditLimit);

    private static ForecastInput Input(
        IEnumerable<ForecastAccount> accounts,
        IEnumerable<ForecastFlow>? flows = null,
        DateOnly? to = null,
        ForecastGranularity granularity = ForecastGranularity.Day,
        Guid? spendingAccount = null,
        IEnumerable<VariableSpendingMonth>? variable = null,
        IEnumerable<ForecastGoal>? goals = null,
        long threshold = 0,
        DateOnly? from = null) =>
        new(Today, from ?? Today, to ?? Today.AddDays(30), granularity, Currency.Byn, 1, threshold, spendingAccount,
            accounts.ToList(), (flows ?? []).ToList(), (variable ?? []).ToList(), (goals ?? []).ToList(), Rates);

    private static long BalanceOn(ForecastResult result, Guid account, DateOnly date) =>
        result.Accounts.Single(a => a.AccountId == account).Points.Single(p => p.Date == date).Balance;

    private static long TotalOn(ForecastResult result, DateOnly date) => result.Total.Single(p => p.Date == date).Balance;

    [Fact]
    public void Starts_from_current_balances_of_accounts_included_in_totals()
    {
        var excluded = UuidV7.New();
        var result = ForecastEngine.Run(Input([Account(Card, 100_000), Account(Cash, 5_000), Account(excluded, 999_999, include: false)]));

        result.Accounts.Select(a => a.AccountId).Should().BeEquivalentTo([Card, Cash]);
        result.Total.Should().HaveCount(31).And.OnlyContain(p => p.Balance == 105_000);
        result.Total[0].Date.Should().Be(Today);
    }

    [Fact]
    public void Applies_planned_recurring_and_scheduled_flows_on_their_dates()
    {
        var result = ForecastEngine.Run(Input(
            [Account(Card, 100_000), Account(Cash, 0)],
            [
                new(Today.AddDays(-5), Card, -1_000, FlowKind.Planned),     // overdue → today
                new(Today.AddDays(3), Card, 250_000, FlowKind.Recurring),
                new(Today.AddDays(5), Card, -20_000, FlowKind.Scheduled),
                new(Today.AddDays(5), Cash, 20_000, FlowKind.Scheduled),    // two sides of a transfer
                new(Today.AddDays(3), UuidV7.New(), -5, FlowKind.Planned),  // unknown account: ignored
            ]));

        BalanceOn(result, Card, Today).Should().Be(99_000);
        BalanceOn(result, Card, Today.AddDays(2)).Should().Be(99_000);
        BalanceOn(result, Card, Today.AddDays(3)).Should().Be(349_000);
        BalanceOn(result, Card, Today.AddDays(5)).Should().Be(329_000);
        BalanceOn(result, Cash, Today.AddDays(5)).Should().Be(20_000);
        TotalOn(result, Today.AddDays(5)).Should().Be(349_000);
    }

    [Fact]
    public void Variable_spending_is_spread_evenly_over_its_days_on_the_spending_account()
    {
        // 10 days × 1 000 + remainder distributed one kopeck at a time.
        var month = new VariableSpendingMonth(new FinancialMonth(2026, 10), Today, Today.AddDays(9), 10_003, VariableSpendingSource.CurrentBudget);
        var result = ForecastEngine.Run(Input([Account(Card, 50_000), Account(Cash, 1_000)], spendingAccount: Card, variable: [month]));

        BalanceOn(result, Card, Today).Should().Be(50_000 - 1_001);
        BalanceOn(result, Card, Today.AddDays(9)).Should().Be(50_000 - 10_003);
        BalanceOn(result, Card, Today.AddDays(20)).Should().Be(50_000 - 10_003);
        BalanceOn(result, Cash, Today.AddDays(9)).Should().Be(1_000);
    }

    [Fact]
    public void Variable_spending_in_another_currency_is_converted_at_the_latest_rate()
    {
        var usd = UuidV7.New();
        var month = new VariableSpendingMonth(new FinancialMonth(2026, 10), Today, Today, 3_000, VariableSpendingSource.History);
        var result = ForecastEngine.Run(Input([Account(usd, 10_000, "USD")], spendingAccount: usd, variable: [month]));

        BalanceOn(result, usd, Today).Should().Be(9_000); // 30 BYN = 10 USD
        TotalOn(result, Today).Should().Be(27_000);       // totals in BYN
    }

    [Fact]
    public void Horizon_ending_mid_month_takes_only_its_part_of_the_month()
    {
        var month = new VariableSpendingMonth(new FinancialMonth(2026, 11), new DateOnly(2026, 11, 1), new DateOnly(2026, 11, 30), 30_000, VariableSpendingSource.Budget);
        var result = ForecastEngine.Run(Input([Account(Card, 100_000)], to: new DateOnly(2026, 11, 10), spendingAccount: Card, variable: [month]));

        BalanceOn(result, Card, new DateOnly(2026, 11, 10)).Should().Be(90_000);
    }

    [Fact]
    public void Without_a_spending_account_there_is_no_variable_spending()
    {
        var month = new VariableSpendingMonth(new FinancialMonth(2026, 10), Today, Today.AddDays(9), 10_000, VariableSpendingSource.History);
        var result = ForecastEngine.Run(Input([Account(Card, 50_000)], variable: [month]));

        result.Total.Should().OnlyContain(p => p.Balance == 50_000);
    }

    [Fact]
    public void What_if_operations_change_the_scenario()
    {
        var baseline = ForecastEngine.Run(Input([Account(Card, 100_000)]));
        var scenario = ForecastEngine.Run(Input([Account(Card, 100_000)],
            [new(Today.AddDays(10), Card, -320_000, FlowKind.WhatIf, Label: "Ноутбук")]));

        TotalOn(baseline, Today.AddDays(30)).Should().Be(100_000);
        TotalOn(scenario, Today.AddDays(30)).Should().Be(-220_000);
        scenario.Alarms.Should().ContainSingle(a => a.Kind == AlarmKind.AccountNegative && a.From == Today.AddDays(10));
    }

    [Fact]
    public void Monthly_granularity_samples_month_ends()
    {
        var result = ForecastEngine.Run(Input([Account(Card, 1)], to: new DateOnly(2027, 1, 15), granularity: ForecastGranularity.Month));

        result.Total.Select(p => p.Date).Should().Equal(
            Today, new DateOnly(2026, 10, 31), new DateOnly(2026, 11, 30), new DateOnly(2026, 12, 31), new DateOnly(2027, 1, 15));
    }

    [Fact]
    public void Sample_dates_follow_the_financial_month()
    {
        ForecastEngine.SampleDates(new DateOnly(2026, 10, 22), new DateOnly(2026, 12, 10), ForecastGranularity.Month, 5)
            .Should().Equal(new DateOnly(2026, 10, 22), new DateOnly(2026, 11, 4), new DateOnly(2026, 12, 4), new DateOnly(2026, 12, 10));
    }

    [Fact]
    public void Series_start_at_from_but_simulation_starts_today()
    {
        var result = ForecastEngine.Run(Input([Account(Card, 100_000)], [new(Today.AddDays(1), Card, -1_000, FlowKind.Planned)],
            from: Today.AddDays(5), to: Today.AddDays(6)));

        result.Total.Should().Equal(new BalancePoint(Today.AddDays(5), 99_000), new BalancePoint(Today.AddDays(6), 99_000));
    }

    [Fact]
    public void Minimum_is_reported_per_account()
    {
        var result = ForecastEngine.Run(Input([Account(Card, 10_000)],
            [new(Today.AddDays(3), Card, -8_000, FlowKind.Planned), new(Today.AddDays(4), Card, 50_000, FlowKind.Recurring)]));

        result.Accounts.Single().Minimum.Should().Be(new BalancePoint(Today.AddDays(3), 2_000));
    }
}

public class ForecastAlarmTests
{
    private static readonly DateOnly Today = new(2026, 10, 22);
    private static readonly ExchangeRateTable Rates = new([new("USD", new DateOnly(2026, 10, 1), 3.0m)]);

    private static ForecastResult Run(IEnumerable<ForecastAccount> accounts, IEnumerable<ForecastFlow> flows, long threshold = 0, Guid? spending = null) =>
        ForecastEngine.Run(new ForecastInput(Today, Today, Today.AddDays(30), ForecastGranularity.Day, Currency.Byn, 1, threshold, spending,
            accounts.ToList(), flows.ToList(), [], [], Rates));

    [Fact]
    public void Negative_account_episodes_have_start_end_and_lowest_point()
    {
        var card = UuidV7.New();
        var result = Run([new(card, "BYN", 1_000, true)],
        [
            new(Today.AddDays(2), card, -3_000, FlowKind.Planned),  // −2 000
            new(Today.AddDays(4), card, -1_000, FlowKind.Planned),  // −3 000 lowest
            new(Today.AddDays(6), card, 10_000, FlowKind.Recurring), // back to +7 000
            new(Today.AddDays(20), card, -8_000, FlowKind.Planned), // −1 000 until the end
        ]);

        var negative = result.Alarms.Where(a => a.Kind == AlarmKind.AccountNegative).ToList();
        negative.Should().HaveCount(2);
        negative[0].Should().Be(new ForecastAlarm(AlarmKind.AccountNegative, card, Today.AddDays(2), Today.AddDays(5), Today.AddDays(4), -3_000));
        negative[1].Should().Be(new ForecastAlarm(AlarmKind.AccountNegative, card, Today.AddDays(20), Today.AddDays(30), Today.AddDays(20), -1_000));
        result.Alarms.Where(a => a.Kind == AlarmKind.TotalBelowThreshold).Should().HaveCount(2, "the total goes below zero too");
    }

    [Fact]
    public void Threshold_applies_to_the_total_and_the_spending_account()
    {
        var card = UuidV7.New();
        var deposit = UuidV7.New();
        var result = Run(
            [new(card, "BYN", 150_000, true), new(deposit, "BYN", 1_000_000, true, AccountType.Deposit)],
            [new(Today.AddDays(10), card, -60_000, FlowKind.Planned)],
            threshold: 100_000,
            spending: card);

        result.Alarms.Should().ContainSingle().Which.Should().Be(new ForecastAlarm(
            AlarmKind.SpendingAccountBelowThreshold, card, Today.AddDays(10), Today.AddDays(30), Today.AddDays(10), 90_000));
    }

    [Fact]
    public void Credit_cards_alarm_only_beyond_their_limit()
    {
        var credit = UuidV7.New();
        var cash = UuidV7.New();
        var result = Run(
            [new(credit, "BYN", -64_020, true, AccountType.CreditCard, 300_000), new(cash, "BYN", 1_000_000, true, AccountType.Cash)],
            [new(Today.AddDays(5), credit, -250_000, FlowKind.Planned)]);

        result.Alarms.Should().ContainSingle().Which.Should().Match<ForecastAlarm>(a =>
            a.Kind == AlarmKind.CreditLimitExceeded && a.AccountId == credit && a.From == Today.AddDays(5) && a.LowestBalance == -314_020);
    }

    [Fact]
    public void Total_threshold_is_in_the_base_currency()
    {
        var usd = UuidV7.New();
        var result = Run([new(usd, "USD", 10_000, true)], [], threshold: 40_000); // 100 USD = 300 BYN < 400 BYN

        result.Alarms.Should().ContainSingle().Which.Should().Match<ForecastAlarm>(a =>
            a.Kind == AlarmKind.TotalBelowThreshold && a.LowestBalance == 30_000 && a.From == Today && a.Until == Today.AddDays(30));
    }

    [Fact]
    public void Accounts_excluded_from_totals_do_not_alarm()
    {
        var hidden = UuidV7.New();
        var result = Run([new(hidden, "BYN", -5_000, false), new(UuidV7.New(), "BYN", 1, true)], []);

        result.Alarms.Should().BeEmpty();
    }
}

public class ForecastGoalTests
{
    private static readonly DateOnly Today = new(2026, 10, 22);
    private static readonly ExchangeRateTable Rates = new([new("USD", new DateOnly(2026, 10, 1), 3.0m)]);

    private static ForecastResult Run(IEnumerable<ForecastAccount> accounts, IEnumerable<ForecastFlow> flows, IEnumerable<ForecastGoal> goals, DateOnly? to = null) =>
        ForecastEngine.Run(new ForecastInput(Today, Today, to ?? Today.AddMonths(1), ForecastGranularity.Month, Currency.Byn, 1, 0, null,
            accounts.ToList(), flows.ToList(), [], goals.ToList(), Rates));

    [Fact]
    public void Linked_goal_follows_the_account_and_reports_the_margin()
    {
        var savings = UuidV7.New();
        var goal = new ForecastGoal(UuidV7.New(), 100_000, "BYN", new DateOnly(2027, 3, 1), savings, 0);
        var flows = Enumerable.Range(1, 5).Select(i => new ForecastFlow(new DateOnly(2026, 10, 25).AddMonths(i - 1), savings, 24_000, FlowKind.Recurring));

        var forecast = Run([new(savings, "BYN", 0, true, AccountType.Savings)], flows, [goal]).Goals.Single();

        forecast.ReachedOn.Should().Be(new DateOnly(2027, 2, 25));
        forecast.OnTrack.Should().BeTrue();
        forecast.EvaluatedOn.Should().Be(new DateOnly(2027, 3, 1));
        forecast.ProjectedAmount.Should().Be(120_000);
        forecast.MarginDays.Should().Be(4);
        forecast.Shortfall.Should().Be(0);
        forecast.ExtraMonthlyNeeded.Should().BeNull();
        forecast.TargetBeyondHorizon.Should().BeFalse();
    }

    [Fact]
    public void Shortfall_and_extra_monthly_contribution()
    {
        var card = UuidV7.New();
        var box = UuidV7.New();
        var goal = new ForecastGoal(UuidV7.New(), 320_000, "BYN", new DateOnly(2027, 3, 1), null, 110_000);
        var flows = new[]
        {
            new ForecastFlow(new DateOnly(2026, 11, 1), box, 52_500, FlowKind.Recurring, goal.Id),
            new ForecastFlow(new DateOnly(2026, 11, 1), card, -52_500, FlowKind.Recurring),
            new ForecastFlow(new DateOnly(2026, 12, 1), box, 30_000, FlowKind.Recurring, goal.Id),
            new ForecastFlow(new DateOnly(2026, 12, 2), box, 7_000, FlowKind.Recurring), // not marked
        };

        var forecast = Run([new(card, "BYN", 1_000_000, true), new(box, "BYN", 0, true)], flows, [goal]).Goals.Single();

        forecast.ProjectedAmount.Should().Be(192_500);
        forecast.OnTrack.Should().BeFalse();
        forecast.Shortfall.Should().Be(127_500);
        forecast.ReachedOn.Should().BeNull();
        // Months left from Oct 2026 to Mar 2027 = 5 → ⌈127 500 / 5⌉.
        forecast.ExtraMonthlyNeeded.Should().Be(25_500);
    }

    [Fact]
    public void Goal_in_another_currency_converts_the_linked_balance()
    {
        var usd = UuidV7.New();
        var goal = new ForecastGoal(UuidV7.New(), 60_000, "BYN", new DateOnly(2026, 11, 1), usd, 0);

        var forecast = Run([new(usd, "USD", 20_000, true)], [], [goal]).Goals.Single(); // 200 USD = 600 BYN

        forecast.ProjectedAmount.Should().Be(60_000);
        forecast.ReachedOn.Should().Be(Today);
        forecast.MarginDays.Should().Be(10);
    }

    [Fact]
    public void Simulation_runs_to_the_target_date_beyond_the_requested_horizon()
    {
        var savings = UuidV7.New();
        var goal = new ForecastGoal(UuidV7.New(), 50_000, "BYN", new DateOnly(2027, 6, 1), savings, 0);
        var result = Run([new(savings, "BYN", 0, true)], [new(new DateOnly(2027, 5, 1), savings, 60_000, FlowKind.Recurring)], [goal], to: Today.AddDays(10));

        result.Total.Last().Date.Should().Be(Today.AddDays(10), "series stop at the requested end");
        result.Goals.Single().Should().Match<GoalForecast>(g => g.OnTrack && g.ReachedOn == new DateOnly(2027, 5, 1));
    }

    [Fact]
    public void Target_beyond_24_months_is_evaluated_at_the_horizon_limit()
    {
        var goal = new ForecastGoal(UuidV7.New(), 50_000, "BYN", new DateOnly(2030, 1, 1), null, 10_000);
        var forecast = Run([new(UuidV7.New(), "BYN", 0, true)], [], [goal]).Goals.Single();

        forecast.TargetBeyondHorizon.Should().BeTrue();
        forecast.EvaluatedOn.Should().Be(ForecastEngine.MaxEnd(Today));
        forecast.ProjectedAmount.Should().Be(10_000);
    }

    [Fact]
    public void Overdue_and_undated_goals()
    {
        var overdue = new ForecastGoal(UuidV7.New(), 50_000, "BYN", new DateOnly(2026, 1, 1), null, 40_000);
        var undated = new ForecastGoal(UuidV7.New(), 50_000, "BYN", null, null, 60_000);

        var goals = Run([new(UuidV7.New(), "BYN", 0, true)], [], [overdue, undated]).Goals;

        goals[0].Should().Match<GoalForecast>(g => g.EvaluatedOn == Today && g.Shortfall == 10_000 && g.ExtraMonthlyNeeded == 10_000);
        goals[1].Should().Match<GoalForecast>(g => g.EvaluatedOn == Today.AddMonths(1) && g.OnTrack && g.ReachedOn == Today && g.MarginDays == null);
    }
}

public class InterestAccrualTests
{
    private static readonly DateOnly Today = new(2026, 1, 1);
    private static readonly Guid Deposit = UuidV7.New();

    private static ForecastResult Run(ForecastAccount account, DateOnly to, IEnumerable<ForecastFlow>? flows = null) =>
        ForecastEngine.Run(new ForecastInput(Today, Today, to, ForecastGranularity.Day, Currency.Byn, 1, 0, null,
            [account], (flows ?? []).ToList(), [], [], ExchangeRateTable.Empty));

    private static ForecastAccount Account(long balance, CapitalizationPeriod period, decimal rate = 12m, DateOnly? open = null,
        DateOnly? maturity = null, AccountType type = AccountType.Deposit) =>
        new(Deposit, "BYN", balance, true, type, null, rate, period, open ?? Today, maturity);

    private static long On(ForecastResult r, DateOnly date) => r.Total.Single(p => p.Date == date).Balance;

    [Fact]
    public void Monthly_capitalization_compounds_actual_365()
    {
        var result = Run(Account(1_000_000, CapitalizationPeriod.Monthly), new DateOnly(2026, 3, 1));

        // Jan: 10 000 × 12% × 31/365 = 101.917… → 101.92 BYN, credited on 1 Feb.
        On(result, new DateOnly(2026, 1, 31)).Should().Be(1_000_000);
        On(result, new DateOnly(2026, 2, 1)).Should().Be(1_010_192);
        // Feb: 10 101.92 × 12% × 28/365 = 92.98…, compounded on the new balance.
        var february = Money.FromDecimal(10_101.92m * 0.12m * 28m / 365m, Currency.Byn).Amount;
        On(result, new DateOnly(2026, 3, 1)).Should().Be(1_010_192 + february);
    }

    [Fact]
    public void Quarterly_capitalization_credits_every_three_months()
    {
        var result = Run(Account(1_000_000, CapitalizationPeriod.Quarterly), new DateOnly(2026, 4, 1));

        On(result, new DateOnly(2026, 3, 31)).Should().Be(1_000_000);
        // 90 days (Jan–Mar): 10 000 × 12% × 90/365 = 295.89.
        On(result, new DateOnly(2026, 4, 1)).Should().Be(1_029_589);
    }

    [Fact]
    public void Simple_interest_is_paid_monthly_without_compounding()
    {
        var result = Run(Account(1_000_000, CapitalizationPeriod.None, rate: 36.5m), new DateOnly(2026, 3, 1));

        // 36.5% / 365 = 0.1% per day of 10 000 → 10 BYN a day, on the principal only.
        On(result, new DateOnly(2026, 2, 1)).Should().Be(1_000_000 + 31 * 1_000);
        On(result, new DateOnly(2026, 3, 1)).Should().Be(1_000_000 + 59 * 1_000);
    }

    [Fact]
    public void At_end_pays_simple_interest_at_maturity()
    {
        var result = Run(Account(1_000_000, CapitalizationPeriod.AtEnd, rate: 36.5m, maturity: new DateOnly(2026, 4, 11)), new DateOnly(2026, 4, 30));

        On(result, new DateOnly(2026, 4, 10)).Should().Be(1_000_000);
        On(result, new DateOnly(2026, 4, 11)).Should().Be(1_000_000 + 100 * 1_000); // 100 days
        On(result, new DateOnly(2026, 4, 30)).Should().Be(1_100_000, "nothing accrues after maturity");
    }

    [Fact]
    public void Interest_already_earned_before_today_is_included()
    {
        var result = Run(Account(1_000_000, CapitalizationPeriod.Monthly, rate: 36.5m, open: new DateOnly(2025, 12, 22)), new DateOnly(2026, 1, 22));

        // Opened 22 Dec: 31 days (10 before today + 21) of 10 BYN credited on 22 Jan.
        On(result, new DateOnly(2026, 1, 22)).Should().Be(1_031_000);
    }

    [Fact]
    public void No_interest_before_opening_on_negative_balance_or_for_other_types()
    {
        Run(Account(1_000_000, CapitalizationPeriod.Monthly, open: new DateOnly(2026, 3, 1)), new DateOnly(2026, 3, 1))
            .Total.Should().OnlyContain(p => p.Balance == 1_000_000);
        Run(Account(-1_000_000, CapitalizationPeriod.Monthly), new DateOnly(2026, 2, 1))
            .Total.Should().OnlyContain(p => p.Balance == -1_000_000);
        Run(Account(1_000_000, CapitalizationPeriod.Monthly, type: AccountType.DebitCard), new DateOnly(2026, 2, 1))
            .Total.Should().OnlyContain(p => p.Balance == 1_000_000);
        Run(Account(1_000_000, CapitalizationPeriod.Monthly, maturity: new DateOnly(2025, 12, 1)), new DateOnly(2026, 2, 1))
            .Total.Should().OnlyContain(p => p.Balance == 1_000_000, "a matured deposit earns nothing");
    }

    [Fact]
    public void Deposits_during_the_period_earn_from_their_day()
    {
        var result = Run(Account(0, CapitalizationPeriod.Monthly, rate: 36.5m, type: AccountType.Savings), new DateOnly(2026, 2, 1),
            [new(new DateOnly(2026, 1, 22), Deposit, 1_000_000, FlowKind.Recurring)]);

        // Earns from 22 to 31 Jan = 10 days × 10 BYN.
        On(result, new DateOnly(2026, 2, 1)).Should().Be(1_000_000 + 10_000);
    }
}

public class VariableSpendingPlannerTests
{
    private static readonly DateOnly Today = new(2026, 10, 22);
    private static readonly Guid Food = UuidV7.New();
    private static readonly Guid Transport = UuidV7.New();
    private static readonly Guid Taxi = UuidV7.New();
    private static readonly Guid Rent = UuidV7.New();
    private static readonly Dictionary<Guid, Guid?> Parents = new() { [Food] = null, [Transport] = null, [Taxi] = Transport, [Rent] = null };

    private static IReadOnlyList<VariableSpendingMonth> Plan(
        DateOnly end,
        IReadOnlyList<PlannerLine>? current = null,
        Dictionary<FinancialMonth, IReadOnlyList<PlannerLine>>? future = null,
        IReadOnlyList<IReadOnlyDictionary<Guid, long>>? history = null,
        Dictionary<Guid, long>? spent = null,
        IReadOnlyList<ScheduledExpense>? scheduled = null) =>
        VariableSpendingPlanner.Plan(new SpendingPlannerInput(Today, end, 1, current, future ?? [], history ?? [], spent ?? [], scheduled ?? [], Parents));

    [Fact]
    public void Current_month_uses_remaining_limits_minus_what_is_already_scheduled()
    {
        var months = Plan(new DateOnly(2026, 10, 31),
            current: [new(Food, 20_000), new(Transport, 5_000), new(Rent, 90_000)],
            scheduled:
            [
                new(new DateOnly(2026, 10, 25), Rent, 85_000),
                new(new DateOnly(2026, 10, 26), Taxi, 2_000),       // child → parent line
                new(new DateOnly(2026, 11, 1), Food, 99_999),       // next month: ignored here
            ]);

        months.Should().ContainSingle().Which.Should().Be(new VariableSpendingMonth(
            new FinancialMonth(2026, 10), Today, new DateOnly(2026, 10, 31), 20_000 + 3_000 + 5_000, VariableSpendingSource.CurrentBudget));
    }

    [Fact]
    public void Overspent_or_fully_scheduled_lines_add_nothing()
    {
        var month = Plan(new DateOnly(2026, 10, 31),
            current: [new(Food, -3_000), new(Rent, 80_000)],
            scheduled: [new(new DateOnly(2026, 10, 25), Rent, 85_000)]).Single();

        month.Total.Should().Be(0);
    }

    [Fact]
    public void Future_months_use_their_budget_or_the_history_median()
    {
        var history = new List<IReadOnlyDictionary<Guid, long>>
        {
            new Dictionary<Guid, long> { [Food] = 60_000, [Taxi] = 1_000 },
            new Dictionary<Guid, long> { [Food] = 80_000 },
            new Dictionary<Guid, long> { [Food] = 70_000, [Taxi] = 5_000 },
        };
        var months = Plan(new DateOnly(2027, 1, 15),
            future: new() { [new FinancialMonth(2026, 12)] = [new(Food, 50_000), new(Rent, 90_000)] },
            history: history,
            scheduled: [new(new DateOnly(2026, 12, 25), Rent, 90_000)]);

        months.Select(m => m.Month.ToString()).Should().Equal("2026-10", "2026-11", "2026-12", "2027-01");
        months[1].Should().Be(new VariableSpendingMonth(new FinancialMonth(2026, 11), new DateOnly(2026, 11, 1), new DateOnly(2026, 11, 30),
            70_000 + 1_000, VariableSpendingSource.History));
        months[2].Should().Match<VariableSpendingMonth>(m => m.Total == 50_000 && m.Source == VariableSpendingSource.Budget);
        months[3].Should().Match<VariableSpendingMonth>(m => m.Total == 71_000 && m.End == new DateOnly(2027, 1, 31));
    }

    [Fact]
    public void Current_month_without_budget_subtracts_what_was_spent()
    {
        var history = new List<IReadOnlyDictionary<Guid, long>> { new Dictionary<Guid, long> { [Food] = 60_000, [Taxi] = 3_000 } };

        var month = Plan(new DateOnly(2026, 10, 31), history: history, spent: new() { [Food] = 45_000, [Taxi] = 9_000 }).Single();

        month.Should().Match<VariableSpendingMonth>(m => m.Total == 15_000 && m.Source == VariableSpendingSource.History && m.Start == Today);
    }

    [Fact]
    public void No_history_means_no_variable_spending()
    {
        Plan(new DateOnly(2026, 11, 30)).Should().OnlyContain(m => m.Total == 0);
    }

    [Theory]
    [InlineData(new long[] { }, 0)]
    [InlineData(new long[] { 5 }, 5)]
    [InlineData(new long[] { 9, 1, 5 }, 5)]
    [InlineData(new long[] { 1, 4 }, 2)]   // 2.5 → 2 (to even)
    [InlineData(new long[] { 1, 6 }, 4)]   // 3.5 → 4 (to even)
    public void Median(long[] values, long expected) => VariableSpendingPlanner.Median(values).Should().Be(expected);
}
