using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Me;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Recurring;

public sealed class RecurringQueries(
    IAppDbContext db,
    MeService me,
    TimeProvider clock,
    IValidator<DateRange> rangeValidator)
{
    public async Task<IReadOnlyList<RecurringRuleResponse>> ListAsync(bool includeInactive, CancellationToken ct)
    {
        var today = (await me.GetUserAsync(ct)).LocalToday(clock.GetUtcNow());
        var query = db.RecurringRules.AsNoTracking();
        if (!includeInactive)
        {
            query = query.Where(r => r.IsActive);
        }

        var rules = await query.OrderBy(r => r.Name).ToListAsync(ct);
        return rules
            .Select(r => RecurringRuleResponse.From(r, today))
            .OrderBy(r => r.NextOccurrence ?? DateOnly.MaxValue)
            .ThenBy(r => r.Name)
            .ToList();
    }

    public async Task<RecurringRuleResponse> GetAsync(Guid id, CancellationToken ct)
    {
        var today = (await me.GetUserAsync(ct)).LocalToday(clock.GetUtcNow());
        var rule = await db.RecurringRules.AsNoTracking().FirstOrDefaultAsync(r => r.Id == id, ct)
                   ?? throw new NotFoundException("RecurringRule", id);
        return RecurringRuleResponse.From(rule, today);
    }

    /// <summary>Occurrences of active rules (or of one rule) in [from, to], merged with materialized transactions.</summary>
    public async Task<IReadOnlyList<OccurrenceResponse>> OccurrencesAsync(DateOnly from, DateOnly to, Guid? ruleId, CancellationToken ct)
    {
        await rangeValidator.ValidateAndThrowAsync(new DateRange(from, to), ct);
        var query = db.RecurringRules.AsNoTracking();
        query = ruleId is { } id ? query.Where(r => r.Id == id) : query.Where(r => r.IsActive);
        var rules = await query.ToListAsync(ct);
        if (ruleId is not null && rules.Count == 0)
        {
            throw new NotFoundException("RecurringRule", ruleId);
        }

        var ruleIds = rules.Select(r => r.Id).ToList();
        // Deleted occurrence transactions count as skipped: they are never materialized again.
        var materialized = await db.Transactions
            .IgnoreQueryFilters([QueryFilters.SoftDelete])
            .AsNoTracking()
            .Where(t => t.RecurringRuleId != null && ruleIds.Contains(t.RecurringRuleId.Value)
                        && t.RecurrenceDate >= from && t.RecurrenceDate <= to)
            .ToListAsync(ct);
        var byOccurrence = materialized.ToDictionary(t => (t.RecurringRuleId!.Value, t.RecurrenceDate!.Value));

        return rules
            .SelectMany(rule => rule.Schedule.Occurrences(from, to).Select(date =>
            {
                if (byOccurrence.TryGetValue((rule.Id, date), out var t))
                {
                    return new OccurrenceResponse(rule.Id, rule.Name, t.Date, t.Type, t.Amount, t.AccountId, t.CategoryId, t.Id,
                        t.IsDeleted ? OccurrenceState.Skipped : State(t.Status));
                }

                return new OccurrenceResponse(rule.Id, rule.Name, date, rule.Type, rule.Amount, rule.AccountId, rule.CategoryId,
                    RecurringRule.OccurrenceTransactionId(rule.Id, date), OccurrenceState.Upcoming);
            }))
            .OrderBy(o => o.Date)
            .ThenBy(o => o.Name)
            .ToList();
    }

    private static OccurrenceState State(TransactionStatus status) => status switch
    {
        TransactionStatus.Cleared => OccurrenceState.Cleared,
        TransactionStatus.Skipped => OccurrenceState.Skipped,
        _ => OccurrenceState.Planned,
    };
}
