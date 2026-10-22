using System.Net;
using Finance.Application.Features.Analytics;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class AnalyticsTests(ApiFactory factory)
{
    private static DateOnly D(int y, int m, int d) => new(y, m, d);

    private static readonly DateOnly Today = TestApiExtensions.TodayFor();
    private static readonly FinancialMonth ThisMonth = FinancialMonth.Containing(Today, 1);

    /// <summary>August vs July 2026 with a USD account, hierarchy and things that must not count.</summary>
    private async Task<(TestUser User, Guid Card, Guid Usd)> SeedSummerAsync()
    {
        await factory.SeedStandardRatesAsync(); // USD = 3.0 BYN
        var user = await factory.RegisterUserAsync();
        var card = (await user.CreateAccountAsync("Карта", initialBalance: 1_000_000)).Id;
        var usd = (await user.CreateAccountAsync("USD", "USD", 100_000)).Id;

        // July
        await user.ExpenseAsync(card, 40_000, D(2026, 7, 10));
        await user.ExpenseAsync(card, 10_000, D(2026, 7, 11), "Такси");
        await user.IncomeAsync(card, 200_000, D(2026, 7, 1));
        // August
        await user.ExpenseAsync(card, 30_000, D(2026, 8, 3));
        await user.ExpenseAsync(usd, 5_000, D(2026, 8, 4));                  // 50 USD = 150 BYN
        await user.ExpenseAsync(card, 4_000, D(2026, 8, 5), "Такси");
        await user.ExpenseAsync(card, 2_000, D(2026, 8, 6), "Общественный транспорт");
        await user.ExpenseAsync(card, 1_000, D(2026, 8, 7), "Транспорт");
        await user.ExpenseAsync(card, 13_600, D(2026, 8, 20), "Одежда", note: "Куртка");
        await user.IncomeAsync(card, 250_000, D(2026, 8, 1));
        // Not counted: planned, skipped, transfer, other month
        await user.ExpenseAsync(card, 99_999, D(2026, 8, 25), status: TransactionStatus.Planned);
        await user.ExpenseAsync(card, 88_888, D(2026, 8, 26), status: TransactionStatus.Skipped);
        await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card, ToAccountId = usd, Type = TransactionType.Transfer, Amount = 30_000, ToAmount = 10_000, Date = D(2026, 8, 9),
        });
        await user.ExpenseAsync(card, 7_000, D(2026, 9, 1));
        return (user, card, usd);
    }

    [Fact]
    public async Task Category_breakdown_with_hierarchy_share_and_change()
    {
        var (user, _, _) = await SeedSummerAsync();
        var food = await user.CategoryAsync("Продукты");
        var transport = await user.CategoryAsync("Транспорт");
        var taxi = await user.CategoryAsync("Такси");
        var clothes = await user.CategoryAsync("Одежда");

        var r = await user.GetAsync<CategoryBreakdownResponse>("/api/v1/analytics/categories?from=2026-08-01&to=2026-08-31");

        r.PreviousFrom.Should().Be(D(2026, 7, 1));
        r.PreviousTo.Should().Be(D(2026, 7, 31));
        r.Kind.Should().Be(CategoryKind.Expense);
        r.Currency.Should().Be("BYN");
        r.Total.Should().Be(30_000 + 15_000 + 4_000 + 2_000 + 1_000 + 13_600);
        r.PreviousTotal.Should().Be(50_000);
        r.ChangePercent.Should().Be(31.2m);

        r.Categories.Select(c => c.CategoryId).Should().Equal(food.Id, clothes.Id, transport.Id);
        var foodItem = r.Categories[0];
        foodItem.Should().Match<CategoryBreakdownItem>(c => c.Amount == 45_000 && c.PreviousAmount == 40_000 && c.ChangePercent == 12.5m);
        foodItem.SharePercent.Should().Be(68.6m);

        var transportItem = r.Categories.Single(c => c.CategoryId == transport.Id);
        transportItem.Amount.Should().Be(7_000);
        transportItem.DirectAmount.Should().Be(1_000);
        transportItem.PreviousAmount.Should().Be(10_000);
        transportItem.Children.Select(c => (c.CategoryId, c.Amount)).Should().Equal((taxi.Id, 4_000L), ((await user.CategoryAsync("Общественный транспорт")).Id, 2_000L));
        r.Categories.Single(c => c.CategoryId == clothes.Id).ChangePercent.Should().BeNull("there was nothing in July");

        var income = await user.GetAsync<CategoryBreakdownResponse>("/api/v1/analytics/categories?from=2026-08-01&to=2026-08-31&kind=Income");
        income.Total.Should().Be(250_000);
        income.Categories.Should().ContainSingle().Which.PreviousAmount.Should().Be(200_000);
    }

    [Fact]
    public async Task Period_comparison()
    {
        var (user, _, _) = await SeedSummerAsync();

        var r = await user.GetAsync<PeriodComparisonResponse>("/api/v1/analytics/compare?from=2026-08-01&to=2026-08-31");

        r.Current.Should().Be(new PeriodTotals(D(2026, 8, 1), D(2026, 8, 31), 250_000, 65_600, 184_400));
        r.Previous.Should().Be(new PeriodTotals(D(2026, 7, 1), D(2026, 7, 31), 200_000, 50_000, 150_000));
        r.Income.Should().Be(new Change(50_000, 25.0m));
        r.Expense.Should().Be(new Change(15_600, 31.2m));
        r.Net.Should().Be(new Change(34_400, 22.9m));
    }

    [Fact]
    public async Task Top_expenses_are_ranked_in_the_base_currency()
    {
        var (user, card, usd) = await SeedSummerAsync();

        var r = await user.GetAsync<TopExpensesResponse>("/api/v1/analytics/top-expenses?from=2026-08-01&to=2026-08-31&limit=3");

        r.Items.Select(i => (i.AccountId, i.Amount, i.AmountInBase)).Should().Equal(
            (card, 30_000L, 30_000L), (usd, 5_000L, 15_000L), (card, 13_600L, 13_600L));
        r.Items[2].Note.Should().Be("Куртка");
        r.Items[1].Currency.Should().Be("USD");
    }

    [Fact]
    public async Task Averages_per_day_week_and_month()
    {
        var (user, _, _) = await SeedSummerAsync();

        var r = await user.GetAsync<AveragesResponse>("/api/v1/analytics/averages?from=2026-08-01&to=2026-08-31");

        r.Days.Should().Be(31);
        r.Total.Should().Be(65_600);
        r.PerDay.Should().Be(2_116);    // 656 / 31 = 21.161…
        r.PerWeek.Should().Be(14_813);  // × 7 = 148.129…
        r.PerMonth.Should().Be(64_410); // × 30.4375 = 644.096…
    }

    [Fact]
    public async Task Monthly_dynamics_for_the_last_months_and_one_category()
    {
        var user = await factory.RegisterUserAsync();
        var card = (await user.CreateAccountAsync(initialBalance: 1_000_000)).Id;
        var start = ThisMonth.Start(1);
        await user.ExpenseAsync(card, 10_000, start, "Такси");
        await user.ExpenseAsync(card, 3_000, start, "Продукты");
        await user.IncomeAsync(card, 50_000, start);
        await user.ExpenseAsync(card, 7_000, ThisMonth.Previous.Start(1), "Общественный транспорт");

        var all = await user.GetAsync<MonthlyDynamicsResponse>("/api/v1/analytics/monthly?months=3");

        all.Months.Select(m => m.Month).Should().Equal(ThisMonth.AddMonths(-2).ToString(), ThisMonth.Previous.ToString(), ThisMonth.ToString());
        all.Months[2].Should().Match<MonthlyPoint>(m => m.Income == 50_000 && m.Expense == 13_000 && m.Net == 37_000 && m.IsCurrent);
        all.Months[1].Should().Match<MonthlyPoint>(m => m.Expense == 7_000 && !m.IsCurrent);
        all.Months[0].Expense.Should().Be(0);

        var transport = (await user.CategoryAsync("Транспорт")).Id;
        var onlyTransport = await user.GetAsync<MonthlyDynamicsResponse>($"/api/v1/analytics/monthly?months=2&categoryId={transport}");
        onlyTransport.Months.Select(m => m.Expense).Should().Equal(7_000, 10_000);
        onlyTransport.Months.Should().OnlyContain(m => m.Income == 0);

        await (await user.Client.GetAsync($"/api/v1/analytics/monthly?categoryId={Guid.CreateVersion7()}"))
            .ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Net_worth_at_month_ends()
    {
        await factory.SeedStandardRatesAsync();
        var user = await factory.RegisterUserAsync();
        var card = (await user.CreateAccountAsync("Карта", initialBalance: 100_000)).Id;
        var twoMonthsAgo = ThisMonth.AddMonths(-2).Start(1).AddDays(3);
        await user.ExpenseAsync(card, 10_000, twoMonthsAgo);
        await user.IncomeAsync(card, 50_000, Today);
        await user.CreateAccountAsync("Новая", initialBalance: 5_000);           // created today, no history
        await user.CreateAccountAsync("USD", "USD", 10_000);                     // 100 USD = 300 BYN, today only
        await user.PostAsync<Finance.Application.Features.Accounts.AccountResponse>("/api/v1/accounts",
            new Finance.Application.Features.Accounts.CreateAccountRequest
            {
                Name = "Вне итога", Type = AccountType.Cash, Currency = "BYN", InitialBalance = 999_999, IncludeInTotals = false,
            });

        var r = await user.GetAsync<NetWorthResponse>("/api/v1/analytics/net-worth?months=3");

        r.Months.Select(m => (m.Month, m.Date, m.NetWorth)).Should().Equal(
            (ThisMonth.AddMonths(-2).ToString(), ThisMonth.AddMonths(-2).End(1), 90_000L),
            (ThisMonth.Previous.ToString(), ThisMonth.Previous.End(1), 90_000L),
            (ThisMonth.ToString(), Today, 140_000L + 5_000 + 30_000));
        r.Months[2].Change.Should().Be(85_000);

        var all = await user.GetAsync<NetWorthResponse>("/api/v1/analytics/net-worth?months=1&includeExcluded=true");
        all.Months.Single().NetWorth.Should().Be(175_000 + 999_999);
    }

    [Fact]
    public async Task Defaults_validation_and_isolation()
    {
        var (alice, _, _) = await SeedSummerAsync();
        var bob = await factory.RegisterUserAsync();

        var defaults = await bob.GetAsync<CategoryBreakdownResponse>("/api/v1/analytics/categories");
        defaults.From.Should().Be(ThisMonth.Start(1));
        defaults.To.Should().Be(ThisMonth.End(1));
        defaults.Total.Should().Be(0);

        (await bob.GetAsync<CategoryBreakdownResponse>("/api/v1/analytics/categories?from=2026-08-01&to=2026-08-31")).Categories.Should().BeEmpty();
        (await bob.GetAsync<TopExpensesResponse>("/api/v1/analytics/top-expenses?from=2026-08-01&to=2026-08-31")).Items.Should().BeEmpty();

        await (await alice.Client.GetAsync("/api/v1/analytics/monthly?months=0")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await alice.Client.GetAsync("/api/v1/analytics/net-worth?months=37")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await alice.Client.GetAsync("/api/v1/analytics/top-expenses?limit=100")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await alice.Client.GetAsync("/api/v1/analytics/compare?from=2020-01-01&to=2026-01-01")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await alice.Client.GetAsync("/api/v1/analytics/averages?from=2026-08-10&to=2026-08-01")).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
    }
}
