using Finance.Domain.Common;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;

namespace Finance.Tests.Unit.Domain;

public class RecurrenceScheduleTests
{
    private static DateOnly D(int y, int m, int d) => new(y, m, d);

    private static List<DateOnly> Run(RecurrenceSchedule s, DateOnly from, DateOnly to) => s.Occurrences(from, to).ToList();

    [Fact]
    public void Daily_every_day()
    {
        var s = new RecurrenceSchedule(Frequency.Daily, 1, D(2026, 1, 30));
        Run(s, D(2026, 1, 1), D(2026, 2, 2)).Should().Equal(D(2026, 1, 30), D(2026, 1, 31), D(2026, 2, 1), D(2026, 2, 2));
    }

    [Fact]
    public void Daily_with_interval_keeps_the_cadence_from_start_date()
    {
        var s = new RecurrenceSchedule(Frequency.Daily, 3, D(2026, 1, 1));
        // 1, 4, 7, 10, 13 … — querying from the 8th must not shift the cadence.
        Run(s, D(2026, 1, 8), D(2026, 1, 16)).Should().Equal(D(2026, 1, 10), D(2026, 1, 13), D(2026, 1, 16));
    }

    [Fact]
    public void Daily_far_in_the_future_skips_ahead()
    {
        var s = new RecurrenceSchedule(Frequency.Daily, 7, D(2000, 1, 3));
        Run(s, D(2026, 10, 1), D(2026, 10, 14)).Should().HaveCount(2).And.OnlyContain(d => d.DayOfWeek == DayOfWeek.Monday);
    }

    [Fact]
    public void Weekly_defaults_to_the_start_weekday()
    {
        var s = new RecurrenceSchedule(Frequency.Weekly, 1, D(2026, 10, 7)); // Wednesday
        Run(s, D(2026, 10, 1), D(2026, 10, 31)).Should().Equal(D(2026, 10, 7), D(2026, 10, 14), D(2026, 10, 21), D(2026, 10, 28));
    }

    [Fact]
    public void Weekly_on_another_weekday_starts_with_the_first_one_on_or_after_start()
    {
        var s = new RecurrenceSchedule(Frequency.Weekly, 1, D(2026, 10, 7), DayOfWeek: DayOfWeek.Monday);
        Run(s, D(2026, 10, 1), D(2026, 10, 20)).Should().Equal(D(2026, 10, 12), D(2026, 10, 19));
    }

    [Fact]
    public void Biweekly_keeps_its_phase()
    {
        var s = new RecurrenceSchedule(Frequency.Weekly, 2, D(2026, 1, 2), DayOfWeek: DayOfWeek.Friday); // Fri 2 Jan
        Run(s, D(2026, 1, 10), D(2026, 2, 13)).Should().Equal(D(2026, 1, 16), D(2026, 1, 30), D(2026, 2, 13));
    }

