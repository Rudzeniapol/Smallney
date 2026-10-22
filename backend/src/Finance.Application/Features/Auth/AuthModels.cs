using Finance.Application.Common;
using Finance.Domain.Users;
using FluentValidation;

namespace Finance.Application.Features.Auth;

public sealed record RegisterRequest
{
    public string? Email { get; init; }

    public string? Password { get; init; }

    /// <summary>ISO 4217, defaults to BYN.</summary>
    public string? BaseCurrency { get; init; }

    /// <summary>IANA zone, defaults to Europe/Minsk.</summary>
    public string? Timezone { get; init; }

    /// <summary>1–28, defaults to 1.</summary>
    public int? FirstDayOfMonth { get; init; }
}

public sealed record LoginRequest(string? Email, string? Password);

public sealed record RefreshRequest(string? RefreshToken);

public sealed record AuthResponse(
    string AccessToken,
    DateTime AccessTokenExpiresAt,
    string RefreshToken,
    DateTime RefreshTokenExpiresAt,
    Guid UserId);

internal sealed class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public const int MinPasswordLength = 8;

    public RegisterRequestValidator()
    {
        RuleFor(x => x.Email).NotEmpty().MaximumLength(320).EmailAddress();
        RuleFor(x => x.Password).NotEmpty().MinimumLength(MinPasswordLength).MaximumLength(256);
        RuleFor(x => x.BaseCurrency).IsCurrencyCode().When(x => x.BaseCurrency is not null);
        RuleFor(x => x.Timezone)
            .Must(UserClock.IsValidTimezone).WithErrorCode("invalid_timezone").WithMessage("Unknown IANA time zone.")
            .When(x => x.Timezone is not null);
        RuleFor(x => x.FirstDayOfMonth).InclusiveBetween(User.MinFirstDayOfMonth, User.MaxFirstDayOfMonth);
    }
}

internal sealed class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Email).NotEmpty();
        RuleFor(x => x.Password).NotEmpty();
    }
}

internal sealed class RefreshRequestValidator : AbstractValidator<RefreshRequest>
{
    public RefreshRequestValidator() => RuleFor(x => x.RefreshToken).NotEmpty().MaximumLength(200);
}
