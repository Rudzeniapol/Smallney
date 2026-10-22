using System.Buffers.Binary;
using System.Security.Cryptography;
using System.Text;

namespace Finance.Domain.Common;

/// <summary>Helpers for RFC 9562 version 7 UUIDs (time-ordered), which clients generate for offline-first.</summary>
public static class UuidV7
{
    public static Guid New() => Guid.CreateVersion7();

    /// <summary>True when <paramref name="id"/> is a version 7 UUID with the RFC 9562 variant.</summary>
    public static bool IsValid(Guid id) => id.Version == 7 && (id.Variant & 0b1100) == 0b1000;

    /// <summary>
    /// A reproducible UUID v7: the 48-bit timestamp is midnight UTC of <paramref name="date"/> in Unix milliseconds,
    /// the remaining bits come from SHA-256 of the UTF-8 <paramref name="seed"/>
    /// (byte 6 = 0x70 | h[0] &amp; 0x0F, byte 7 = h[1], byte 8 = 0x80 | h[2] &amp; 0x3F, bytes 9–15 = h[3..10]).
    /// Clients implement the same algorithm (see docs/decisions.md).
    /// </summary>
    public static Guid Deterministic(DateOnly date, string seed)
    {
        Span<byte> hash = stackalloc byte[32];
        SHA256.HashData(Encoding.UTF8.GetBytes(seed), hash);

        Span<byte> bytes = stackalloc byte[16];
        var unixMs = (long)(date.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc) - DateTime.UnixEpoch).TotalMilliseconds;
        Span<byte> ms = stackalloc byte[8];
        BinaryPrimitives.WriteInt64BigEndian(ms, unixMs);
        ms[2..].CopyTo(bytes);
        bytes[6] = (byte)(0x70 | (hash[0] & 0x0F));
        bytes[7] = hash[1];
        bytes[8] = (byte)(0x80 | (hash[2] & 0x3F));
        hash[3..10].CopyTo(bytes[9..]);
        return new Guid(bytes, bigEndian: true);
    }
}
