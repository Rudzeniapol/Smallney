using Finance.Domain.Budgets;
using Finance.Domain.Common;
using Finance.Domain.Goals;

namespace Finance.Tests.Unit.Domain;

public class FinancialMonthTests
{
    [Theory]
    [InlineData("2026-10-04", 5, "2026-09")]
    [InlineData("2026-10-05", 5, "2026-10")]
    [InlineData("2026-01-03", 5, "2025-12")]
    [InlineData("2026-10-01", 1, "2026-10")]
    public void Containing_respects_the_first_day(string date, int firstDay, string expected)
    {
        FinancialMonth.Containing(DateOnly.Parse(date), firstDay).ToString().Should().Be(expected);
    }

    [Fact]
    public void Period_bounds()
    {
        var october = new FinancialMonth(2026, 10);
        october.Start(5).Should().Be(new DateOnly(2026, 10, 5));
        october.End(5).Should().Be(new DateOnly(2026, 11, 4));
        new FinancialMonth(2026, 12).End(1).Should().Be(new DateOnly(2026, 12, 31));
        new FinancialMonth(2026, 1).End(28).Should().Be(new DateOnly(2026, 2, 27));
    }

    [Fact]
    public void Arithmetic_and_comparison()
    {
        var m = new FinancialMonth(2026, 1);
        m.Previous.Should().Be(new FinancialMonth(2025, 12));
        m.Next.Should().Be(new FinancialMonth(2026, 2));
        m.AddMonths(14).Should().Be(new FinancialMonth(2027, 3));
        m.MonthsUntil(new FinancialMonth(2027, 3)).Should().Be(14);
        new FinancialMonth(2027, 3).MonthsUntil(m).Should().Be(-14);
        (m < m.Next).Should().BeTrue();
        (m.Next > m).Should().BeTrue();
        (m <= m).Should().BeTrue();
        (m >= m.Previous).Should().BeTrue();
        m.FirstCalendarDay.Should().Be(new DateOnly(2026, 1, 1));
        FinancialMonth.FromCalendarDay(new DateOnly(2026, 1, 31)).Should().Be(m);
    }

    [Theory]
    [InlineData("2026-10", true)]
    [InlineData("2026-13", false)]
    [InlineData("2026-1", false)]
    [InlineData("oct", false)]
    [InlineData(null, false)]
    public void Parses_yyyy_MM(string? text, bool valid)
    {
        FinancialMonth.TryParse(text, null, out var month).Should().Be(valid);
        if (valid)
        {
            month.ToString().Should().Be(text);
            FinancialMonth.Parse(text!, null).Should().Be(month);
        }
    }

    [Fact]
    public void Parse_throws_on_garbage()
    {
        var act = () => FinancialMonth.Parse("x", null);
        act.Should().Throw<FormatException>();
        ((Action)(() => _ = new FinancialMonth(2026, 13))).Should().Throw<ArgumentOutOfRangeException>();
    }
}

public class BudgetCalculatorTests
{
    private static readonly Guid Food = UuidV7.New();
    private static readonly Guid Transport = UuidV7.New();
    private static readonly Guid Taxi = UuidV7.New();
    private static readonly Guid Bus = UuidV7.New();
    private static readonly Guid Clothes = UuidV7.New();

    private static readonly Dictionary<Guid, Guid?> Parents = new()
    {
        [Food] = null, [Transport] = null, [Taxi] = Transport, [Bus] = Transport, [Clothes] = null,
    };

    private static BudgetMonthInput Month(
        long income,
        IEnumerable<BudgetLineInput> lines,
        Dictionary<Guid, long> spent,
        long actualIncome = 0,
        IEnumerable<BudgetAllocationInput>? allocations = null) =>
        new(income, actualIncome, lines.ToList(), (allocations ?? []).ToList(), spent, Parents);

    private static BudgetLineInput Line(Guid category, long planned, bool rollover = false) => new(UuidV7.New(), category, planned, rollover);

    [Fact]
    public void Income_split_into_savings_lines_and_unallocated()
    {
        var result = BudgetCalculator.Calculate(Month(
            290_000,
            [Line(Food, 80_000), Line(Transport, 15_000)],
            [],
            actualIncome: 241_240,
            allocations: [new(UuidV7.New(), UuidV7.New(), 25_000), new(UuidV7.New(), UuidV7.New(), 15_000)]));

        result.ExpectedIncome.Should().Be(290_000);
        result.ActualIncome.Should().Be(241_240);
        result.ToSavings.Should().Be(40_000);
        result.Allocated.Should().Be(95_000);
        result.Unallocated.Should().Be(155_000);
        result.IsOverAllocated.Should().BeFalse();
    }

