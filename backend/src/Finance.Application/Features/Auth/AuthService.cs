using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Domain.Users;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Auth;

public sealed class AuthService(
    IAppDbContext db,
    IPasswordService passwords,
    ITokenService tokens,
    TimeProvider clock,
    IValidator<RegisterRequest> registerValidator,
    IValidator<LoginRequest> loginValidator,
    IValidator<RefreshRequest> refreshValidator)
{
    // Verified for unknown emails so that response time does not reveal whether the email exists.
    private static string? _dummyHash;

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken ct)
    {
        await registerValidator.ValidateAndThrowAsync(request, ct);

        var normalizedEmail = User.NormalizeEmail(request.Email!);
        if (await db.Users.AnyAsync(u => u.NormalizedEmail == normalizedEmail, ct))
        {
            throw new ConflictException("email_taken", "A user with this email already exists.");
        }

        var user = new User
        {
            Id = UuidV7.New(),
            Email = request.Email!.Trim(),
            NormalizedEmail = normalizedEmail,
            BaseCurrency = request.BaseCurrency?.Trim().ToUpperInvariant() ?? Domain.Monetary.Currency.BaseCode,
            Timezone = request.Timezone ?? User.DefaultTimezone,
            FirstDayOfMonth = request.FirstDayOfMonth ?? User.MinFirstDayOfMonth,
        };
        user.PasswordHash = passwords.Hash(user, request.Password!);

        db.Users.Add(user);
        db.Categories.AddRange(DefaultCategories.CreateFor(user.Id, UuidV7.New));
        var response = IssueTokens(user, familyId: UuidV7.New());
        await db.SaveChangesAsync(ct);
        return response;
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken ct)
    {
        await loginValidator.ValidateAndThrowAsync(request, ct);

        var normalizedEmail = User.NormalizeEmail(request.Email!);
        var user = await db.Users.FirstOrDefaultAsync(u => u.NormalizedEmail == normalizedEmail, ct);
        if (user is null)
        {
            var dummy = new User { PasswordHash = _dummyHash ??= passwords.Hash(new User(), "dummy-password") };
            passwords.Verify(dummy, request.Password!);
            throw InvalidCredentials();
        }

        switch (passwords.Verify(user, request.Password!))
        {
            case PasswordCheck.Failed:
                throw InvalidCredentials();
            case PasswordCheck.SuccessRehashNeeded:
                user.PasswordHash = passwords.Hash(user, request.Password!);
                break;
        }

        var response = IssueTokens(user, familyId: UuidV7.New());
        await db.SaveChangesAsync(ct);
        return response;
    }

    /// <summary>Rotates the refresh token. Presenting an already rotated token revokes the whole family.</summary>
    public async Task<AuthResponse> RefreshAsync(RefreshRequest request, CancellationToken ct)
    {
        await refreshValidator.ValidateAndThrowAsync(request, ct);

        var now = clock.GetUtcNow().UtcDateTime;
        var hash = tokens.HashRefreshToken(request.RefreshToken!);
        var stored = await db.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == hash, ct);
        if (stored is null)
        {
            throw InvalidRefreshToken();
        }

        if (stored.RevokedAt is not null)
        {
            if (stored.ReplacedByTokenId is not null)
            {
                // Reuse of a rotated token: assume it was stolen and kill every token of this login.
                await RevokeFamilyAsync(stored.FamilyId, now, "reuse_detected", ct);
                await db.SaveChangesAsync(ct);
            }

            throw InvalidRefreshToken();
        }

        if (!stored.IsActive(now))
        {
            throw InvalidRefreshToken();
        }

        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == stored.UserId, ct) ?? throw InvalidRefreshToken();
        var response = IssueTokens(user, stored.FamilyId, out var replacement);
        stored.Revoke(now, "rotated", replacement.Id);
        await db.SaveChangesAsync(ct);
        return response;
    }

    /// <summary>Revokes the presented refresh token and every token of the same login. Always succeeds.</summary>
    public async Task LogoutAsync(RefreshRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            return;
        }

        var hash = tokens.HashRefreshToken(request.RefreshToken);
        var stored = await db.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == hash, ct);
        if (stored is null)
        {
            return;
        }

        await RevokeFamilyAsync(stored.FamilyId, clock.GetUtcNow().UtcDateTime, "logout", ct);
        await db.SaveChangesAsync(ct);
    }

    private AuthResponse IssueTokens(User user, Guid familyId) => IssueTokens(user, familyId, out _);

    private AuthResponse IssueTokens(User user, Guid familyId, out RefreshToken entity)
    {
        var access = tokens.CreateAccessToken(user);
        var refresh = tokens.CreateRefreshToken();
        entity = new RefreshToken
        {
            Id = UuidV7.New(),
            UserId = user.Id,
            FamilyId = familyId,
            TokenHash = refresh.Hash,
            CreatedAt = clock.GetUtcNow().UtcDateTime,
            ExpiresAt = refresh.ExpiresAt,
        };
        db.RefreshTokens.Add(entity);
        return new AuthResponse(access.Token, access.ExpiresAt, refresh.Token, refresh.ExpiresAt, user.Id);
    }

    private async Task RevokeFamilyAsync(Guid familyId, DateTime now, string reason, CancellationToken ct)
    {
        var family = await db.RefreshTokens.Where(t => t.FamilyId == familyId && t.RevokedAt == null).ToListAsync(ct);
        foreach (var token in family)
        {
            token.Revoke(now, reason);
        }
    }

    private static AuthenticationFailedException InvalidCredentials() =>
        new("invalid_credentials", "Email or password is incorrect.");

    private static AuthenticationFailedException InvalidRefreshToken() =>
        new("invalid_refresh_token", "Refresh token is invalid, expired or revoked.");
}
