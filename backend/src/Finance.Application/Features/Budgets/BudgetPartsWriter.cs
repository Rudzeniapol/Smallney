using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Budgets;

/// <summary>A budget without its lines, as a sync entity.</summary>
public record BudgetSyncPayload
{
    /// <summary>yyyy-MM.</summary>
    public string? Month { get; init; }

    /// <summary>Defaults to the base currency; cannot change later.</summary>
    public string? Currency { get; init; }

    public long ExpectedIncome { get; init; }
}

public record BudgetLineSyncPayload
{
    public Guid? BudgetId { get; init; }

    public Guid? CategoryId { get; init; }

    public long PlannedAmount { get; init; }

    public bool Rollover { get; init; }
}

public record BudgetAllocationSyncPayload
{
    public Guid? BudgetId { get; init; }

    public Guid? SavingsGoalId { get; init; }

    public long PlannedAmount { get; init; }
}

internal sealed class BudgetSyncPayloadValidator : AbstractValidator<BudgetSyncPayload>
{
    public BudgetSyncPayloadValidator()
    {
        RuleFor(x => x.Month).NotEmpty().Must(m => FinancialMonth.TryParse(m, null, out _)).WithMessage("Use yyyy-MM.");
        RuleFor(x => x.Currency).IsCurrencyCode().When(x => x.Currency is not null);
        RuleFor(x => x.ExpectedIncome).GreaterThanOrEqualTo(0);
    }
}

internal sealed class BudgetLineSyncPayloadValidator : AbstractValidator<BudgetLineSyncPayload>
{
    public BudgetLineSyncPayloadValidator()
    {
        RuleFor(x => x.BudgetId).NotNull();
        RuleFor(x => x.CategoryId).NotNull();
        RuleFor(x => x.PlannedAmount).GreaterThanOrEqualTo(0);
    }
}

internal sealed class BudgetAllocationSyncPayloadValidator : AbstractValidator<BudgetAllocationSyncPayload>
{
    public BudgetAllocationSyncPayloadValidator()
    {
        RuleFor(x => x.BudgetId).NotNull();
        RuleFor(x => x.SavingsGoalId).NotNull();
        RuleFor(x => x.PlannedAmount).GreaterThanOrEqualTo(0);
    }
}

