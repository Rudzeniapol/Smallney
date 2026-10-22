namespace Finance.Domain.Users;

/// <summary>
/// Opaque refresh token. Only a SHA-256 hash is stored. Tokens rotate on every refresh;
/// all tokens descending from one login share a <see cref="FamilyId"/>, so reuse of a rotated
/// token revokes the whole family.
/// </summary>
public sealed class RefreshToken
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid FamilyId { get; set; }

    public string TokenHash { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public DateTime ExpiresAt { get; set; }

    public DateTime? RevokedAt { get; set; }

    public string? RevokedReason { get; set; }

    public Guid? ReplacedByTokenId { get; set; }

    public bool IsActive(DateTime utcNow) => RevokedAt is null && ExpiresAt > utcNow;

    public void Revoke(DateTime utcNow, string reason, Guid? replacedBy = null)
    {
        if (RevokedAt is not null)
        {
            return;
        }

        RevokedAt = utcNow;
        RevokedReason = reason;
        ReplacedByTokenId = replacedBy;
    }
}
