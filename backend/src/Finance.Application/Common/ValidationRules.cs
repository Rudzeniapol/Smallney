using System.Text.RegularExpressions;
using Finance.Domain.Common;
using Finance.Domain.Monetary;
using FluentValidation;

namespace Finance.Application.Common;

public static partial class ValidationRules
{
    public static readonly DateOnly MinDate = new(1990, 1, 1);
    public static readonly DateOnly MaxDate = new(2100, 12, 31);

    public static IRuleBuilderOptions<T, string?> IsCurrencyCode<T>(this IRuleBuilder<T, string?> rule) =>
        rule.Must(code => Currency.IsSupported(code?.Trim().ToUpperInvariant()))
            .WithErrorCode("unsupported_currency")
            .WithMessage("'{PropertyValue}' is not a supported ISO 4217 currency code.");

    public static IRuleBuilderOptions<T, string?> IsHexColor<T>(this IRuleBuilder<T, string?> rule) =>
        rule.Must(color => color is null || HexColor().IsMatch(color))
            .WithErrorCode("invalid_color")
            .WithMessage("Color must look like #RRGGBB or #RRGGBBAA.");

    public static IRuleBuilderOptions<T, DateOnly?> IsSaneDate<T>(this IRuleBuilder<T, DateOnly?> rule) =>
        rule.Must(date => date is null || (date >= MinDate && date <= MaxDate))
            .WithErrorCode("date_out_of_range")
            .WithMessage($"Date must be between {MinDate:yyyy-MM-dd} and {MaxDate:yyyy-MM-dd}.");

    /// <summary>Client-generated ids must be UUID v7 (time-ordered, needed for offline-first).</summary>
    public static void EnsureUuidV7(Guid id, string property = "id")
    {
        if (!UuidV7.IsValid(id))
        {
            throw new ValidationException(
                [new FluentValidation.Results.ValidationFailure(property, "Id must be a UUID v7.") { ErrorCode = "invalid_id" }]);
        }
    }

    [GeneratedRegex("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$")]
    private static partial Regex HexColor();
}
