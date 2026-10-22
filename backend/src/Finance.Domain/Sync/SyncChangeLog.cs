namespace Finance.Domain.Sync;

public enum SyncOperation
{
    Upsert,
    Delete,
}

/// <summary>
/// An accepted pushed change, remembered so that a retry with the same (entity id, clientUpdatedAt)
/// returns the original outcome instead of being applied again.
/// </summary>
public sealed class SyncChangeLog
{
    public Guid UserId { get; set; }

    public Guid EntityId { get; set; }

    public DateTime ClientUpdatedAt { get; set; }

    public string EntityType { get; set; } = string.Empty;

    public SyncOperation Operation { get; set; }

    /// <summary>Version of the entity after the change; null when the change had nothing to do.</summary>
    public long? Version { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime ProcessedAt { get; set; }
}
