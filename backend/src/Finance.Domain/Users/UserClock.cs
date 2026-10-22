namespace Finance.Domain.Users;

public static class UserClock
{
    public static bool IsValidTimezone(string? timezone) =>
        !string.IsNullOrWhiteSpace(timezone) && TimeZoneInfo.TryFindSystemTimeZoneById(timezone, out _);

    /// <summary>Local calendar date in <paramref name="timezone"/>; falls back to UTC for an unknown zone.</summary>
    public static DateOnly LocalDate(string timezone, DateTimeOffset utcNow)
    {
        var local = TimeZoneInfo.TryFindSystemTimeZoneById(timezone, out var zone)
            ? TimeZoneInfo.ConvertTime(utcNow, zone)
            : utcNow;
        return DateOnly.FromDateTime(local.DateTime);
    }
}
