using Finance.Application.Abstractions;
using Finance.Domain.Users;
using Microsoft.AspNetCore.Identity;

namespace Finance.Infrastructure.Auth;

/// <summary>ASP.NET Core Identity's PBKDF2 hasher.</summary>
internal sealed class PasswordService : IPasswordService
{
    private readonly PasswordHasher<User> _hasher = new();

    public string Hash(User user, string password) => _hasher.HashPassword(user, password);

    public PasswordCheck Verify(User user, string password) =>
        _hasher.VerifyHashedPassword(user, user.PasswordHash, password) switch
        {
            PasswordVerificationResult.Success => PasswordCheck.Success,
            PasswordVerificationResult.SuccessRehashNeeded => PasswordCheck.SuccessRehashNeeded,
            _ => PasswordCheck.Failed,
        };
}