/// <summary>
/// Budgets, lines and goal allocations as separate entities (sync). The REST API saves the whole month at once
/// with <see cref="BudgetWriter"/>; both keep (user, month), (budget, category) and (budget, goal) unique.
/// Does not call SaveChanges.
/// </summary>
public sealed class BudgetPartsWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    BudgetWriter budgets,
    IValidator<BudgetSyncPayload> budgetValidator,
    IValidator<BudgetLineSyncPayload> lineValidator,
    IValidator<BudgetAllocationSyncPayload> allocationValidator)
{
    public async Task<Budget> CreateBudgetAsync(Guid id, BudgetSyncPayload p, CancellationToken ct)
    {
        await budgetValidator.ValidateAndThrowAsync(p, ct);
        await db.Budgets.EnsureIdIsFreeAsync(id, ct);
        var month = FinancialMonth.Parse(p.Month!, null).FirstCalendarDay;
        if (await db.Budgets.AnyAsync(b => b.Month == month, ct))
        {
            throw new ConflictException("budget_exists", $"The budget for {p.Month} already exists with another id.");
        }

        var userId = currentUser.RequiredUserId();
        var user = await db.Users.AsNoTracking().FirstAsync(u => u.Id == userId, ct);
        var budget = new Budget
        {
            Id = id,
            UserId = userId,
            Month = month,
            Currency = p.Currency?.Trim().ToUpperInvariant() ?? user.BaseCurrency,
            ExpectedIncome = p.ExpectedIncome,
        };
        db.Budgets.Add(budget);
        return budget;
    }

    public async Task<Budget> UpdateBudgetAsync(Guid id, BudgetSyncPayload p, CancellationToken ct)
    {
        await budgetValidator.ValidateAndThrowAsync(p, ct);
        var budget = await db.Budgets.FirstOrDefaultAsync(b => b.Id == id, ct) ?? throw new NotFoundException("Budget", id);
        if (FinancialMonth.Parse(p.Month!, null).FirstCalendarDay != budget.Month
            || (p.Currency is not null && !string.Equals(p.Currency.Trim(), budget.Currency, StringComparison.OrdinalIgnoreCase)))
        {
            throw new DomainException("budget_month_locked", "The month and currency of a budget cannot change.");
        }

        budget.ExpectedIncome = p.ExpectedIncome;
        return budget;
    }

    public async Task DeleteBudgetAsync(Guid id, CancellationToken ct)
    {
        var budget = await db.Budgets.AsNoTracking().FirstOrDefaultAsync(b => b.Id == id, ct) ?? throw new NotFoundException("Budget", id);
        await budgets.DeleteAsync(budget.Period, ct);
    }

    public async Task<BudgetLine> CreateLineAsync(Guid id, BudgetLineSyncPayload p, CancellationToken ct)
    {
        await lineValidator.ValidateAndThrowAsync(p, ct);
        await db.BudgetLines.EnsureIdIsFreeAsync(id, ct);
        await EnsureBudgetAsync(p.BudgetId!.Value, ct);
        await EnsureExpenseCategoryAsync(p.CategoryId!.Value, ct);
        if (await db.BudgetLines.AnyAsync(l => l.BudgetId == p.BudgetId && l.CategoryId == p.CategoryId, ct))
        {
            throw new ConflictException("duplicate_category", "The budget already has a line for this category.");
        }

        var line = new BudgetLine
        {
            Id = id, UserId = currentUser.RequiredUserId(), BudgetId = p.BudgetId!.Value, CategoryId = p.CategoryId!.Value,
            PlannedAmount = p.PlannedAmount, Rollover = p.Rollover,
        };
        db.BudgetLines.Add(line);
        return line;
    }

    public async Task<BudgetLine> UpdateLineAsync(Guid id, BudgetLineSyncPayload p, CancellationToken ct)
    {
        await lineValidator.ValidateAndThrowAsync(p, ct);
        var line = await db.BudgetLines.FirstOrDefaultAsync(l => l.Id == id, ct) ?? throw new NotFoundException("BudgetLine", id);
        if (line.BudgetId != p.BudgetId || line.CategoryId != p.CategoryId)
        {
            throw new DomainException(
                "budget_line_category_locked",
                "A line cannot move to another budget or category. Delete it and create a new one.");
        }

        line.PlannedAmount = p.PlannedAmount;
        line.Rollover = p.Rollover;
        return line;
    }

    public async Task DeleteLineAsync(Guid id, CancellationToken ct)
    {
        var line = await db.BudgetLines.FirstOrDefaultAsync(l => l.Id == id, ct) ?? throw new NotFoundException("BudgetLine", id);
        line.MarkDeleted(clock.GetUtcNow().UtcDateTime);
    }

    public async Task<BudgetGoalAllocation> CreateAllocationAsync(Guid id, BudgetAllocationSyncPayload p, CancellationToken ct)
    {
        await allocationValidator.ValidateAndThrowAsync(p, ct);
        await db.BudgetGoalAllocations.EnsureIdIsFreeAsync(id, ct);
        await EnsureBudgetAsync(p.BudgetId!.Value, ct);
        if (!await db.SavingsGoals.AnyAsync(g => g.Id == p.SavingsGoalId, ct))
        {
            throw new DomainException("savings_goal_not_found", $"Savings goal '{p.SavingsGoalId}' was not found.");
        }

        if (await db.BudgetGoalAllocations.AnyAsync(a => a.BudgetId == p.BudgetId && a.SavingsGoalId == p.SavingsGoalId, ct))
        {
            throw new ConflictException("duplicate_goal", "The budget already has an allocation for this goal.");
        }

        var allocation = new BudgetGoalAllocation
        {
            Id = id, UserId = currentUser.RequiredUserId(), BudgetId = p.BudgetId!.Value, SavingsGoalId = p.SavingsGoalId!.Value,
            PlannedAmount = p.PlannedAmount,
        };
        db.BudgetGoalAllocations.Add(allocation);
        return allocation;
    }

    public async Task<BudgetGoalAllocation> UpdateAllocationAsync(Guid id, BudgetAllocationSyncPayload p, CancellationToken ct)
    {
        await allocationValidator.ValidateAndThrowAsync(p, ct);
        var allocation = await db.BudgetGoalAllocations.FirstOrDefaultAsync(a => a.Id == id, ct)
                         ?? throw new NotFoundException("BudgetGoalAllocation", id);
        if (allocation.BudgetId != p.BudgetId || allocation.SavingsGoalId != p.SavingsGoalId)
        {
            throw new DomainException(
                "budget_allocation_goal_locked",
                "An allocation cannot move to another budget or goal. Delete it and create a new one.");
        }

        allocation.PlannedAmount = p.PlannedAmount;
        return allocation;
    }

    public async Task DeleteAllocationAsync(Guid id, CancellationToken ct)
    {
        var allocation = await db.BudgetGoalAllocations.FirstOrDefaultAsync(a => a.Id == id, ct)
                         ?? throw new NotFoundException("BudgetGoalAllocation", id);
        allocation.MarkDeleted(clock.GetUtcNow().UtcDateTime);
    }

    private async Task EnsureBudgetAsync(Guid budgetId, CancellationToken ct)
    {
        if (!await db.Budgets.AnyAsync(b => b.Id == budgetId, ct))
        {
            throw new DomainException("budget_not_found", $"Budget '{budgetId}' was not found.");
        }
    }

    private async Task EnsureExpenseCategoryAsync(Guid categoryId, CancellationToken ct)
    {
        var kind = await db.Categories.Where(c => c.Id == categoryId).Select(c => (CategoryKind?)c.Kind).FirstOrDefaultAsync(ct)
                   ?? throw new DomainException("category_not_found", $"Category '{categoryId}' was not found.");
        if (kind != CategoryKind.Expense)
        {
            throw new DomainException("category_kind_mismatch", "Budget lines can only use expense categories.");
        }
    }
}
