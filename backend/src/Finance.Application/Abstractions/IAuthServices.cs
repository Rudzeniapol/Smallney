using Finance.Domain.Users;

namespace Finance.Application.Abstractions;

public sealed record IssuedAccessToken(string Token, DateTime ExpiresAt);

public sealed record IssuedRefreshToken(string Token, string Hash, DateTime ExpiresAt);

public interface ITokenService
{
    IssuedAccessToken CreateAccessToken(User user);

    IssuedRefreshToken CreateRefreshToken();

    string HashRefreshToken(string token);
}

public enum PasswordCheck
{
    Failed,
    Success,
    SuccessRehashNeeded,
}

public interface IPasswordService
{
    string Hash(User user, string password);

    PasswordCheck Verify(User user, string password);
}
