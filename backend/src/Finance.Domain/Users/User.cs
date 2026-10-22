using Finance.Domain.Common;
using Finance.Domain.Monetary;

namespace Finance.Domain.Users;

public sealed class User : IHasTimestamps, IVersioned
{
    public const int MinFirstDayOfMonth = 1;
    public const int MaxFirstDayOfMonth = 28;
    public const string DefaultTimezone = "Europe/Minsk";

    public Guid Id { get; set; }

    public string Email { get; set; } = string.Empty;

    /// <summary>Upper-cased trimmed email used for uniqueness and lookups.</summary>
    public string NormalizedEmail { get; set; } = string.Empty;

    public string PasswordHash { get; set; } = string.Empty;

    public string BaseCurrency { get; set; } = Currency.BaseCode;

    /// <summary>IANA time zone id, e.g. "Europe/Minsk".</summary>
    public string Timezone { get; set; } = DefaultTimezone;

    /// <summary>Day (1–28) on which the user's financial month starts, e.g. pay day.</summary>
    public int FirstDayOfMonth { get; set; } = MinFirstDayOfMonth;

    /// <summary>Account that variable spending is charged to in the forecast.</summary>
    public Guid? DefaultSpendingAccountId { get; set; }

    /// <summary>Forecast alert threshold in minor units of the base currency (alert when balance &lt; threshold).</summary>
    public long LowBalanceThreshold { get; set; }

    /// <summary>Version of the settings in the sync stream (entity type "settings").</summary>
    public long Version { get; set; }

    Guid IVersioned.VersionOwnerId => Id;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public static string NormalizeEmail(string email) => email.Trim().ToUpperInvariant();

    /// <summary>The user's local calendar date at <paramref name="utcNow"/>.</summary>
    public DateOnly LocalToday(DateTimeOffset utcNow) => UserClock.LocalDate(Timezone, utcNow);
}
