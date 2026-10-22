using System.Net;
using Finance.Application.Features.Auth;
using Finance.Application.Features.Budgets;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Transactions;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Goals;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class BudgetsTests(ApiFactory factory)
{
    private static DateOnly D(int y, int m, int d) => new(y, m, d);

    private async Task<TestUser> UserStartingMonthOnThe5thAsync() =>
        await factory.RegisterUserAsync(new RegisterRequest { FirstDayOfMonth = 5 });

    private static Task<SavingsGoalResponse> GoalAsync(TestUser user, string name = "Подушка", DateOnly? targetDate = null, long target = 750_000) =>
        user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals",
            new CreateSavingsGoalRequest { Name = name, TargetAmount = target, Currency = "BYN", TargetDate = targetDate });

    [Fact]
    public async Task Save_get_replace_list_and_delete()
    {
        var user = await UserStartingMonthOnThe5thAsync();
        var food = await user.CategoryAsync("Продукты");
        var taxi = await user.CategoryAsync("Такси");
        var goal = await GoalAsync(user);

        var saved = await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-10", new BudgetPayload
        {
            ExpectedIncome = 290_000,
            Lines =
            [
                new() { CategoryId = food.Id, PlannedAmount = 80_000, Rollover = true },
                new() { CategoryId = taxi.Id, PlannedAmount = 6_000 },
            ],
            GoalAllocations = [new() { SavingsGoalId = goal.Id, PlannedAmount = 15_000 }],
        });

        saved.Month.Should().Be("2026-10");
        saved.PeriodStart.Should().Be(D(2026, 10, 5));
        saved.PeriodEnd.Should().Be(D(2026, 11, 4));
        saved.Currency.Should().Be("BYN");
        saved.Lines.Should().HaveCount(2);
        saved.GoalAllocations.Should().ContainSingle().Which.PlannedAmount.Should().Be(15_000);
        var foodLineId = saved.Lines.Single(l => l.CategoryId == food.Id).Id;

        var replaced = await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-10", new BudgetPayload
        {
            ExpectedIncome = 300_000,
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 90_000 }],
        });

        replaced.Id.Should().Be(saved.Id);
        replaced.ExpectedIncome.Should().Be(300_000);
        replaced.Lines.Should().ContainSingle().Which.Should().Match<BudgetLineResponse>(l => l.Id == foodLineId && l.PlannedAmount == 90_000);
        replaced.GoalAllocations.Should().BeEmpty();

        await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-11", new BudgetPayload { ExpectedIncome = 1 });
        (await user.GetAsync<List<BudgetResponse>>("/api/v1/budgets?from=2026-09&to=2026-12")).Select(b => b.Month)
            .Should().Equal("2026-10", "2026-11");

        (await user.Client.DeleteAsync("/api/v1/budgets/2026-10")).StatusCode.Should().Be(HttpStatusCode.NoContent);
        await (await user.Client.GetAsync("/api/v1/budgets/2026-10")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");

        // A deleted month can be planned again.
        await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-10", new BudgetPayload { ExpectedIncome = 5 });
    }

    [Fact]
    public async Task Invalid_budgets_are_rejected()
    {
        var user = await factory.RegisterUserAsync();
        var food = await user.CategoryAsync("Продукты");
        var salary = await user.CategoryAsync("Зарплата", CategoryKind.Income);

        var incomeLine = await user.PutAsync("/api/v1/budgets/2026-10",
            new BudgetPayload { Lines = [new() { CategoryId = salary.Id, PlannedAmount = 1 }] });
        await incomeLine.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_kind_mismatch");

        var duplicate = await user.PutAsync("/api/v1/budgets/2026-10", new BudgetPayload
        {
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 1 }, new() { CategoryId = food.Id, PlannedAmount = 2 }],
        });
        await duplicate.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        var negative = await user.PutAsync("/api/v1/budgets/2026-10", new BudgetPayload { ExpectedIncome = -1 });
        await negative.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");

        (await user.Client.GetAsync("/api/v1/budgets/2026-13")).StatusCode.Should().Be(HttpStatusCode.BadRequest);
        (await user.Client.GetAsync("/api/v1/budgets/october")).StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Summary_of_a_month_with_hierarchy_off_budget_currency_and_rollover()
    {
        await factory.SeedStandardRatesAsync(); // USD = 3.0 BYN
        var user = await UserStartingMonthOnThe5thAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 1_000_000);
        var usd = await user.CreateAccountAsync("USD", "USD", 100_000);
        var food = await user.CategoryAsync("Продукты");
        var transport = await user.CategoryAsync("Транспорт");
        var taxi = await user.CategoryAsync("Такси");
        var cafe = await user.CategoryAsync("Кафе и рестораны");
        var goal = await GoalAsync(user);

        await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-07", new BudgetPayload
        {
            ExpectedIncome = 200_000,
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 50_000, Rollover = true }, new() { CategoryId = transport.Id, PlannedAmount = 10_000 }],
        });
        await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-08", new BudgetPayload
        {
            ExpectedIncome = 290_000,
            Lines =
            [
                new() { CategoryId = food.Id, PlannedAmount = 50_000, Rollover = true },
                new() { CategoryId = transport.Id, PlannedAmount = 15_000 },
                new() { CategoryId = taxi.Id, PlannedAmount = 6_000 },
                new() { CategoryId = cafe.Id, PlannedAmount = 0 },
            ],
            GoalAllocations = [new() { SavingsGoalId = goal.Id, PlannedAmount = 25_000 }],
        });

        // July period: 5 Jul – 4 Aug.
        await user.ExpenseAsync(card.Id, 40_000, D(2026, 7, 10));
        await user.ExpenseAsync(card.Id, 5_000, D(2026, 8, 4));
        await user.IncomeAsync(card.Id, 100, D(2026, 8, 4));
        // August period: 5 Aug – 4 Sep.
        await user.ExpenseAsync(card.Id, 20_000, D(2026, 8, 5));
        await user.ExpenseAsync(usd.Id, 1_000, D(2026, 9, 4)); // 10 USD = 30 BYN
        await user.ExpenseAsync(card.Id, 4_000, D(2026, 8, 10), "Такси");
        await user.ExpenseAsync(card.Id, 2_500, D(2026, 8, 11), "Общественный транспорт");
        await user.ExpenseAsync(card.Id, 500, D(2026, 8, 12), "Транспорт");
        await user.ExpenseAsync(card.Id, 13_600, D(2026, 8, 15), "Одежда");
        await user.ExpenseAsync(card.Id, 9_999, D(2026, 8, 20), status: TransactionStatus.Planned);
        await user.IncomeAsync(card.Id, 241_240, D(2026, 8, 6));
        await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card.Id, ToAccountId = usd.Id, Type = TransactionType.Transfer, Amount = 30_000, ToAmount = 10_000, Date = D(2026, 8, 7),
        });
        // September period, not counted.
        await user.ExpenseAsync(card.Id, 7_000, D(2026, 9, 5));

        var s = await user.GetAsync<BudgetSummaryResponse>("/api/v1/budgets/2026-08/summary");

        s.PeriodStart.Should().Be(D(2026, 8, 5));
        s.PeriodEnd.Should().Be(D(2026, 9, 4));
        s.ExpectedIncome.Should().Be(290_000);
        s.ActualIncome.Should().Be(241_240);
        s.ToSavings.Should().Be(25_000);
        s.Allocated.Should().Be(71_000);
        s.Unallocated.Should().Be(194_000);
        s.IsOverAllocated.Should().BeFalse();

        var foodLine = s.Lines.Single(l => l.CategoryId == food.Id);
        foodLine.CarriedOver.Should().Be(5_000, "July: 50 000 planned − 45 000 spent, rollover on");
        foodLine.Limit.Should().Be(55_000);
        foodLine.Spent.Should().Be(23_000);
        foodLine.Remaining.Should().Be(32_000);

        var transportLine = s.Lines.Single(l => l.CategoryId == transport.Id);
        transportLine.Spent.Should().Be(3_000, "bus has no own line, taxi has");
        transportLine.CarriedOver.Should().Be(0);
        s.Lines.Single(l => l.CategoryId == taxi.Id).Should().Match<BudgetLineSummary>(l => l.Spent == 4_000 && l.Percent == 66.7m);
        s.Lines.Single(l => l.CategoryId == cafe.Id).Should().Match<BudgetLineSummary>(l => l.Spent == 0 && l.Percent == null);

        s.OffBudget.Should().ContainSingle().Which.Should().Be(new OffBudgetItem((await user.CategoryAsync("Одежда")).Id, 13_600));
        s.OffBudgetTotal.Should().Be(13_600);
        s.TotalSpent.Should().Be(43_600);
        s.GoalAllocations.Should().ContainSingle().Which.Should().Match<GoalAllocationSummary>(a =>
            a.SavingsGoalId == goal.Id && a.Planned == 25_000 && a.Recommended == null);
    }

    [Fact]
    public async Task Over_allocated_month_and_line_statuses()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var food = await user.CategoryAsync("Продукты");
        var cafe = await user.CategoryAsync("Кафе и рестораны");
        await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-03", new BudgetPayload
        {
            ExpectedIncome = 10_000,
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 10_000 }, new() { CategoryId = cafe.Id, PlannedAmount = 1_000 }],
        });
        await user.ExpenseAsync(card.Id, 8_500, D(2026, 3, 2));
        await user.ExpenseAsync(card.Id, 1_200, D(2026, 3, 3), "Кафе и рестораны");

        var s = await user.GetAsync<BudgetSummaryResponse>("/api/v1/budgets/2026-03/summary");

        s.Unallocated.Should().Be(-1_000);
        s.IsOverAllocated.Should().BeTrue();
        s.Lines.Single(l => l.CategoryId == food.Id).Status.Should().Be(BudgetLineStatus.Warning);
        s.Lines.Single(l => l.CategoryId == cafe.Id).Should().Match<BudgetLineSummary>(l => l.Status == BudgetLineStatus.Over && l.Remaining == -200);
        s.Lines[0].CategoryId.Should().Be(cafe.Id, "lines are ordered by usage");
        await (await user.Client.GetAsync("/api/v1/budgets/2026-04/summary")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Copy_from_previous_month()
    {
        var user = await factory.RegisterUserAsync();
        var food = await user.CategoryAsync("Продукты");
        var goal = await GoalAsync(user);
        var august = await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-08", new BudgetPayload
        {
            ExpectedIncome = 290_000,
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 80_000, Rollover = true }],
            GoalAllocations = [new() { SavingsGoalId = goal.Id, PlannedAmount = 15_000 }],
        });

        var september = await user.PostAsync<BudgetResponse>("/api/v1/budgets/2026-09/copy-from-previous", new { });

        september.Id.Should().NotBe(august.Id);
        september.ExpectedIncome.Should().Be(290_000);
        september.Lines.Should().ContainSingle().Which.Should().Match<BudgetLineResponse>(l =>
            l.CategoryId == food.Id && l.PlannedAmount == 80_000 && l.Rollover && l.Id != august.Lines[0].Id);
        september.GoalAllocations.Should().ContainSingle().Which.PlannedAmount.Should().Be(15_000);

        await (await user.PostAsync("/api/v1/budgets/2026-09/copy-from-previous", new { }))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "budget_exists");
        await (await user.PostAsync("/api/v1/budgets/2020-01/copy-from-previous", new { }))
            .ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "previous_budget_not_found");
    }

    [Fact]
    public async Task Template_suggests_previous_plan_and_recommended_goal_contributions()
    {
        var user = await UserStartingMonthOnThe5thAsync();
        var food = await user.CategoryAsync("Продукты");
        var cushion = await GoalAsync(user, "Подушка");
        var targetDate = TestApiExtensions.TodayFor().AddMonths(8);
        var vacation = await GoalAsync(user, "Отпуск", targetDate, target: 400_000);
        var today = TestApiExtensions.TodayFor();
        var thisMonth = FinancialMonth.Containing(today, 5);
        var next = thisMonth.Next;
        await user.PutAsync<BudgetResponse>($"/api/v1/budgets/{thisMonth}", new BudgetPayload
        {
            ExpectedIncome = 290_000,
            Lines = [new() { CategoryId = food.Id, PlannedAmount = 80_000 }],
            GoalAllocations = [new() { SavingsGoalId = cushion.Id, PlannedAmount = 15_000 }, new() { SavingsGoalId = vacation.Id, PlannedAmount = 1 }],
        });

        var template = await user.GetAsync<BudgetTemplateResponse>($"/api/v1/budgets/{next}/template");

        template.BasedOnPrevious.Should().BeTrue();
        template.ExpectedIncome.Should().Be(290_000);
        template.Lines.Should().ContainSingle().Which.CategoryId.Should().Be(food.Id);
        var expected = SavingsGoalMath.RecommendedMonthly(400_000, 0, SavingsGoalMath.MonthsLeft(next, targetDate, 5));
        template.GoalAllocations.Single(a => a.SavingsGoalId == vacation.Id).PlannedAmount.Should().Be(expected);
        template.GoalAllocations.Single(a => a.SavingsGoalId == cushion.Id).PlannedAmount.Should().Be(15_000, "undated goals keep the previous amount");

        var summary = await user.GetAsync<BudgetSummaryResponse>($"/api/v1/budgets/{thisMonth}/summary");
        summary.GoalAllocations.Single(a => a.SavingsGoalId == vacation.Id).Recommended
            .Should().Be(SavingsGoalMath.RecommendedMonthly(400_000, 0, SavingsGoalMath.MonthsLeft(thisMonth, targetDate, 5)));

        var empty = await (await factory.RegisterUserAsync()).GetAsync<BudgetTemplateResponse>("/api/v1/budgets/2026-10/template");
        empty.BasedOnPrevious.Should().BeFalse();
        empty.Lines.Should().BeEmpty();
    }

    [Fact]
    public async Task Categories_in_budgets_cannot_be_deleted()
    {
        var user = await factory.RegisterUserAsync();
        var cafe = await user.CategoryAsync("Кафе и рестораны");
        await user.PutAsync<BudgetResponse>("/api/v1/budgets/2026-10",
            new BudgetPayload { Lines = [new() { CategoryId = cafe.Id, PlannedAmount = 30_000 }] });

        await (await user.Client.DeleteAsync($"/api/v1/categories/{cafe.Id}")).ShouldBeProblemAsync(HttpStatusCode.Conflict, "category_in_budget");
    }

    [Fact]
    public async Task Other_users_budgets_and_goals_are_invisible()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var goal = await GoalAsync(alice);
        await alice.PutAsync<BudgetResponse>("/api/v1/budgets/2026-10", new BudgetPayload { ExpectedIncome = 1 });

        await (await bob.Client.GetAsync("/api/v1/budgets/2026-10")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        await (await bob.Client.GetAsync("/api/v1/budgets/2026-10/summary")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");

        var foreignGoal = await bob.PutAsync("/api/v1/budgets/2026-10",
            new BudgetPayload { GoalAllocations = [new() { SavingsGoalId = goal.Id, PlannedAmount = 1 }] });
        await foreignGoal.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "savings_goal_not_found");

        // Bob's own budget for the same month is independent.
        (await bob.PutAsync<BudgetResponse>("/api/v1/budgets/2026-10", new BudgetPayload { ExpectedIncome = 2 })).ExpectedIncome.Should().Be(2);
        (await alice.GetAsync<BudgetResponse>("/api/v1/budgets/2026-10")).ExpectedIncome.Should().Be(1);
    }
}
