using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Recurring;

/// <summary>Recurring rule write rules shared by REST and sync. Does not call SaveChanges.</summary>
public sealed class RecurringRuleWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    TransactionTemplateResolver resolver,
    IValidator<RecurringRulePayload> validator)
{
    public async Task<RecurringRule> CreateAsync(Guid id, RecurringRulePayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        await db.RecurringRules.EnsureIdIsFreeAsync(id, ct);

        var rule = new RecurringRule { Id = id, UserId = currentUser.RequiredUserId() };
        await ApplyAsync(rule, payload, ct);
        db.RecurringRules.Add(rule);
        return rule;
    }

    /// <summary>Already materialized transactions keep their values; only future occurrences change.</summary>
    public async Task<RecurringRule> UpdateAsync(Guid id, RecurringRulePayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        var rule = await FindAsync(id, ct);
        await ApplyAsync(rule, payload, ct);
        return rule;
    }

    /// <summary>Soft-deletes the rule and its still unconfirmed (Planned) transactions.</summary>
    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var rule = await FindAsync(id, ct);
        var now = clock.GetUtcNow().UtcDateTime;
        rule.MarkDeleted(now);

        var planned = await db.Transactions
            .Where(t => t.RecurringRuleId == id && t.Status == TransactionStatus.Planned)
            .ToListAsync(ct);
        foreach (var transaction in planned)
        {
            transaction.MarkDeleted(now);
        }
    }

    private async Task<RecurringRule> FindAsync(Guid id, CancellationToken ct) =>
        await db.RecurringRules.FirstOrDefaultAsync(r => r.Id == id, ct)
        ?? throw new NotFoundException("RecurringRule", id);

    private async Task ApplyAsync(RecurringRule rule, RecurringRulePayload p, CancellationToken ct)
    {
        var resolved = await resolver.ResolveAsync(p, ct);

        rule.Name = p.Name!.Trim();
        rule.AccountId = resolved.Account.Id;
        rule.Type = resolved.Type;
        rule.Amount = p.Amount;
        rule.CategoryId = resolved.CategoryId;
        rule.Note = string.IsNullOrWhiteSpace(p.Note) ? null : p.Note.Trim();
        rule.Tags = TransactionRules.NormalizeTags(p.Tags);
        rule.ToAccountId = resolved.ToAccountId;
        rule.ToAmount = resolved.ToAmount;
        rule.SavingsGoalId = resolved.SavingsGoalId;
        rule.Frequency = p.Frequency!.Value;
        rule.Interval = p.Interval ?? 1;
        rule.DayOfMonth = p.DayOfMonth;
        rule.DayOfWeek = p.DayOfWeek;
        rule.StartDate = p.StartDate!.Value;
        rule.EndDate = p.EndDate;
        rule.IsActive = p.IsActive;
    }
}
