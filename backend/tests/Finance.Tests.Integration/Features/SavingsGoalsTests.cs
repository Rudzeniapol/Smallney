using System.Net;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Goals;
using Finance.Domain.Transactions;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class SavingsGoalsTests(ApiFactory factory)
{
    private static readonly DateOnly Day = new(2026, 9, 1);

    private static CreateSavingsGoalRequest Goal(string name = "Отпуск", long target = 400_000, string currency = "BYN") =>
        new() { Name = name, TargetAmount = target, Currency = currency };

    [Fact]
    public async Task Crud_and_completion_date()
    {
        var user = await factory.RegisterUserAsync();

        var created = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal() with { Priority = 1, Color = "#F2C14E" });
        created.Progress.Current.Should().Be(0);
        created.Progress.Percent.Should().Be(0);
        created.Progress.RecommendedMonthly.Should().BeNull();

        var completed = await user.PutAsync<SavingsGoalResponse>($"/api/v1/savings-goals/{created.Id}",
            (SavingsGoalPayload)Goal() with { IsCompleted = true });
        completed.IsCompleted.Should().BeTrue();
        completed.CompletedOn.Should().Be(TestApiExtensions.TodayFor());

        (await user.GetAsync<List<SavingsGoalResponse>>("/api/v1/savings-goals?includeCompleted=false")).Should().BeEmpty();
        (await user.GetAsync<List<SavingsGoalResponse>>("/api/v1/savings-goals")).Should().ContainSingle();

        (await user.Client.DeleteAsync($"/api/v1/savings-goals/{created.Id}")).StatusCode.Should().Be(HttpStatusCode.NoContent);
        await (await user.Client.GetAsync($"/api/v1/savings-goals/{created.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Validation()
    {
        var user = await factory.RegisterUserAsync();

        await (await user.PostAsync("/api/v1/savings-goals", Goal(target: 0))).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.PostAsync("/api/v1/savings-goals", Goal(currency: "XXX"))).ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        await (await user.PostAsync("/api/v1/savings-goals", Goal() with { LinkedAccountId = Guid.CreateVersion7() }))
            .ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "account_not_found");
    }

    [Fact]
    public async Task Progress_from_a_linked_account_is_its_balance_converted()
    {
        await factory.SeedStandardRatesAsync(); // USD = 3.0 BYN
        var user = await factory.RegisterUserAsync();
        var savings = await user.CreateAccountAsync("Накопительный", "USD", 10_000, AccountType.Savings);

        var goal = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals",
            Goal(target: 100_000) with { LinkedAccountId = savings.Id });

        goal.Progress.Current.Should().Be(30_000);
        goal.Progress.Percent.Should().Be(30.0m);
        goal.Progress.Remaining.Should().Be(70_000);
    }

    [Fact]
    public async Task Progress_without_a_link_sums_marked_transfers()
    {
        await factory.SeedStandardRatesAsync();
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync("Карта", initialBalance: 500_000);
        var box = await user.CreateAccountAsync("Копилка");
        var bynGoal = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal());
        var usdGoal = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal("Ноутбук", 100_000, "USD"));

        async Task Transfer(long amount, Guid goalId, TransactionStatus status = TransactionStatus.Cleared) =>
            await user.CreateTransactionAsync(new TransactionPayload
            {
                AccountId = card.Id, ToAccountId = box.Id, Type = TransactionType.Transfer, Amount = amount, Date = Day,
                SavingsGoalId = goalId, Status = status,
            });

        await Transfer(20_000, bynGoal.Id);
        await Transfer(5_000, bynGoal.Id);
        await Transfer(99_999, bynGoal.Id, TransactionStatus.Planned);
        await Transfer(30_000, usdGoal.Id); // 300 BYN = 100 USD

        var goals = (await user.GetAsync<List<SavingsGoalResponse>>("/api/v1/savings-goals")).ToDictionary(g => g.Id);
        goals[bynGoal.Id].Progress.Current.Should().Be(25_000);
        goals[usdGoal.Id].Progress.Current.Should().Be(10_000);
    }

    [Fact]
    public async Task Dated_goal_gets_a_recommended_monthly_contribution()
    {
        var user = await factory.RegisterUserAsync();
        var target = TestApiExtensions.TodayFor().AddMonths(6);

        var goal = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal() with { TargetDate = target });

        var months = SavingsGoalMath.MonthsLeft(FinancialMonth.Containing(TestApiExtensions.TodayFor(), 1), target, 1);
        goal.Progress.MonthsLeft.Should().Be(months);
        goal.Progress.RecommendedMonthly.Should().Be(SavingsGoalMath.RecommendedMonthly(400_000, 0, months));
        goal.Progress.IsOverdue.Should().BeFalse();
    }

    [Fact]
    public async Task Goals_in_use_cannot_be_deleted_and_only_transfers_can_be_marked()
    {
        var user = await factory.RegisterUserAsync();
        var card = await user.CreateAccountAsync();
        var box = await user.CreateAccountAsync("Копилка");
        var goal = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal());
        await user.CreateTransactionAsync(new TransactionPayload
        {
            AccountId = card.Id, ToAccountId = box.Id, Type = TransactionType.Transfer, Amount = 100, Date = Day, SavingsGoalId = goal.Id,
        });

        await (await user.Client.DeleteAsync($"/api/v1/savings-goals/{goal.Id}")).ShouldBeProblemAsync(HttpStatusCode.Conflict, "goal_in_use");

        var food = await user.CategoryAsync("Продукты");
        var expense = await user.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = card.Id, Type = TransactionType.Expense, Amount = 1, CategoryId = food.Id, Date = Day, SavingsGoalId = goal.Id,
        });
        var problem = await expense.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        problem.Extensions["errorCodes"]!.ToString().Should().Contain("savings_goal_only_for_transfers");
    }

    [Fact]
    public async Task Deleting_a_linked_account_unlinks_the_goal()
    {
        var user = await factory.RegisterUserAsync();
        var savings = await user.CreateAccountAsync("Накопительный", type: AccountType.Savings);
        var goal = await user.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal() with { LinkedAccountId = savings.Id });

        await user.Client.DeleteAsync($"/api/v1/accounts/{savings.Id}");

        (await user.GetAsync<SavingsGoalResponse>($"/api/v1/savings-goals/{goal.Id}")).LinkedAccountId.Should().BeNull();
    }

    [Fact]
    public async Task Other_users_goals_are_invisible()
    {
        var (alice, bob) = (await factory.RegisterUserAsync(), await factory.RegisterUserAsync());
        var goal = await alice.PostAsync<SavingsGoalResponse>("/api/v1/savings-goals", Goal());
        var card = await bob.CreateAccountAsync();
        var box = await bob.CreateAccountAsync("Копилка");

        await (await bob.Client.GetAsync($"/api/v1/savings-goals/{goal.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
        (await bob.GetAsync<List<SavingsGoalResponse>>("/api/v1/savings-goals")).Should().BeEmpty();

        var markForeign = await bob.PostAsync("/api/v1/transactions", new CreateTransactionRequest
        {
            AccountId = card.Id, ToAccountId = box.Id, Type = TransactionType.Transfer, Amount = 1, Date = Day, SavingsGoalId = goal.Id,
        });
        await markForeign.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "savings_goal_not_found");

        var link = await alice.PostAsync("/api/v1/savings-goals", Goal() with { LinkedAccountId = card.Id });
        await link.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "account_not_found");
    }
}
