using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Common;
using Finance.Domain.Goals;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Goals;

/// <summary>Savings goal write rules shared by REST and sync. Does not call SaveChanges.</summary>
public sealed class GoalWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    IValidator<SavingsGoalPayload> validator)
{
    public async Task<SavingsGoal> CreateAsync(Guid id, SavingsGoalPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        await db.SavingsGoals.EnsureIdIsFreeAsync(id, ct);

        var goal = new SavingsGoal { Id = id, UserId = currentUser.RequiredUserId() };
        await ApplyAsync(goal, payload, ct);
        db.SavingsGoals.Add(goal);
        return goal;
    }

    public async Task<SavingsGoal> UpdateAsync(Guid id, SavingsGoalPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        var goal = await FindAsync(id, ct);
        await ApplyAsync(goal, payload, ct);
        return goal;
    }

    /// <summary>Only goals that no budget, rule or transfer refers to can be deleted; mark the others completed.</summary>
    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var goal = await FindAsync(id, ct);
        var inUse = await db.BudgetGoalAllocations.AnyAsync(a => a.SavingsGoalId == id, ct)
                    || await db.Transactions.AnyAsync(t => t.SavingsGoalId == id, ct)
                    || await db.RecurringRules.AnyAsync(r => r.SavingsGoalId == id, ct);
        if (inUse)
        {
            throw new ConflictException(
                "goal_in_use",
                "Budgets, recurring rules or transfers refer to the goal. Mark it completed instead.");
        }

        goal.MarkDeleted(clock.GetUtcNow().UtcDateTime);
    }

    private async Task<SavingsGoal> FindAsync(Guid id, CancellationToken ct) =>
        await db.SavingsGoals.FirstOrDefaultAsync(g => g.Id == id, ct)
        ?? throw new NotFoundException("SavingsGoal", id);

    private async Task ApplyAsync(SavingsGoal goal, SavingsGoalPayload p, CancellationToken ct)
    {
        if (p.LinkedAccountId is { } accountId && !await db.Accounts.AnyAsync(a => a.Id == accountId, ct))
        {
            throw new DomainException("account_not_found", $"Account '{accountId}' was not found.");
        }

        DateOnly? completedOn = null;
        if (p.IsCompleted)
        {
            var userId = currentUser.RequiredUserId();
            var user = await db.Users.AsNoTracking().FirstAsync(u => u.Id == userId, ct);
            completedOn = p.CompletedOn ?? goal.CompletedOn ?? user.LocalToday(clock.GetUtcNow());
        }

        goal.Name = p.Name!.Trim();
        goal.TargetAmount = p.TargetAmount;
        goal.Currency = p.Currency!.Trim().ToUpperInvariant();
        goal.TargetDate = p.TargetDate;
        goal.LinkedAccountId = p.LinkedAccountId;
        goal.Priority = p.Priority;
        goal.IsCompleted = p.IsCompleted;
        goal.CompletedOn = completedOn;
        goal.Color = p.Color;
        goal.Icon = p.Icon;
    }
}
