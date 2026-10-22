namespace Finance.Application.Abstractions;

public interface ICurrentUser
{
    /// <summary>The authenticated user, or null for anonymous requests and background jobs.</summary>
    Guid? UserId { get; }
}

public static class CurrentUserExtensions
{
    public static Guid RequiredUserId(this ICurrentUser user) =>
        user.UserId ?? throw new UnauthorizedAccessException("An authenticated user is required.");
}
