using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Budgets;

/// <summary>Budget write rules. Does not call SaveChanges.</summary>
public sealed class BudgetWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    IValidator<BudgetPayload> validator)
{
    /// <summary>Creates the month's budget or replaces its plan: lines and allocations not listed are removed.</summary>
    public async Task<Budget> SaveAsync(FinancialMonth month, BudgetPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        var userId = currentUser.RequiredUserId();
        var lines = payload.Lines ?? [];
        var allocations = payload.GoalAllocations ?? [];
        await EnsureReferencesAsync(lines, allocations, ct);

        var budget = await FindAsync(month, ct);
        if (budget is null)
        {
            var id = payload.Id ?? UuidV7.New();
            await db.Budgets.EnsureIdIsFreeAsync(id, ct);
            var user = await db.Users.AsNoTracking().FirstAsync(u => u.Id == userId, ct);
            budget = new Budget { Id = id, UserId = userId, Month = month.FirstCalendarDay, Currency = user.BaseCurrency };
            db.Budgets.Add(budget);
        }
        else if (payload.Id is { } id && id != budget.Id)
        {
            throw new ConflictException("budget_exists", $"The budget for {month} already exists with another id.");
        }

        budget.ExpectedIncome = payload.ExpectedIncome;
        await ReplaceLinesAsync(budget, lines, ct);
        await ReplaceAllocationsAsync(budget, allocations, ct);
        return budget;
    }

    public async Task DeleteAsync(FinancialMonth month, CancellationToken ct)
    {
        var budget = await FindAsync(month, ct) ?? throw new NotFoundException("Budget", month);
        var now = clock.GetUtcNow().UtcDateTime;
        budget.MarkDeleted(now);
        foreach (var line in await db.BudgetLines.Where(l => l.BudgetId == budget.Id).ToListAsync(ct))
        {
            line.MarkDeleted(now);
        }

        foreach (var allocation in await db.BudgetGoalAllocations.Where(a => a.BudgetId == budget.Id).ToListAsync(ct))
        {
            allocation.MarkDeleted(now);
        }
    }

    /// <summary>Copies the previous month's plan (income, lines, allocations) into an empty month.</summary>
    public async Task<Budget> CopyFromPreviousAsync(FinancialMonth month, CancellationToken ct)
    {
        if (await FindAsync(month, ct) is not null)
        {
            throw new ConflictException("budget_exists", $"The budget for {month} already exists.");
        }

        var previous = await FindAsync(month.Previous, ct)
                       ?? throw new DomainException("previous_budget_not_found", $"There is no budget for {month.Previous}.");
        var budget = new Budget
        {
            Id = UuidV7.New(),
            UserId = currentUser.RequiredUserId(),
            Month = month.FirstCalendarDay,
            Currency = previous.Currency,
            ExpectedIncome = previous.ExpectedIncome,
        };
        db.Budgets.Add(budget);

        foreach (var line in await db.BudgetLines.AsNoTracking().Where(l => l.BudgetId == previous.Id).ToListAsync(ct))
        {
            db.BudgetLines.Add(new BudgetLine
            {
                Id = UuidV7.New(), UserId = budget.UserId, BudgetId = budget.Id,
                CategoryId = line.CategoryId, PlannedAmount = line.PlannedAmount, Rollover = line.Rollover,
            });
        }

        foreach (var allocation in await db.BudgetGoalAllocations.AsNoTracking().Where(a => a.BudgetId == previous.Id).ToListAsync(ct))
        {
            db.BudgetGoalAllocations.Add(new BudgetGoalAllocation
            {
                Id = UuidV7.New(), UserId = budget.UserId, BudgetId = budget.Id,
                SavingsGoalId = allocation.SavingsGoalId, PlannedAmount = allocation.PlannedAmount,
            });
        }

        return budget;
    }

    private Task<Budget?> FindAsync(FinancialMonth month, CancellationToken ct)
    {
        var day = month.FirstCalendarDay;
        return db.Budgets.FirstOrDefaultAsync(b => b.Month == day, ct);
    }

