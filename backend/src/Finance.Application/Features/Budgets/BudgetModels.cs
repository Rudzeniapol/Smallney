using Finance.Domain.Budgets;
using FluentValidation;

namespace Finance.Application.Features.Budgets;

public sealed record BudgetLinePayload
{
    /// <summary>Client-generated UUID v7; omitted = match by category or create.</summary>
    public Guid? Id { get; init; }

    /// <summary>Expense category, root or child.</summary>
    public Guid? CategoryId { get; init; }

    public long PlannedAmount { get; init; }

    public bool Rollover { get; init; }
}

public sealed record BudgetAllocationPayload
{
    public Guid? Id { get; init; }

    public Guid? SavingsGoalId { get; init; }

    public long PlannedAmount { get; init; }
}

/// <summary>The whole budget of a month. Lines and allocations not listed are removed.</summary>
public sealed record BudgetPayload
{
    /// <summary>Client-generated UUID v7 used when the budget is created.</summary>
    public Guid? Id { get; init; }

    /// <summary>Minor units of the budget currency (the base currency at creation).</summary>
    public long ExpectedIncome { get; init; }

    public IReadOnlyList<BudgetLinePayload>? Lines { get; init; }

    public IReadOnlyList<BudgetAllocationPayload>? GoalAllocations { get; init; }
}

public sealed record BudgetLineResponse(Guid Id, Guid CategoryId, long PlannedAmount, bool Rollover, long Version);

public sealed record BudgetAllocationResponse(Guid Id, Guid SavingsGoalId, long PlannedAmount, long Version);

public sealed record BudgetResponse(
    Guid Id,
    string Month,
    DateOnly PeriodStart,
    DateOnly PeriodEnd,
    string Currency,
    long ExpectedIncome,
    IReadOnlyList<BudgetLineResponse> Lines,
    IReadOnlyList<BudgetAllocationResponse> GoalAllocations,
    long Version,
    DateTime CreatedAt,
    DateTime UpdatedAt);

/// <param name="Limit">Planned + CarriedOver.</param>
/// <param name="Percent">Spent / Limit × 100, one decimal; null when the limit is 0.</param>
public sealed record BudgetLineSummary(
    Guid LineId,
    Guid CategoryId,
    long Planned,
    long CarriedOver,
    long Limit,
    long Spent,
    long Remaining,
    decimal? Percent,
    BudgetLineStatus Status,
    bool Rollover);

public sealed record GoalAllocationSummary(Guid AllocationId, Guid SavingsGoalId, long Planned, long? Recommended);

public sealed record OffBudgetItem(Guid CategoryId, long Spent);

/// <summary>
/// The month in the budget currency (transactions are converted at the rate of their date).
/// Unallocated = ExpectedIncome − ToSavings − Allocated and may be negative (IsOverAllocated).
/// </summary>
public sealed record BudgetSummaryResponse(
    Guid BudgetId,
    string Month,
    DateOnly PeriodStart,
    DateOnly PeriodEnd,
    string Currency,
    long ExpectedIncome,
    long ActualIncome,
    long ToSavings,
    long Allocated,
    long Unallocated,
    bool IsOverAllocated,
    long TotalSpent,
    long OffBudgetTotal,
    IReadOnlyList<BudgetLineSummary> Lines,
    IReadOnlyList<GoalAllocationSummary> GoalAllocations,
    IReadOnlyList<OffBudgetItem> OffBudget);

/// <summary>A proposed budget: the previous month's plan plus recommended contributions to dated goals.</summary>
public sealed record BudgetTemplateResponse(
    string Month,
    string Currency,
    bool BasedOnPrevious,
    long ExpectedIncome,
    IReadOnlyList<BudgetLinePayload> Lines,
    IReadOnlyList<BudgetAllocationPayload> GoalAllocations);

internal sealed class BudgetPayloadValidator : AbstractValidator<BudgetPayload>
{
    public const int MaxLines = 200;

    public BudgetPayloadValidator()
    {
        RuleFor(x => x.ExpectedIncome).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Lines).Must(l => l is null || l.Count <= MaxLines);
        RuleForEach(x => x.Lines).ChildRules(line =>
        {
            line.RuleFor(l => l.CategoryId).NotNull();
            line.RuleFor(l => l.PlannedAmount).GreaterThanOrEqualTo(0);
        });
        RuleFor(x => x.Lines)
            .Must(l => l is null || l.Where(x => x.CategoryId is not null).GroupBy(x => x.CategoryId).All(g => g.Count() == 1))
            .WithErrorCode("duplicate_category").WithMessage("A category can have only one line.");
        RuleForEach(x => x.GoalAllocations).ChildRules(allocation =>
        {
            allocation.RuleFor(a => a.SavingsGoalId).NotNull();
            allocation.RuleFor(a => a.PlannedAmount).GreaterThanOrEqualTo(0);
        });
        RuleFor(x => x.GoalAllocations)
            .Must(a => a is null || a.Where(x => x.SavingsGoalId is not null).GroupBy(x => x.SavingsGoalId).All(g => g.Count() == 1))
            .WithErrorCode("duplicate_goal").WithMessage("A goal can have only one allocation.");
    }
}
