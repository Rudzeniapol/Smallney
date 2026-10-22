namespace Finance.Domain.Common;

/// <summary>A row that takes part in sync: every change gets a new <see cref="Version"/> from the global sequence.</summary>
public interface IVersioned
{
    long Version { get; set; }

    /// <summary>The user whose sync stream the row belongs to (and whose write lock is taken).</summary>
    Guid VersionOwnerId { get; }
}
