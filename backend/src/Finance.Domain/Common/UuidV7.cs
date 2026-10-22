namespace Finance.Domain.Common;

/// <summary>Helpers for RFC 9562 version 7 UUIDs (time-ordered), which clients generate for offline-first.</summary>
public static class UuidV7
{
    public static Guid New() => Guid.CreateVersion7();

    /// <summary>True when <paramref name="id"/> is a version 7 UUID with the RFC 9562 variant.</summary>
    public static bool IsValid(Guid id) => id.Version == 7 && (id.Variant & 0b1100) == 0b1000;
}
