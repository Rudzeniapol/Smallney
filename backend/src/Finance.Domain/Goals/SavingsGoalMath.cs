using Finance.Domain.Budgets;

namespace Finance.Domain.Goals;

public sealed record GoalProgress(
    long Current,
    long Remaining,
    decimal Percent,
    int? MonthsLeft,
    long? RecommendedMonthly,
    bool IsOverdue);

public static class SavingsGoalMath
{
    /// <summary>
    /// Monthly contributions still possible before the target date: from <paramref name="month"/> up to, but not
    /// including, the financial month that contains the target date. At least 1 (everything is due now).
    /// </summary>
    public static int MonthsLeft(FinancialMonth month, DateOnly targetDate, int firstDayOfMonth) =>
        Math.Max(1, month.MonthsUntil(FinancialMonth.Containing(targetDate, firstDayOfMonth)));

    /// <summary>(Target − Current) / months left, rounded up to a whole minor unit so the target is reached.</summary>
    public static long RecommendedMonthly(long target, long current, int monthsLeft)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(monthsLeft, 1);
        var remaining = Math.Max(0, target - current);
        return (remaining + monthsLeft - 1) / monthsLeft;
    }

    public static GoalProgress Progress(SavingsGoal goal, long current, DateOnly today, int firstDayOfMonth) =>
        Progress(goal, current, today, FinancialMonth.Containing(today, firstDayOfMonth), firstDayOfMonth);

    /// <param name="month">The month the recommendation is for (e.g. the budget being planned).</param>
    public static GoalProgress Progress(SavingsGoal goal, long current, DateOnly today, FinancialMonth month, int firstDayOfMonth)
    {
        var remaining = Math.Max(0, goal.TargetAmount - current);
        var percent = goal.TargetAmount > 0
            ? Math.Min(100m, Math.Round(Math.Max(0, current) * 100m / goal.TargetAmount, 1, MidpointRounding.ToEven))
            : 100m;

        if (goal.TargetDate is not { } targetDate || goal.IsCompleted)
        {
            return new GoalProgress(current, remaining, percent, null, null, false);
        }

        var months = MonthsLeft(month, targetDate, firstDayOfMonth);
        return new GoalProgress(
            current,
            remaining,
            percent,
            months,
            RecommendedMonthly(goal.TargetAmount, current, months),
            IsOverdue: targetDate < today && remaining > 0);
    }
}
