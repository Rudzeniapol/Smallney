using Finance.Application.Common;
using Finance.Domain.Users;
using FluentValidation;

namespace Finance.Application.Features.Me;

public sealed record MeResponse(
    Guid Id,
    string Email,
    string BaseCurrency,
    string Timezone,
    int FirstDayOfMonth,
    Guid? DefaultSpendingAccountId,
    long LowBalanceThreshold,
    DateTime CreatedAt)
{
    public static MeResponse From(User user) => new(
        user.Id,
        user.Email,
        user.BaseCurrency,
        user.Timezone,
        user.FirstDayOfMonth,
        user.DefaultSpendingAccountId,
        user.LowBalanceThreshold,
        user.CreatedAt);
}

/// <summary>
/// JSON Merge Patch (RFC 7386) body for PATCH /me: absent fields are left unchanged,
/// <c>null</c> clears a nullable field.
/// </summary>
public sealed record UpdateMeRequest
{
    public string? BaseCurrency { get; init; }

    public string? Timezone { get; init; }

    public int? FirstDayOfMonth { get; init; }

    public Guid? DefaultSpendingAccountId { get; init; }

    /// <summary>Minor units of the base currency, ≥ 0.</summary>
    public long? LowBalanceThreshold { get; init; }
}

/// <summary>All settings at once: the "settings" entity of the sync stream (id = user id).</summary>
public record SettingsPayload
{
    public string? BaseCurrency { get; init; }

    public string? Timezone { get; init; }

    public int FirstDayOfMonth { get; init; } = User.MinFirstDayOfMonth;

    public Guid? DefaultSpendingAccountId { get; init; }

    public long LowBalanceThreshold { get; init; }
}

/// <summary>Settings as pulled; <see cref="Email"/> is read-only.</summary>
public sealed record SettingsSyncData : SettingsPayload
{
    public string? Email { get; init; }

    public static SettingsSyncData From(User user) => new()
    {
        Email = user.Email,
        BaseCurrency = user.BaseCurrency,
        Timezone = user.Timezone,
        FirstDayOfMonth = user.FirstDayOfMonth,
        DefaultSpendingAccountId = user.DefaultSpendingAccountId,
        LowBalanceThreshold = user.LowBalanceThreshold,
    };
}

internal sealed class SettingsPayloadValidator : AbstractValidator<SettingsPayload>
{
    public SettingsPayloadValidator()
    {
        RuleFor(x => x.BaseCurrency).NotEmpty().IsCurrencyCode();
        RuleFor(x => x.Timezone).NotEmpty()
            .Must(UserClock.IsValidTimezone).WithErrorCode("invalid_timezone").WithMessage("Unknown IANA time zone.");
        RuleFor(x => x.FirstDayOfMonth).InclusiveBetween(User.MinFirstDayOfMonth, User.MaxFirstDayOfMonth);
        RuleFor(x => x.LowBalanceThreshold).GreaterThanOrEqualTo(0);
    }
}

internal sealed class UpdateMeRequestValidator : AbstractValidator<UpdateMeRequest>
{
    public UpdateMeRequestValidator()
    {
        RuleFor(x => x.BaseCurrency).IsCurrencyCode().When(x => x.BaseCurrency is not null);
        RuleFor(x => x.Timezone)
            .Must(UserClock.IsValidTimezone).WithErrorCode("invalid_timezone").WithMessage("Unknown IANA time zone.")
            .When(x => x.Timezone is not null);
        RuleFor(x => x.FirstDayOfMonth).InclusiveBetween(User.MinFirstDayOfMonth, User.MaxFirstDayOfMonth);
        RuleFor(x => x.LowBalanceThreshold).GreaterThanOrEqualTo(0);
    }
}
