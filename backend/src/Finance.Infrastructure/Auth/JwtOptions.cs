using System.ComponentModel.DataAnnotations;

namespace Finance.Infrastructure.Auth;

public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    [Required]
    public string Issuer { get; set; } = "smallney";

    [Required]
    public string Audience { get; set; } = "smallney-clients";

    /// <summary>HMAC-SHA256 key, at least 32 bytes. Must come from configuration/secrets.</summary>
    [Required]
    [MinLength(32)]
    public string SigningKey { get; set; } = string.Empty;

    [Range(1, 1440)]
    public int AccessTokenMinutes { get; set; } = 15;

    [Range(1, 365)]
    public int RefreshTokenDays { get; set; } = 30;
}
