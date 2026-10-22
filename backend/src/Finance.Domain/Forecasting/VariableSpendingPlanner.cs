using Finance.Domain.Budgets;

namespace Finance.Domain.Forecasting;

/// <summary>A budget line as the planner sees it (amounts in the base currency).</summary>
/// <param name="Amount">Remaining limit for the current month, planned amount for a future month.</param>
public sealed record PlannerLine(Guid CategoryId, long Amount);

/// <summary>An explicitly simulated expense (planned or recurring) that a budget line already contains.</summary>
public sealed record ScheduledExpense(DateOnly Date, Guid CategoryId, long Amount);

/// <param name="CurrentBudgetLines">Remaining limits of the current month's budget, or null when there is no budget.</param>
/// <param name="FutureBudgetLines">Planned lines of future months that have a budget.</param>
/// <param name="HistoryMonths">Spending per category of the last full months, without rule-generated transactions.</param>
/// <param name="SpentThisMonth">Spending per category of the current month so far, without rule-generated transactions.</param>
public sealed record SpendingPlannerInput(
    DateOnly Today,
    DateOnly End,
    int FirstDayOfMonth,
    IReadOnlyList<PlannerLine>? CurrentBudgetLines,
    IReadOnlyDictionary<FinancialMonth, IReadOnlyList<PlannerLine>> FutureBudgetLines,
    IReadOnlyList<IReadOnlyDictionary<Guid, long>> HistoryMonths,
    IReadOnlyDictionary<Guid, long> SpentThisMonth,
    IReadOnlyList<ScheduledExpense> ScheduledExpenses,
    IReadOnlyDictionary<Guid, Guid?> CategoryParents);

/// <summary>
/// Expected variable spending per financial month of the horizon:
/// <list type="bullet">
/// <item>current month with a budget: Σ max(0, line remaining − scheduled expenses of the line still due this month),
/// spread over the remaining days;</item>
/// <item>future month with a budget: Σ max(0, line planned − scheduled expenses of the line in that month);</item>
/// <item>month without a budget: Σ per category of the median of the last full months (which exclude rule-generated
/// spending, simulated separately); for the current month minus what was already spent.</item>
/// </list>
/// A scheduled expense belongs to the line of its category, else to the line of the parent category.
/// </summary>
public static class VariableSpendingPlanner
{
    public static IReadOnlyList<VariableSpendingMonth> Plan(SpendingPlannerInput input)
    {
        var result = new List<VariableSpendingMonth>();
        var current = FinancialMonth.Containing(input.Today, input.FirstDayOfMonth);
        var last = FinancialMonth.Containing(input.End, input.FirstDayOfMonth);
        var medians = Medians(input.HistoryMonths);

        for (var month = current; month <= last; month = month.Next)
        {
            var isCurrent = month == current;
            var start = isCurrent ? input.Today : month.Start(input.FirstDayOfMonth);
            var end = month.End(input.FirstDayOfMonth);
            var scheduled = input.ScheduledExpenses.Where(e => e.Date >= start && e.Date <= end).ToList();

            long total;
            VariableSpendingSource source;
            var lines = isCurrent ? input.CurrentBudgetLines : input.FutureBudgetLines.GetValueOrDefault(month);
            if (lines is not null)
            {
                total = FromBudget(lines, scheduled, input.CategoryParents);
                source = isCurrent ? VariableSpendingSource.CurrentBudget : VariableSpendingSource.Budget;
            }
            else
            {
                total = medians.Sum(m => Math.Max(0, m.Value - (isCurrent ? input.SpentThisMonth.GetValueOrDefault(m.Key) : 0)));
                source = VariableSpendingSource.History;
            }

            result.Add(new VariableSpendingMonth(month, start, end, total, source));
        }

        return result;
    }

    /// <summary>Median per category; a month without spending in a category counts as zero.</summary>
    public static Dictionary<Guid, long> Medians(IReadOnlyList<IReadOnlyDictionary<Guid, long>> months)
    {
        if (months.Count == 0)
        {
            return [];
        }

        return months
            .SelectMany(m => m.Keys)
            .Distinct()
            .ToDictionary(category => category, category => Median(months.Select(m => m.GetValueOrDefault(category))));
    }

    public static long Median(IEnumerable<long> values)
    {
        var sorted = values.Order().ToArray();
        if (sorted.Length == 0)
        {
            return 0;
        }

        var middle = sorted.Length / 2;
        return sorted.Length % 2 == 1
            ? sorted[middle]
            : (long)Math.Round((sorted[middle - 1] + sorted[middle]) / 2m, MidpointRounding.ToEven);
    }

    private static long FromBudget(
        IReadOnlyList<PlannerLine> lines,
        IReadOnlyList<ScheduledExpense> scheduled,
        IReadOnlyDictionary<Guid, Guid?> parents)
    {
        var byCategory = lines.ToDictionary(l => l.CategoryId, l => l.Amount);
        foreach (var expense in scheduled)
        {
            var line = byCategory.ContainsKey(expense.CategoryId)
                ? expense.CategoryId
                : parents.GetValueOrDefault(expense.CategoryId) is { } parent && byCategory.ContainsKey(parent) ? parent : (Guid?)null;
            if (line is { } id)
            {
                byCategory[id] -= expense.Amount;
            }
        }

        return byCategory.Values.Sum(v => Math.Max(0, v));
    }
}
