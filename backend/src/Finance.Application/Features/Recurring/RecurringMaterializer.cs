using Finance.Application.Abstractions;
using Finance.Domain.Recurring;
using Finance.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Finance.Application.Features.Recurring;

/// <summary>
/// Turns due rule occurrences into Planned transactions. An occurrence is materialized once: an existing
/// transaction for (rule, occurrence date) — in any status, even deleted — means it is done.
/// Only today and a short catch-up window are covered, and never days before the rule was created,
/// so a rule with a StartDate in the past does not flood the user with old payments.
/// The check and the insert run under the per-user lock, so the hourly job and a request never race.
/// </summary>
public sealed class RecurringMaterializer(IAppDbContext db, TimeProvider clock, ILogger<RecurringMaterializer> logger)
{
    public const int CatchUpDays = 7;

    public async Task<int> MaterializeAllAsync(CancellationToken ct)
    {
        var userIds = await db.RecurringRules
            .IgnoreQueryFilters([QueryFilters.Tenant])
            .Where(r => r.IsActive)
            .Select(r => r.UserId)
            .Distinct()
            .ToListAsync(ct);

        var created = 0;
        foreach (var userId in userIds)
        {
            try
            {
                created += await MaterializeForUserAsync(userId, ct);
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                // One user's broken data must not stop everybody else's payments.
                logger.LogError(ex, "Materializing recurring transactions failed for user {UserId}", userId);
            }
        }

        return created;
    }

    public async Task<int> MaterializeForUserAsync(Guid userId, CancellationToken ct)
    {
        var user = await db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId, ct);
        if (user is null)
        {
            return 0;
        }

        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        await db.LockUserAsync(userId, ct);

        var now = clock.GetUtcNow();
        var today = user.LocalToday(now);
        var windowStart = today.AddDays(-CatchUpDays);
        var rules = await db.RecurringRules
            .IgnoreQueryFilters([QueryFilters.Tenant])
            .Where(r => r.UserId == userId && r.IsActive && r.StartDate <= today && (r.EndDate == null || r.EndDate >= windowStart))
            .ToListAsync(ct);
        if (rules.Count == 0)
        {
            return 0;
        }

        var due = new List<(RecurringRule Rule, DateOnly Date)>();
        foreach (var rule in rules)
        {
            var createdOn = UserClock.LocalDate(user.Timezone, new DateTimeOffset(DateTime.SpecifyKind(rule.CreatedAt, DateTimeKind.Utc)));
            var from = Max(windowStart, createdOn);
            due.AddRange(rule.Schedule.Occurrences(from, today).Select(date => (rule, date)));
        }

        if (due.Count == 0)
        {
            return 0;
        }

        var ruleIds = rules.Select(r => r.Id).ToList();
        var done = (await db.Transactions
                .IgnoreQueryFilters()
                .Where(t => t.UserId == userId && t.RecurringRuleId != null && ruleIds.Contains(t.RecurringRuleId.Value)
                            && t.RecurrenceDate >= windowStart)
                .Select(t => new { RuleId = t.RecurringRuleId!.Value, Date = t.RecurrenceDate!.Value })
                .ToListAsync(ct))
            .Select(x => (x.RuleId, x.Date))
            .ToHashSet();

        var candidateIds = due.Select(d => RecurringRule.OccurrenceTransactionId(d.Rule.Id, d.Date)).ToList();
        var takenIds = (await db.Transactions.IgnoreQueryFilters().Where(t => candidateIds.Contains(t.Id)).Select(t => t.Id).ToListAsync(ct))
            .ToHashSet();

        var created = 0;
        foreach (var (rule, date) in due)
        {
            if (done.Contains((rule.Id, date)) || takenIds.Contains(RecurringRule.OccurrenceTransactionId(rule.Id, date)))
            {
                continue;
            }

            db.Transactions.Add(rule.Materialize(date));
            created++;
        }

        if (created > 0)
        {
            await db.SaveChangesAsync(ct);
        }

        await transaction.CommitAsync(ct);
        return created;
    }

    private static DateOnly Max(DateOnly a, DateOnly b) => a > b ? a : b;
}