    [Fact]
    public void Over_allocation_is_negative_and_flagged()
    {
        var result = BudgetCalculator.Calculate(Month(100_000, [Line(Food, 90_000)], [],
            allocations: [new(UuidV7.New(), UuidV7.New(), 20_000)]));

        result.Unallocated.Should().Be(-10_000);
        result.IsOverAllocated.Should().BeTrue();
    }

    [Fact]
    public void Parent_line_includes_children_without_own_lines()
    {
        var result = BudgetCalculator.Calculate(Month(0, [Line(Transport, 15_000)],
            new() { [Transport] = 1_000, [Taxi] = 5_000, [Bus] = 2_700 }));

        result.Lines.Single().Spent.Should().Be(8_700);
        result.OffBudget.Should().BeEmpty();
    }

    [Fact]
    public void Child_line_takes_its_own_spending_so_nothing_is_counted_twice()
    {
        var result = BudgetCalculator.Calculate(Month(0, [Line(Transport, 15_000), Line(Taxi, 6_000)],
            new() { [Transport] = 1_000, [Taxi] = 5_000, [Bus] = 2_700 }));

        result.Lines.Single(l => l.CategoryId == Transport).Spent.Should().Be(3_700);
        result.Lines.Single(l => l.CategoryId == Taxi).Spent.Should().Be(5_000);
        result.TotalSpent.Should().Be(8_700);
    }

    [Fact]
    public void Categories_without_lines_are_off_budget()
    {
        var result = BudgetCalculator.Calculate(Month(0, [Line(Food, 80_000)],
            new() { [Food] = 59_200, [Clothes] = 13_600, [Taxi] = 6_120, [Bus] = 0 }));

        result.OffBudget.Should().Equal(new OffBudgetSpending(Clothes, 13_600), new OffBudgetSpending(Taxi, 6_120));
        result.OffBudgetTotal.Should().Be(19_720);
        result.TotalSpent.Should().Be(78_920);
    }

    [Theory]
    [InlineData(0, BudgetLineStatus.Ok, "0")]
    [InlineData(7_999, BudgetLineStatus.Ok, "80.0")] // 79.99% → shown as 80.0 but still below the threshold
    [InlineData(8_000, BudgetLineStatus.Warning, "80.0")]
    [InlineData(10_000, BudgetLineStatus.Warning, "100.0")]
    [InlineData(10_001, BudgetLineStatus.Over, "100.0")]
    [InlineData(15_000, BudgetLineStatus.Over, "150.0")]
    public void Status_thresholds(long spent, BudgetLineStatus status, string percent)
    {
        var line = BudgetCalculator.Calculate(Month(0, [Line(Food, 10_000)], new() { [Food] = spent })).Lines.Single();

        line.Status.Should().Be(status);
        line.Percent.Should().Be(decimal.Parse(percent, System.Globalization.CultureInfo.InvariantCulture));
        line.Remaining.Should().Be(10_000 - spent);
    }

    [Fact]
    public void Zero_limit_has_no_percent()
    {
        var lines = BudgetCalculator.Calculate(Month(0, [Line(Food, 0), Line(Clothes, 0)], new() { [Food] = 100 })).Lines;

        lines.Single(l => l.CategoryId == Food).Should().Match<BudgetLineResult>(l => l.Percent == null && l.Status == BudgetLineStatus.Over);
        lines.Single(l => l.CategoryId == Clothes).Should().Match<BudgetLineResult>(l => l.Percent == null && l.Status == BudgetLineStatus.Ok);
    }

    [Fact]
    public void Rollover_carries_the_unspent_remainder_into_the_next_month()
    {
        var september = Month(0, [Line(Food, 10_000, rollover: true), Line(Clothes, 5_000)], new() { [Food] = 7_500, [Clothes] = 1_000 });
        var october = Month(0, [Line(Food, 10_000, rollover: true), Line(Clothes, 5_000)], new() { [Food] = 11_000 });

        var result = BudgetCalculator.CalculateChain([september, october])!;

        var food = result.Lines.Single(l => l.CategoryId == Food);
        food.CarriedOver.Should().Be(2_500);
        food.Limit.Should().Be(12_500);
        food.Remaining.Should().Be(1_500);
        food.Percent.Should().Be(88.0m);
        result.Lines.Single(l => l.CategoryId == Clothes).CarriedOver.Should().Be(0, "rollover is off for that line");
    }

    [Fact]
    public void Rollover_chains_over_several_months_and_never_carries_overspending()
    {
        var m1 = Month(0, [Line(Food, 10_000, true)], new() { [Food] = 6_000 });  // +4 000
        var m2 = Month(0, [Line(Food, 10_000, true)], new() { [Food] = 9_000 });  // limit 14 000, +5 000
        var m3 = Month(0, [Line(Food, 10_000, true)], new() { [Food] = 20_000 }); // limit 15 000, overspent
        var m4 = Month(0, [Line(Food, 10_000, true)], []);

        BudgetCalculator.CalculateChain([m1, m2])!.Lines.Single().Remaining.Should().Be(5_000);
        BudgetCalculator.CalculateChain([m1, m2, m3])!.Lines.Single().Limit.Should().Be(15_000);
        BudgetCalculator.CalculateChain([m1, m2, m3, m4])!.Lines.Single().CarriedOver.Should().Be(0);
    }

