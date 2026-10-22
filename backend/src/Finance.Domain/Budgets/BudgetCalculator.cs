namespace Finance.Domain.Budgets;

public enum BudgetLineStatus
{
    /// <summary>Below 80% of the limit.</summary>
    Ok,

    /// <summary>80–100% of the limit.</summary>
    Warning,

    /// <summary>Over the limit (or spending without a limit).</summary>
    Over,
}

public sealed record BudgetLineInput(Guid LineId, Guid CategoryId, long Planned, bool Rollover);

public sealed record BudgetAllocationInput(Guid AllocationId, Guid SavingsGoalId, long Planned);

/// <summary>Everything the calculation needs for one month, already converted to the budget currency.</summary>
public sealed record BudgetMonthInput(
    long ExpectedIncome,
    long ActualIncome,
    IReadOnlyList<BudgetLineInput> Lines,
    IReadOnlyList<BudgetAllocationInput> Allocations,
    IReadOnlyDictionary<Guid, long> SpentByCategory,
    IReadOnlyDictionary<Guid, Guid?> CategoryParents);

public sealed record BudgetLineResult(
    Guid LineId,
    Guid CategoryId,
    long Planned,
    long CarriedOver,
    long Spent,
    long Remaining,
    decimal? Percent,
    BudgetLineStatus Status,
    bool Rollover)
{
    public long Limit => Planned + CarriedOver;
}

public sealed record OffBudgetSpending(Guid CategoryId, long Spent);

public sealed record BudgetMonthResult(
    long ExpectedIncome,
    long ActualIncome,
    long ToSavings,
    long Allocated,
    long Unallocated,
    long TotalSpent,
    IReadOnlyList<BudgetLineResult> Lines,
    IReadOnlyList<OffBudgetSpending> OffBudget)
{
    public bool IsOverAllocated => Unallocated < 0;

    public long OffBudgetTotal => OffBudget.Sum(o => o.Spent);
}

/// <summary>
/// Pure budget math. Spending of a category goes to the most specific line: its own line, otherwise its
/// parent's line, otherwise "off budget". So a parent line covers children that have no line of their own,
/// and nothing is counted twice.
/// </summary>
public static class BudgetCalculator
{
    public const decimal WarningThresholdPercent = 80m;

    /// <param name="carriedOver">Per category: remainder carried over from the previous month.</param>
    public static BudgetMonthResult Calculate(BudgetMonthInput input, IReadOnlyDictionary<Guid, long>? carriedOver = null)
    {
        var lineByCategory = input.Lines.ToDictionary(l => l.CategoryId);
        var spentByLine = input.Lines.ToDictionary(l => l.CategoryId, _ => 0L);
        var offBudget = new Dictionary<Guid, long>();

        foreach (var (categoryId, spent) in input.SpentByCategory)
        {
            if (spent == 0)
            {
                continue;
            }

            if (lineByCategory.ContainsKey(categoryId))
            {
                spentByLine[categoryId] += spent;
            }
            else if (input.CategoryParents.GetValueOrDefault(categoryId) is { } parentId && lineByCategory.ContainsKey(parentId))
            {
                spentByLine[parentId] += spent;
            }
            else
            {
                offBudget[categoryId] = offBudget.GetValueOrDefault(categoryId) + spent;
            }
        }

        var lines = input.Lines
            .Select(line =>
            {
                var carried = carriedOver?.GetValueOrDefault(line.CategoryId) ?? 0;
                var spent = spentByLine[line.CategoryId];
                var limit = line.Planned + carried;
                var percent = limit > 0 ? Math.Round(spent * 100m / limit, 1, MidpointRounding.ToEven) : (decimal?)null;
                return new BudgetLineResult(
                    line.LineId, line.CategoryId, line.Planned, carried, spent, limit - spent, percent, Status(spent, limit), line.Rollover);
            })
            .ToList();

        var toSavings = input.Allocations.Sum(a => a.Planned);
        var allocated = input.Lines.Sum(l => l.Planned);
        return new BudgetMonthResult(
            input.ExpectedIncome,
            input.ActualIncome,
            toSavings,
            allocated,
            input.ExpectedIncome - toSavings - allocated,
            input.SpentByCategory.Values.Sum(),
            lines,
            offBudget.Select(kv => new OffBudgetSpending(kv.Key, kv.Value)).OrderByDescending(o => o.Spent).ToList());
    }

    /// <summary>What a month passes on: unspent remainders of lines marked Rollover (never negative).</summary>
    public static Dictionary<Guid, long> CarryForward(BudgetMonthResult month) =>
        month.Lines
            .Where(l => l.Rollover && l.Remaining > 0)
            .ToDictionary(l => l.CategoryId, l => l.Remaining);

    /// <summary>
    /// Calculates consecutive months oldest first, passing rollover remainders along.
    /// A month missing from the sequence breaks the chain (pass null for it).
    /// </summary>
    public static BudgetMonthResult? CalculateChain(IReadOnlyList<BudgetMonthInput?> monthsOldestFirst)
    {
        BudgetMonthResult? previous = null;
        foreach (var month in monthsOldestFirst)
        {
            previous = month is null ? null : Calculate(month, previous is null ? null : CarryForward(previous));
        }

        return previous;
    }

    private static BudgetLineStatus Status(long spent, long limit)
    {
        if (limit <= 0)
        {
            return spent > 0 ? BudgetLineStatus.Over : BudgetLineStatus.Ok;
        }

        var percent = spent * 100m / limit;
        return percent > 100m ? BudgetLineStatus.Over
            : percent >= WarningThresholdPercent ? BudgetLineStatus.Warning
            : BudgetLineStatus.Ok;
    }
}
