using System.Text.Json;
using System.Text.Json.Serialization;
using Finance.Domain.Sync;
using FluentValidation;

namespace Finance.Application.Features.Sync;

public static class SyncEntityTypes
{
    public const string Settings = "settings";
    public const string Account = "account";
    public const string Category = "category";
    public const string SavingsGoal = "savingsGoal";
    public const string RecurringRule = "recurringRule";
    public const string Budget = "budget";
    public const string BudgetLine = "budgetLine";
    public const string BudgetGoalAllocation = "budgetGoalAllocation";
    public const string Transaction = "transaction";
}

/// <summary>One change made on the client.</summary>
public sealed record SyncChange
{
    /// <summary>account, category, transaction, recurringRule, budget, budgetLine, budgetGoalAllocation, savingsGoal, settings.</summary>
    public string? EntityType { get; init; }

    public Guid Id { get; init; }

    public SyncOperation? Operation { get; init; }

    /// <summary>For upsert: the entity in the shape that pull returns in <c>data</c>.</summary>
    public JsonElement? Payload { get; init; }

    /// <summary>When the client made the change (UTC). With the id it makes the change idempotent.</summary>
    public DateTime ClientUpdatedAt { get; init; }
}

public sealed record SyncPushRequest(IReadOnlyList<SyncChange>? Changes);

public enum SyncAcceptStatus
{
    /// <summary>Applied; <c>version</c> is the entity's new version.</summary>
    Applied,

    /// <summary>The payload matched the stored entity; nothing changed.</summary>
    Unchanged,

    /// <summary>Already processed earlier with the same (id, clientUpdatedAt); the original result is returned.</summary>
    Duplicate,

    /// <summary>Delete of an entity that is already deleted.</summary>
    AlreadyDeleted,

    /// <summary>Delete of an entity the server never had.</summary>
    Ignored,
}

public sealed record AcceptedChange(string EntityType, Guid Id, SyncOperation Operation, long? Version, SyncAcceptStatus Status);

/// <param name="Code">Stable machine-readable reason, e.g. entity_deleted, validation_failed, account_has_transactions.</param>
public sealed record RejectedChange(
    string? EntityType,
    Guid Id,
    SyncOperation? Operation,
    string Code,
    string Message,
    IReadOnlyDictionary<string, string[]>? Errors = null);

public sealed record SyncPushResponse(IReadOnlyList<AcceptedChange> Accepted, IReadOnlyList<RejectedChange> Rejected);

/// <param name="Data">The entity (same shape as the push payload); null for deleted entities.</param>
public sealed record PulledChange(
    string EntityType,
    Guid Id,
    long Version,
    bool Deleted,
    DateTime? DeletedAt,
    DateTime UpdatedAt,
    object? Data);

/// <param name="NextCursor">Pass it as <c>since</c> next time. Equals <c>since</c> when there is nothing new.</param>
public sealed record SyncPullResponse(IReadOnlyList<PulledChange> Changes, long NextCursor, bool HasMore);

/// <summary>JSON rules for payloads: the same as the HTTP API (camelCase, enums as strings, strict numbers).</summary>
public static class SyncJson
{
    public static readonly JsonSerializerOptions Options = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() },
        NumberHandling = JsonNumberHandling.Strict,
    };
}

internal sealed class SyncPushRequestValidator : AbstractValidator<SyncPushRequest>
{
    public const int MaxChanges = 500;

    public SyncPushRequestValidator()
    {
        RuleFor(x => x.Changes).NotNull().Must(c => c is { Count: > 0 and <= MaxChanges })
            .WithMessage($"Send 1 to {MaxChanges} changes.");
    }
}