    private async Task EnsureReferencesAsync(
        IReadOnlyList<BudgetLinePayload> lines,
        IReadOnlyList<BudgetAllocationPayload> allocations,
        CancellationToken ct)
    {
        var categoryIds = lines.Select(l => l.CategoryId!.Value).ToList();
        var kinds = await db.Categories.Where(c => categoryIds.Contains(c.Id)).ToDictionaryAsync(c => c.Id, c => c.Kind, ct);
        foreach (var id in categoryIds)
        {
            if (!kinds.TryGetValue(id, out var kind))
            {
                throw new DomainException("category_not_found", $"Category '{id}' was not found.");
            }

            if (kind != CategoryKind.Expense)
            {
                throw new DomainException("category_kind_mismatch", "Budget lines can only use expense categories.");
            }
        }

        var goalIds = allocations.Select(a => a.SavingsGoalId!.Value).ToList();
        var known = await db.SavingsGoals.Where(g => goalIds.Contains(g.Id)).Select(g => g.Id).ToListAsync(ct);
        var missing = goalIds.Except(known).ToList();
        if (missing.Count > 0)
        {
            throw new DomainException("savings_goal_not_found", $"Savings goal '{missing[0]}' was not found.");
        }
    }

    private async Task ReplaceLinesAsync(Budget budget, IReadOnlyList<BudgetLinePayload> lines, CancellationToken ct)
    {
        var existing = await db.BudgetLines.Where(l => l.BudgetId == budget.Id).ToListAsync(ct);
        var kept = new HashSet<Guid>();
        foreach (var p in lines)
        {
            var categoryId = p.CategoryId!.Value;
            var line = existing.FirstOrDefault(l => p.Id is not null && l.Id == p.Id)
                       ?? existing.FirstOrDefault(l => l.CategoryId == categoryId && !kept.Contains(l.Id));
            if (line is not null && line.CategoryId != categoryId)
            {
                // Keeps (budget, category) unique at every step of the update.
                throw new DomainException(
                    "budget_line_category_locked",
                    "A line cannot move to another category. Remove it and add a new line instead.");
            }
            if (line is null)
            {
                var id = p.Id ?? UuidV7.New();
                await db.BudgetLines.EnsureIdIsFreeAsync(id, ct);
                line = new BudgetLine { Id = id, UserId = budget.UserId, BudgetId = budget.Id };
                db.BudgetLines.Add(line);
            }

            line.CategoryId = categoryId;
            line.PlannedAmount = p.PlannedAmount;
            line.Rollover = p.Rollover;
            kept.Add(line.Id);
        }

        var now = clock.GetUtcNow().UtcDateTime;
        foreach (var line in existing.Where(l => !kept.Contains(l.Id)))
        {
            line.MarkDeleted(now);
        }
    }

    private async Task ReplaceAllocationsAsync(Budget budget, IReadOnlyList<BudgetAllocationPayload> allocations, CancellationToken ct)
    {
        var existing = await db.BudgetGoalAllocations.Where(a => a.BudgetId == budget.Id).ToListAsync(ct);
        var kept = new HashSet<Guid>();
        foreach (var p in allocations)
        {
            var goalId = p.SavingsGoalId!.Value;
            var allocation = existing.FirstOrDefault(a => p.Id is not null && a.Id == p.Id)
                             ?? existing.FirstOrDefault(a => a.SavingsGoalId == goalId && !kept.Contains(a.Id));
            if (allocation is not null && allocation.SavingsGoalId != goalId)
            {
                throw new DomainException(
                    "budget_allocation_goal_locked",
                    "An allocation cannot move to another goal. Remove it and add a new one instead.");
            }
            if (allocation is null)
            {
                var id = p.Id ?? UuidV7.New();
                await db.BudgetGoalAllocations.EnsureIdIsFreeAsync(id, ct);
                allocation = new BudgetGoalAllocation { Id = id, UserId = budget.UserId, BudgetId = budget.Id };
                db.BudgetGoalAllocations.Add(allocation);
            }

            allocation.SavingsGoalId = goalId;
            allocation.PlannedAmount = p.PlannedAmount;
            kept.Add(allocation.Id);
        }

        var now = clock.GetUtcNow().UtcDateTime;
        foreach (var allocation in existing.Where(a => !kept.Contains(a.Id)))
        {
            allocation.MarkDeleted(now);
        }
    }
}
