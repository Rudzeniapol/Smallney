using System.Net;
using System.Text;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Budgets;
using Finance.Application.Features.Forecast;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Recurring;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Forecasting;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class ForecastTests(ApiFactory factory)
{
    private static readonly DateOnly Today = TestApiExtensions.TodayFor();
    private static readonly FinancialMonth ThisMonth = FinancialMonth.Containing(Today, 1);

    private static string Iso(DateOnly d) => d.ToString("yyyy-MM-dd");

    private static async Task SetSpendingAccountAsync(TestUser user, Guid accountId, long threshold = 0) =>
        await (await user.Client.PatchAsync("/api/v1/me", new StringContent(
            $$"""{"defaultSpendingAccountId": "{{accountId}}", "lowBalanceThreshold": {{threshold}}}""", Encoding.UTF8, "application/json")))
            .EnsureStatusAsync(HttpStatusCode.OK);

    private static long Total(ForecastResponse f, DateOnly date) => f.Total.Single(p => p.Date == date).Balance;

    private static long Balance(ForecastResponse f, Guid account, DateOnly date) =>
        f.Accounts.Single(a => a.AccountId == account).Points.Single(p => p.Date == date).Balance;

    [Fact]
    public async Task Starts_from_current_balances_and_defaults_to_three_months()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 100_000);
        var hidden = await user.PostAsync<AccountResponse>("/api/v1/accounts", new CreateAccountRequest
        {
            Name = "Чужие", Type = AccountType.Cash, Currency = "BYN", InitialBalance = 500_000, IncludeInTotals = false,
        });
        await user.ExpenseAsync(card.Id, 10_000, Today.AddDays(-1));

        var forecast = await user.GetAsync<ForecastResponse>("/api/v1/forecast");

        forecast.Today.Should().Be(Today);
        forecast.From.Should().Be(Today);
        forecast.To.Should().Be(Today.AddMonths(3));
        forecast.Granularity.Should().Be(ForecastGranularity.Day);
        forecast.Accounts.Should().ContainSingle().Which.AccountId.Should().Be(card.Id);
        forecast.Total.Should().OnlyContain(p => p.Balance == 90_000);
        forecast.SpendingAccountId.Should().Be(card.Id, "the only debit card is the fallback spending account");
        hidden.Should().NotBeNull();
    }

    [Fact]
    public async Task Planned_scheduled_and_recurring_flows_are_counted_once()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 100_000);
        var phone = (await user.CategoryAsync("Связь и интернет")).Id;
        var salary = (await user.CategoryAsync("Зарплата", Finance.Domain.Categories.CategoryKind.Income)).Id;

        // Monthly expense due today: materialized as Planned right away, must not be counted twice.
        await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "Связь", AccountId = card.Id, Type = TransactionType.Expense, Amount = 1_850, CategoryId = phone,
            Frequency = Frequency.Monthly, StartDate = Today,
        });
        await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "Зарплата", AccountId = card.Id, Type = TransactionType.Income, Amount = 250_000, CategoryId = salary,
            Frequency = Frequency.Monthly, StartDate = Today.AddDays(5),
        });
        await user.IncomeAsync(card.Id, 7_000, Today.AddDays(10)); // cleared, dated in the future

        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(Today.AddDays(20))}");

        Total(forecast, Today).Should().Be(100_000 - 1_850);
        Total(forecast, Today.AddDays(5)).Should().Be(100_000 - 1_850 + 250_000);
        Total(forecast, Today.AddDays(10)).Should().Be(100_000 - 1_850 + 250_000 + 7_000);
        forecast.VariableSpending.Should().OnlyContain(m => m.Total == 0, "there is no budget and no history");
    }

    [Fact]
    public async Task Skipped_occurrences_are_not_forecast()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 100_000);
        var rule = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "Связь", AccountId = card.Id, Type = TransactionType.Expense, Amount = 1_850,
            CategoryId = (await user.CategoryAsync("Связь и интернет")).Id, Frequency = Frequency.Monthly, StartDate = Today,
        });
        await user.PostAsync<TransactionResponse>($"/api/v1/transactions/{RecurringRule.OccurrenceTransactionId(rule.Id, Today)}/skip", new { }, HttpStatusCode.OK);

        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(Today.AddDays(3))}");

        forecast.Total.Should().OnlyContain(p => p.Balance == 100_000);
    }

    [Fact]
    public async Task Current_month_budget_remaining_is_spread_until_the_month_end()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 1_000_000);
        await user.CreateAccountAsync("Наличные", initialBalance: 10_000, type: AccountType.Cash);
        await SetSpendingAccountAsync(user, card.Id);
        var food = await user.CategoryAsync("Продукты");
        await user.PutAsync<BudgetResponse>($"/api/v1/budgets/{ThisMonth}", new BudgetPayload
        {
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 40_000 }],
        });
        await user.ExpenseAsync(card.Id, 9_000, ThisMonth.Start(1));

        var end = ThisMonth.End(1);
        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(end)}");

        Balance(forecast, card.Id, end).Should().Be(1_000_000 - 9_000 - 31_000, "the remaining 31 000 is spent by the month end");
        var current = forecast.VariableSpending.Single();
        current.Should().Match<VariableSpendingResponse>(m =>
            m.Month == ThisMonth.ToString() && m.Total == 31_000 && m.Source == VariableSpendingSource.CurrentBudget && m.Start == Today);
    }

    [Fact]
    public async Task Months_without_budget_use_the_median_of_three_full_months_without_rule_spending()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 10_000_000);
        await SetSpendingAccountAsync(user, card.Id);
        await user.ExpenseAsync(card.Id, 1, ThisMonth.AddMonths(-4).Start(1)); // first activity before the history window
        await user.ExpenseAsync(card.Id, 60_000, ThisMonth.AddMonths(-3).Start(1).AddDays(2));
        await user.ExpenseAsync(card.Id, 80_000, ThisMonth.AddMonths(-2).Start(1).AddDays(2));
        await user.ExpenseAsync(card.Id, 70_000, ThisMonth.AddMonths(-1).Start(1).AddDays(2));
        await user.ExpenseAsync(card.Id, 5_000, ThisMonth.AddMonths(-1).Start(1).AddDays(3), "Такси");

        // A big rule-generated payment in the history must not be part of the median.
        var rent = await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "Аренда", AccountId = card.Id, Type = TransactionType.Expense, Amount = 900_000,
            CategoryId = (await user.CategoryAsync("Продукты")).Id, Frequency = Frequency.Monthly,
            StartDate = ThisMonth.AddMonths(-2).Start(1).AddDays(1), IsActive = false,
        });
        var food = await user.CategoryAsync("Продукты");
        await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card.Id, Type = TransactionType.Expense, Amount = 900_000, CategoryId = food.Id,
            Date = ThisMonth.AddMonths(-2).Start(1).AddDays(1), RecurringRuleId = rent.Id, RecurrenceDate = ThisMonth.AddMonths(-2).Start(1).AddDays(1),
        });

        var next = ThisMonth.Next;
        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(next.End(1))}&granularity=Month");

        forecast.VariableSpending.Single(m => m.Month == next.ToString())
            .Should().Match<VariableSpendingResponse>(m => m.Total == 70_000 && m.Source == VariableSpendingSource.History);
        var current = forecast.VariableSpending.Single(m => m.Month == ThisMonth.ToString());
        current.Total.Should().Be(70_000, "taxi has a median of 0 and nothing was spent this month");
        const long balanceNow = 10_000_000 - 1 - 60_000 - 80_000 - 70_000 - 5_000 - 900_000;
        Total(forecast, next.End(1)).Should().Be(balanceNow - 70_000 - 70_000);
    }

    [Fact]
    public async Task Savings_account_earns_interest()
    {
        var user = await factory.RegisterUserAsync();
        var savings = await user.PostAsync<AccountResponse>("/api/v1/accounts", new CreateAccountRequest
        {
            Name = "Накопительный", Type = AccountType.Savings, Currency = "BYN", InitialBalance = 1_000_000,
            InterestRatePercent = 36.5m, CapitalizationPeriod = CapitalizationPeriod.Monthly, OpenDate = Today,
        });

        var anniversary = Today.AddMonths(1);
        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(anniversary)}");

        var days = anniversary.DayNumber - Today.DayNumber;
        Balance(forecast, savings.Id, anniversary.AddDays(-1)).Should().Be(1_000_000);
        Balance(forecast, savings.Id, anniversary).Should().Be(1_000_000 + (days * 1_000), "0.1% a day of 10 000 BYN");
    }

    [Fact]
    public async Task What_if_scenario_via_query_and_body()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 200_000);
        var to = Today.AddDays(30);

        var viaQuery = await user.GetAsync<ForecastResponse>(
            $"/api/v1/forecast?to={Iso(to)}&extraOneOff={Iso(Today.AddDays(10))}|-320000|{card.Id}|{Uri.EscapeDataString("Ноутбук")}");

        viaQuery.Scenario.Should().NotBeNull();
        viaQuery.Scenario!.EndBalanceDifference.Should().Be(-320_000);
        viaQuery.Scenario.ExtraOneOffs.Single().Label.Should().Be("Ноутбук");
        viaQuery.Scenario.Alarms.Should().Contain(a => a.Kind == AlarmKind.AccountNegative && a.From == Today.AddDays(10) && a.LowestBalance == -120_000);
        viaQuery.Alarms.Should().BeEmpty("the baseline is unaffected");
        viaQuery.Total.Last().Balance.Should().Be(200_000);

        var response = await user.Client.PostAsync("/api/v1/forecast", JsonContent(new ForecastRequest
        {
            To = to,
            ExtraOneOffs = [new() { Date = Today.AddDays(1), Amount = 50_000, AccountId = card.Id, Label = "Премия" }],
        }));
        await response.EnsureStatusAsync(HttpStatusCode.OK);
        var viaBody = (await System.Net.Http.Json.HttpContentJsonExtensions.ReadFromJsonAsync<ForecastResponse>(response.Content, Json.Options))!;
        viaBody.Scenario!.Total.Last().Balance.Should().Be(250_000);

        // Nothing was saved.
        (await user.GetAsync<AccountResponse>($"/api/v1/accounts/{card.Id}")).Balance.Should().Be(200_000);
    }

    [Fact]
    public async Task Alarms_use_the_threshold_on_the_spending_account()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 150_000);
        await user.CreateAccountAsync("Накопительный", initialBalance: 5_000_000, type: AccountType.Savings);
        await SetSpendingAccountAsync(user, card.Id, threshold: 100_000);
        await user.ExpenseAsync(card.Id, 60_000, Today.AddDays(4), status: TransactionStatus.Planned);

        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(Today.AddDays(10))}");

        forecast.LowBalanceThreshold.Should().Be(100_000);
        forecast.Alarms.Should().ContainSingle().Which.Should().Be(new ForecastAlarm(
            AlarmKind.SpendingAccountBelowThreshold, card.Id, Today.AddDays(4), Today.AddDays(10), Today.AddDays(4), 90_000));
        forecast.Accounts.Single(a => a.AccountId == card.Id).Minimum.Balance.Should().Be(90_000);
    }

    [Fact]
    public async Task Goals_outlook_follows_recurring_contributions()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 10_000_000);
        var savings = await user.CreateAccountAsync("Накопительный", initialBalance: 0, type: AccountType.Savings);
        var target = Today.AddMonths(4).AddDays(3);
        var onTrack = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", new CreateSavingsGoalRequest
        {
            Name = "Отпуск", TargetAmount = 90_000, Currency = "BYN", TargetDate = target, LinkedAccountId = savings.Id,
        });
        var behind = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", new CreateSavingsGoalRequest
        {
            Name = "Ноутбук", TargetAmount = 320_000, Currency = "BYN", TargetDate = target,
        });
        await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "В отпуск", AccountId = card.Id, ToAccountId = savings.Id, Type = TransactionType.Transfer, Amount = 30_000,
            Frequency = Frequency.Monthly, StartDate = Today.AddDays(1),
        });
        await user.PostAsync<RecurringRuleResponse>("/api/v1/recurring-rules", new CreateRecurringRuleRequest
        {
            Name = "На ноутбук", AccountId = card.Id, ToAccountId = savings.Id, Type = TransactionType.Transfer, Amount = 10_000,
            SavingsGoalId = behind.Id, Frequency = Frequency.Monthly, StartDate = Today.AddDays(1),
        });

        // The requested horizon is shorter than the target date: the simulation still runs until the target.
        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(Today.AddDays(7))}");

        var vacation = forecast.Goals.Single(g => g.GoalId == onTrack.Id);
        vacation.OnTrack.Should().BeTrue();
        vacation.ReachedOn.Should().Be(Today.AddDays(1).AddMonths(2), "30 000 + 10 000 a month land on the linked account");
        vacation.MarginDays.Should().BePositive();

        var laptop = forecast.Goals.Single(g => g.GoalId == behind.Id);
        laptop.OnTrack.Should().BeFalse();
        laptop.ProjectedAmount.Should().Be(50_000, "5 marked transfers of 10 000 before the target date");
        laptop.Shortfall.Should().Be(270_000);
        laptop.ExtraMonthlyNeeded.Should().BePositive();
        forecast.Total.Last().Date.Should().Be(Today.AddDays(7));
    }

    [Fact]
    public async Task Monthly_granularity_returns_month_ends()
    {
        var user = await factory.RegisterUserAsync();
        await user.CreateAccountAsync(initialBalance: 1);

        var to = ThisMonth.AddMonths(2).End(1);
        var forecast = await user.GetAsync<ForecastResponse>($"/api/v1/forecast?to={Iso(to)}&granularity=Month");

        forecast.Total.Select(p => p.Date).Should().Equal(
            new[] { Today, ThisMonth.End(1), ThisMonth.Next.End(1), to }.Distinct());
    }

    [Fact]
    public async Task Invalid_requests()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var foreign = await (await factory.RegisterUserAsync()).CreateAccountAsync();

        await (await user.Client.GetAsync($"/api/v1/forecast?to={Iso(Today.AddMonths(25))}"))
            .ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.Client.GetAsync($"/api/v1/forecast?to={Iso(Today.AddDays(5))}&extraOneOff={Iso(Today.AddDays(6))}|-1|{card.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.Client.GetAsync("/api/v1/forecast?extraOneOff=garbage"))
            .ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.Client.GetAsync($"/api/v1/forecast?extraOneOff={Iso(Today)}|0|{card.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.Client.GetAsync($"/api/v1/forecast?extraOneOff={Iso(Today)}|-100|{foreign.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "account_not_found");
    }

    private static StringContent JsonContent(object body) =>
        new(System.Text.Json.JsonSerializer.Serialize(body, Json.Options), Encoding.UTF8, "application/json");
}