    [Fact]
    public void A_missing_month_breaks_the_chain()
    {
        var m1 = Month(0, [Line(Food, 10_000, true)], []);
        var m3 = Month(0, [Line(Food, 10_000, true)], []);

        BudgetCalculator.CalculateChain([m1, null, m3])!.Lines.Single().CarriedOver.Should().Be(0);
        BudgetCalculator.CalculateChain([m1, null]).Should().BeNull();
    }

    [Fact]
    public void Carry_over_is_lost_when_the_next_month_has_no_line()
    {
        var m1 = Month(0, [Line(Food, 10_000, true)], []);
        var m2 = Month(0, [Line(Clothes, 1_000)], []);

        BudgetCalculator.CalculateChain([m1, m2])!.Lines.Single().CarriedOver.Should().Be(0);
    }
}

public class SavingsGoalMathTests
{
    private static readonly DateOnly Today = new(2026, 10, 22);

    [Theory]
    [InlineData("2027-07-01", 5, 8)]   // 5th-day months: Oct…May, July 1 belongs to the June period
    [InlineData("2027-07-01", 1, 9)]   // Oct…Jun
    [InlineData("2026-11-15", 1, 1)]   // next month
    [InlineData("2026-10-30", 1, 1)]   // this month → everything now
    [InlineData("2025-01-01", 1, 1)]   // overdue → everything now
    public void Months_left(string target, int firstDay, int expected)
    {
        SavingsGoalMath.MonthsLeft(FinancialMonth.Containing(Today, firstDay), DateOnly.Parse(target), firstDay).Should().Be(expected);
    }

    [Theory]
    [InlineData(400_000, 208_000, 8, 24_000)]
    [InlineData(320_000, 110_000, 4, 52_500)]
    [InlineData(100, 0, 3, 34)]          // rounded up: 3 × 34 ≥ 100
    [InlineData(100, 150, 3, 0)]         // already reached
    public void Recommended_monthly(long target, long current, int months, long expected)
    {
        SavingsGoalMath.RecommendedMonthly(target, current, months).Should().Be(expected);
    }

    [Fact]
    public void Recommended_monthly_rejects_zero_months()
    {
        var act = () => SavingsGoalMath.RecommendedMonthly(1, 0, 0);
        act.Should().Throw<ArgumentOutOfRangeException>();
    }

    [Fact]
    public void Progress_of_a_dated_goal()
    {
        var goal = new SavingsGoal { TargetAmount = 400_000, TargetDate = new DateOnly(2027, 7, 1) };

        var p = SavingsGoalMath.Progress(goal, 208_000, Today, firstDayOfMonth: 5);

        p.Percent.Should().Be(52.0m);
        p.Remaining.Should().Be(192_000);
        p.MonthsLeft.Should().Be(8);
        p.RecommendedMonthly.Should().Be(24_000);
        p.IsOverdue.Should().BeFalse();
    }

    [Fact]
    public void Undated_and_completed_goals_have_no_recommendation()
    {
        var open = SavingsGoalMath.Progress(new SavingsGoal { TargetAmount = 750_000 }, 360_000, Today, 1);
        open.RecommendedMonthly.Should().BeNull();
        open.MonthsLeft.Should().BeNull();
        open.Percent.Should().Be(48.0m);

        var done = SavingsGoalMath.Progress(
            new SavingsGoal { TargetAmount = 60_000, TargetDate = new DateOnly(2026, 9, 1), IsCompleted = true }, 60_000, Today, 1);
        done.RecommendedMonthly.Should().BeNull();
        done.IsOverdue.Should().BeFalse();
    }

    [Fact]
    public void Overdue_goal_and_percent_bounds()
    {
        var goal = new SavingsGoal { TargetAmount = 1_000, TargetDate = new DateOnly(2026, 1, 1) };

        var behind = SavingsGoalMath.Progress(goal, 400, Today, 1);
        behind.IsOverdue.Should().BeTrue();
        behind.RecommendedMonthly.Should().Be(600);

        SavingsGoalMath.Progress(goal, 5_000, Today, 1).Percent.Should().Be(100m);
        SavingsGoalMath.Progress(goal, -50, Today, 1).Percent.Should().Be(0m);
        SavingsGoalMath.Progress(new SavingsGoal { TargetAmount = 0 }, 0, Today, 1).Percent.Should().Be(100m);
    }
}
