using System.Data;
using System.Text.Json;
using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Me;
using Finance.Domain.Common;
using Finance.Domain.Sync;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Finance.Application.Features.Sync;

/// <summary>
/// Offline-first sync. Push applies client changes one by one with the same rules as the REST API; pull streams
/// every change with Version &gt; since. Conflicts: last write wins in arrival order; a deleted entity stays deleted.
/// </summary>
public sealed class SyncService(
    IAppDbContext db,
    ICurrentUser currentUser,
    SyncHandlers handlers,
    MeService me,
    TimeProvider clock,
    IValidator<SyncPushRequest> validator,
    ILogger<SyncService> logger)
{
    public const int DefaultPullLimit = 500;
    public const int MaxPullLimit = 1000;

    /// <summary>Settings may refer to an account, so they go after accounts.</summary>
    private const int SettingsOrder = 15;

    /// <summary>
    /// Applies the changes under the user's write lock, in dependency order: upserts parents first
    /// (accounts → settings → categories → goals → rules → budgets → lines → allocations → transactions),
    /// then deletes children first. Each change is saved on its own, so one rejection does not affect the others.
    /// </summary>
    public async Task<SyncPushResponse> PushAsync(SyncPushRequest request, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(request, ct);
        var userId = currentUser.RequiredUserId();
        var accepted = new List<AcceptedChange>();
        var rejected = new List<RejectedChange>();

        var valid = new List<(SyncChange Change, int Index)>();
        foreach (var (change, index) in request.Changes!.Select((c, i) => (c with { ClientUpdatedAt = Normalize(c.ClientUpdatedAt) }, i)))
        {
            if (EnvelopeProblem(change) is { } problem)
            {
                rejected.Add(Reject(change, problem.Code, problem.Message));
                continue;
            }

            valid.Add((change, index));
        }

        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        await db.LockUserAsync(userId, ct);
        var ordered = await OrderAsync(valid, ct);

        var ids = ordered.Select(c => c.Id).Distinct().ToList();
        var processed = (await db.SyncChangeLogs.AsNoTracking().Where(l => l.UserId == userId && ids.Contains(l.EntityId)).ToListAsync(ct))
            .ToDictionary(l => (l.EntityId, l.ClientUpdatedAt));
        var logs = new List<SyncChangeLog>();

        foreach (var change in ordered)
        {
            var key = (change.Id, change.ClientUpdatedAt);
            if (processed.TryGetValue(key, out var earlier))
            {
                accepted.Add(new AcceptedChange(change.EntityType!, change.Id, change.Operation!.Value, earlier.Version, SyncAcceptStatus.Duplicate));
                continue;
            }

            try
            {
                var (version, status) = await ApplyAsync(change, userId, ct);
                accepted.Add(new AcceptedChange(change.EntityType!, change.Id, change.Operation!.Value, version, status));
                var log = new SyncChangeLog
                {
                    UserId = userId,
                    EntityId = change.Id,
                    ClientUpdatedAt = change.ClientUpdatedAt,
                    EntityType = change.EntityType!,
                    Operation = change.Operation!.Value,
                    Version = version,
                    Status = status.ToString(),
                    ProcessedAt = clock.GetUtcNow().UtcDateTime,
                };
                logs.Add(log);
                processed[key] = log;
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                db.ChangeTracker.Clear();
                rejected.Add(Rejection(change, ex));
            }
        }

        db.SyncChangeLogs.AddRange(logs);
        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);
        return new SyncPushResponse(accepted, rejected);
    }

    /// <summary>All changes after <paramref name="since"/>, read from one consistent snapshot.</summary>
    public async Task<SyncPullResponse> PullAsync(long since, int? limit, CancellationToken ct)
    {
        var take = limit ?? DefaultPullLimit;
        if (since < 0 || take is < 1 or > MaxPullLimit)
        {
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure(since < 0 ? "since" : "limit", $"since ≥ 0, limit 1..{MaxPullLimit}.")]);
        }

        var userId = currentUser.RequiredUserId();

        // One snapshot for all tables: otherwise a commit between two queries could let the cursor skip a change.
        await using var transaction = await db.Database.BeginTransactionAsync(IsolationLevel.RepeatableRead, ct);
        var changes = new List<PulledChange>();
        foreach (var handler in handlers.All.Values)
        {
            foreach (var entity in await handler.ChangesAsync(since, take + 1, ct))
            {
                changes.Add(new PulledChange(handler.EntityType, entity.Id, entity.Version, entity.IsDeleted, entity.DeletedAt,
                    entity.UpdatedAt, entity.IsDeleted ? null : handler.ToData(entity)));
            }
        }

        var user = await db.Users.AsNoTracking().FirstAsync(u => u.Id == userId, ct);
        if (user.Version > since)
        {
            changes.Add(new PulledChange(SyncEntityTypes.Settings, user.Id, user.Version, false, null, user.UpdatedAt, SettingsSyncData.From(user)));
        }

        await transaction.CommitAsync(ct);

        var page = changes.OrderBy(c => c.Version).Take(take).ToList();
        return new SyncPullResponse(page, page.Count > 0 ? page[^1].Version : since, changes.Count > take);
    }

    private async Task<(long? Version, SyncAcceptStatus Status)> ApplyAsync(SyncChange change, Guid userId, CancellationToken ct)
    {
        if (change.EntityType == SyncEntityTypes.Settings)
        {
            if (change.Operation == SyncOperation.Delete)
            {
                throw new DomainException("operation_not_allowed", "Settings cannot be deleted.");
            }

            if (change.Id != userId)
            {
                throw new NotFoundException("Settings", change.Id);
            }

            var settings = change.Payload!.Value.Deserialize<SettingsPayload>(SyncJson.Options) ?? throw new JsonException("The payload is empty.");
            var before = (await me.GetUserAsync(ct)).Version;
            var user = await me.ReplaceSettingsAsync(settings, ct);
            await db.SaveChangesAsync(ct);
            return (user.Version, user.Version == before ? SyncAcceptStatus.Unchanged : SyncAcceptStatus.Applied);
        }

        var handler = handlers.All[change.EntityType!];
        var existing = await handler.FindAsync(change.Id, ct);

        if (change.Operation == SyncOperation.Delete)
        {
            if (existing is null)
            {
                return (null, SyncAcceptStatus.Ignored);
            }

            if (existing.IsDeleted)
            {
                return (existing.Version, SyncAcceptStatus.AlreadyDeleted);
            }

            await handler.DeleteAsync(change.Id, ct);
            await db.SaveChangesAsync(ct);
            return (existing.Version, SyncAcceptStatus.Applied);
        }

        if (existing is { IsDeleted: true })
        {
            throw new ConflictException("entity_deleted", "The entity was deleted; a deletion wins over later changes.");
        }

        var versionBefore = existing?.Version;
        var entity = existing is null
            ? await handler.CreateAsync(change.Id, change.Payload!.Value, ct)
            : await handler.UpdateAsync(change.Id, change.Payload!.Value, ct);
        await db.SaveChangesAsync(ct);
        return (entity.Version, entity.Version == versionBefore ? SyncAcceptStatus.Unchanged : SyncAcceptStatus.Applied);
    }

    /// <summary>Upserts parents first, then deletes children first; otherwise the order the client sent.</summary>
    private async Task<List<SyncChange>> OrderAsync(List<(SyncChange Change, int Index)> changes, CancellationToken ct)
    {
        int Rank(SyncChange c) => c.EntityType == SyncEntityTypes.Settings ? SettingsOrder : handlers.All[c.EntityType!].Order;

        var upserts = changes.Where(c => c.Change.Operation == SyncOperation.Upsert)
            .OrderBy(c => Rank(c.Change))
            .ThenBy(c => c.Change.EntityType == SyncEntityTypes.Settings ? 0 : handlers.All[c.Change.EntityType!].SubOrder(c.Change.Payload))
            .ThenBy(c => c.Index);

        var deletes = changes.Where(c => c.Change.Operation == SyncOperation.Delete).ToList();
        var stored = new Dictionary<Guid, int>();
        foreach (var group in deletes.Where(d => d.Change.EntityType != SyncEntityTypes.Settings).GroupBy(d => d.Change.EntityType!))
        {
            foreach (var (id, order) in await handlers.All[group.Key].SubOrdersAsync(group.Select(d => d.Change.Id).ToList(), ct))
            {
                stored[id] = order;
            }
        }

        var orderedDeletes = deletes
            .OrderByDescending(c => Rank(c.Change))
            .ThenByDescending(c => stored.GetValueOrDefault(c.Change.Id))
            .ThenBy(c => c.Index);
        return upserts.Concat(orderedDeletes).Select(c => c.Change).ToList();
    }

    /// <summary>UTC with microsecond precision — what PostgreSQL stores — so retries match the log exactly.</summary>
    private static DateTime Normalize(DateTime value)
    {
        var utc = value.Kind switch
        {
            DateTimeKind.Local => value.ToUniversalTime(),
            DateTimeKind.Unspecified => DateTime.SpecifyKind(value, DateTimeKind.Utc),
            _ => value,
        };
        return new DateTime(utc.Ticks - (utc.Ticks % 10), DateTimeKind.Utc);
    }

    private (string Code, string Message)? EnvelopeProblem(SyncChange change)
    {
        if (change.EntityType is null || (change.EntityType != SyncEntityTypes.Settings && !handlers.All.ContainsKey(change.EntityType)))
        {
            return ("unknown_entity_type", $"Unknown entity type '{change.EntityType}'.");
        }

        if (change.Id == Guid.Empty)
        {
            return ("invalid_id", "The id is required.");
        }

        if (change.Operation is null || !Enum.IsDefined(change.Operation.Value))
        {
            return ("invalid_operation", "The operation must be upsert or delete.");
        }

        if (change.ClientUpdatedAt == default)
        {
            return ("client_updated_at_required", "clientUpdatedAt is required.");
        }

        if (change.Operation == SyncOperation.Upsert && change.Payload is not { ValueKind: JsonValueKind.Object })
        {
            return ("invalid_payload", "An upsert needs a JSON object payload.");
        }

        return null;
    }

    private RejectedChange Rejection(SyncChange change, Exception ex)
    {
        switch (ex)
        {
            case ValidationException validation:
                var errors = validation.Errors
                    .GroupBy(e => e.PropertyName ?? string.Empty)
                    .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());
                var code = validation.Errors.Select(e => e.ErrorCode).FirstOrDefault(c => c is not null && c.Contains('_')) ?? "validation_failed";
                return Reject(change, code, "Validation failed.", errors);
            case DomainException domain:
                return Reject(change, domain.Code, domain.Message);
            case ConflictException conflict:
                return Reject(change, conflict.Code, conflict.Message);
            case NotFoundException notFound:
                return Reject(change, "not_found", notFound.Message);
            case JsonException json:
                return Reject(change, "invalid_payload", json.Message);
            case DbUpdateException { InnerException: Npgsql.PostgresException { SqlState: Npgsql.PostgresErrorCodes.UniqueViolation } }:
                return Reject(change, "duplicate", "The change conflicts with existing data.");
            case DbUpdateException:
                return Reject(change, "constraint_violation", "The change violates a data constraint.");
            default:
                logger.LogError(ex, "Sync change {EntityType} {Id} failed unexpectedly", change.EntityType, change.Id);
                return Reject(change, "internal_error", "The change could not be processed.");
        }
    }

    private static RejectedChange Reject(SyncChange change, string code, string message, IReadOnlyDictionary<string, string[]>? errors = null) =>
        new(change.EntityType, change.Id, change.Operation, code, message, errors);
}
