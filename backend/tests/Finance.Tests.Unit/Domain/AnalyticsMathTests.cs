using Finance.Domain.Analytics;
using Finance.Domain.Monetary;

namespace Finance.Tests.Unit.Domain;

public class AnalyticsMathTests
{
    private static DateOnly D(int y, int m, int d) => new(y, m, d);

    [Fact]
    public void Whole_month_is_compared_with_the_previous_month()
    {
        AnalyticsMath.PreviousPeriod(new Period(D(2026, 10, 5), D(2026, 11, 4)), 5).Should().Be(new Period(D(2026, 9, 5), D(2026, 10, 4)));
        AnalyticsMath.PreviousPeriod(new Period(D(2026, 3, 1), D(2026, 3, 31)), 1).Should().Be(new Period(D(2026, 2, 1), D(2026, 2, 28)));
    }

    [Fact]
    public void Month_to_date_is_compared_with_the_same_days_of_the_previous_month()
    {
        AnalyticsMath.PreviousPeriod(new Period(D(2026, 10, 5), D(2026, 10, 22)), 5).Should().Be(new Period(D(2026, 9, 5), D(2026, 9, 22)));
        // 31 March to date vs February: capped at the end of February.
        AnalyticsMath.PreviousPeriod(new Period(D(2026, 3, 1), D(2026, 3, 30)), 1).Should().Be(new Period(D(2026, 2, 1), D(2026, 2, 28)));
    }

    [Fact]
    public void Quarter_is_compared_with_the_previous_quarter()
    {
        AnalyticsMath.PreviousPeriod(new Period(D(2026, 7, 1), D(2026, 9, 30)), 1).Should().Be(new Period(D(2026, 4, 1), D(2026, 6, 30)));
    }

    [Fact]
    public void Arbitrary_period_is_compared_with_the_same_number_of_days_before()
    {
        AnalyticsMath.PreviousPeriod(new Period(D(2026, 10, 10), D(2026, 10, 19)), 1).Should().Be(new Period(D(2026, 9, 30), D(2026, 10, 9)));
        new Period(D(2026, 10, 10), D(2026, 10, 19)).Days.Should().Be(10);
    }

    [Theory]
    [InlineData(131_200, 143_200, "-8.4")]
    [InlineData(150, 100, "50.0")]
    [InlineData(100, 0, null)]
    [InlineData(-50, -100, "50.0")]
    public void Change_percent(long current, long previous, string? expected)
    {
        AnalyticsMath.ChangePercent(current, previous).Should().Be(expected is null ? null : decimal.Parse(expected, System.Globalization.CultureInfo.InvariantCulture));
    }

    [Fact]
    public void Share()
    {
        AnalyticsMath.Share(592, 1_312).Should().Be(45.1m);
        AnalyticsMath.Share(1, 0).Should().Be(0);
    }

    [Fact]
    public void Averages_count_only_elapsed_days()
    {
        var total = new Money(131_200, Currency.Byn); // 1 312 BYN in 18 days so far
        var averages = AnalyticsMath.Averages(total, new Period(D(2026, 10, 5), D(2026, 11, 4)), D(2026, 10, 22));

        averages.Days.Should().Be(18);
        averages.PerDay.Should().Be(7_289);     // 72.888…
        averages.PerWeek.Should().Be(51_022);   // 510.22
        averages.PerMonth.Should().Be(221_856); // 72.888… × 30.4375 = 2 218.556
        averages.Total.Should().Be(131_200);
    }

    [Fact]
    public void Averages_of_a_past_period_and_of_a_future_one()
    {
        AnalyticsMath.Averages(new Money(3_000, Currency.Byn), new Period(D(2026, 1, 1), D(2026, 1, 3)), D(2026, 10, 1)).PerDay.Should().Be(1_000);
        AnalyticsMath.Averages(new Money(0, Currency.Byn), new Period(D(2027, 1, 1), D(2027, 1, 3)), D(2026, 10, 1)).Days.Should().Be(1);
    }
}