    [Fact]
    public void Monthly_defaults_to_the_start_day()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 15));
        Run(s, D(2026, 1, 1), D(2026, 4, 30)).Should().Equal(D(2026, 1, 15), D(2026, 2, 15), D(2026, 3, 15), D(2026, 4, 15));
    }

    [Fact]
    public void Monthly_on_the_31st_falls_on_the_last_day_of_short_months()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 31));
        Run(s, D(2026, 1, 1), D(2026, 6, 30)).Should().Equal(
            D(2026, 1, 31), D(2026, 2, 28), D(2026, 3, 31), D(2026, 4, 30), D(2026, 5, 31), D(2026, 6, 30));
    }

    [Fact]
    public void Monthly_on_the_30th_uses_29_february_in_leap_years()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2028, 1, 1), DayOfMonth: 30);
        Run(s, D(2028, 2, 1), D(2028, 3, 31)).Should().Equal(D(2028, 2, 29), D(2028, 3, 30));
    }

    [Fact]
    public void Monthly_day_before_the_start_day_begins_next_month()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 20), DayOfMonth: 5);
        Run(s, D(2026, 1, 1), D(2026, 3, 31)).Should().Equal(D(2026, 2, 5), D(2026, 3, 5));
    }

    [Fact]
    public void Monthly_interval_is_anchored_at_the_start_month()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 3, D(2026, 1, 10)); // quarterly: Jan, Apr, Jul, Oct
        Run(s, D(2026, 2, 1), D(2026, 12, 31)).Should().Equal(D(2026, 4, 10), D(2026, 7, 10), D(2026, 10, 10));
    }

    [Fact]
    public void Monthly_interval_skips_an_anchor_month_before_start()
    {
        // Every 2 months from Jan; Jan's day 5 is before the start, so the first one is in March.
        var s = new RecurrenceSchedule(Frequency.Monthly, 2, D(2026, 1, 20), DayOfMonth: 5);
        Run(s, D(2026, 1, 1), D(2026, 7, 31)).Should().Equal(D(2026, 3, 5), D(2026, 5, 5), D(2026, 7, 5));
    }

    [Fact]
    public void Yearly_on_29_february_falls_on_28_february_in_other_years()
    {
        var s = new RecurrenceSchedule(Frequency.Yearly, 1, D(2024, 2, 29));
        Run(s, D(2024, 1, 1), D(2028, 12, 31)).Should().Equal(
            D(2024, 2, 29), D(2025, 2, 28), D(2026, 2, 28), D(2027, 2, 28), D(2028, 2, 29));
    }

    [Fact]
    public void Yearly_with_interval()
    {
        var s = new RecurrenceSchedule(Frequency.Yearly, 2, D(2026, 3, 1));
        Run(s, D(2026, 1, 1), D(2031, 12, 31)).Should().Equal(D(2026, 3, 1), D(2028, 3, 1), D(2030, 3, 1));
    }

    [Fact]
    public void Yearly_with_explicit_day_of_month()
    {
        var s = new RecurrenceSchedule(Frequency.Yearly, 1, D(2026, 4, 1), DayOfMonth: 31); // April has 30 days
        Run(s, D(2026, 1, 1), D(2027, 12, 31)).Should().Equal(D(2026, 4, 30), D(2027, 4, 30));
    }

    [Fact]
    public void End_date_is_inclusive()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 10), EndDate: D(2026, 3, 10));
        Run(s, D(2026, 1, 1), D(2026, 12, 31)).Should().Equal(D(2026, 1, 10), D(2026, 2, 10), D(2026, 3, 10));
    }

    [Fact]
    public void End_date_cuts_the_last_month_short()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 10), EndDate: D(2026, 3, 9));
        Run(s, D(2026, 1, 1), D(2026, 12, 31)).Should().Equal(D(2026, 1, 10), D(2026, 2, 10));
    }

    [Fact]
    public void Nothing_before_start_after_end_or_in_an_inverted_range()
    {
        var s = new RecurrenceSchedule(Frequency.Daily, 1, D(2026, 5, 1), EndDate: D(2026, 5, 31));
        Run(s, D(2026, 1, 1), D(2026, 4, 30)).Should().BeEmpty();
        Run(s, D(2026, 6, 1), D(2026, 6, 30)).Should().BeEmpty();
        Run(s, D(2026, 5, 10), D(2026, 5, 9)).Should().BeEmpty();
    }

    [Fact]
    public void Range_bounds_are_inclusive()
    {
        var s = new RecurrenceSchedule(Frequency.Weekly, 1, D(2026, 10, 5));
        Run(s, D(2026, 10, 12), D(2026, 10, 19)).Should().Equal(D(2026, 10, 12), D(2026, 10, 19));
    }

    [Fact]
    public void Invalid_interval_throws()
    {
        var s = new RecurrenceSchedule(Frequency.Daily, 0, D(2026, 1, 1));
        var act = () => s.Occurrences(D(2026, 1, 1), D(2026, 1, 2)).ToList();
        act.Should().Throw<ArgumentOutOfRangeException>();
    }

    [Fact]
    public void Next_occurrence()
    {
        var s = new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 31));
        s.NextOccurrence(D(2026, 2, 1)).Should().Be(D(2026, 2, 28));
        new RecurrenceSchedule(Frequency.Monthly, 1, D(2026, 1, 1), EndDate: D(2026, 2, 1)).NextOccurrence(D(2026, 2, 2)).Should().BeNull();
    }
}

public class RecurringRuleTests
{
    [Fact]
    public void Occurrence_ids_are_deterministic_v7_and_distinct()
    {
        var rule = UuidV7.New();
        var a = RecurringRule.OccurrenceTransactionId(rule, new DateOnly(2026, 10, 22));

        a.Should().Be(RecurringRule.OccurrenceTransactionId(rule, new DateOnly(2026, 10, 22)));
        a.Should().NotBe(RecurringRule.OccurrenceTransactionId(rule, new DateOnly(2026, 10, 23)));
        a.Should().NotBe(RecurringRule.OccurrenceTransactionId(UuidV7.New(), new DateOnly(2026, 10, 22)));
        UuidV7.IsValid(a).Should().BeTrue();
    }

    [Fact]
    public void Deterministic_uuid_encodes_the_date_as_timestamp()
    {
        // 1970-01-02T00:00:00Z = 86 400 000 ms = 0x0000_0526_5C00 in the first 48 bits.
        var id = UuidV7.Deterministic(new DateOnly(1970, 1, 2), "seed");
        id.ToString().Should().StartWith("00000526-5c00-7");
    }

    [Fact]
    public void Materialize_copies_the_template_as_planned()
    {
        var rule = new RecurringRule
        {
            Id = UuidV7.New(), UserId = UuidV7.New(), Name = "Мобильная связь", AccountId = UuidV7.New(),
            Type = TransactionType.Expense, Amount = 1850, CategoryId = UuidV7.New(), Tags = ["связь"],
            Frequency = Frequency.Monthly, StartDate = new DateOnly(2026, 1, 22),
        };

        var t = rule.Materialize(new DateOnly(2026, 10, 22));

        t.Id.Should().Be(RecurringRule.OccurrenceTransactionId(rule.Id, new DateOnly(2026, 10, 22)));
        t.Status.Should().Be(TransactionStatus.Planned);
        t.Note.Should().Be("Мобильная связь", "the rule name is used when there is no note");
        t.RecurringRuleId.Should().Be(rule.Id);
        t.RecurrenceDate.Should().Be(new DateOnly(2026, 10, 22));
        t.Amount.Should().Be(1850);
        t.Tags.Should().Equal("связь").And.NotBeSameAs(rule.Tags);
        rule.Schedule.Frequency.Should().Be(Frequency.Monthly);
    }
}
