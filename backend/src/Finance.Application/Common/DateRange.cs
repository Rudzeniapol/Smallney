using FluentValidation;

namespace Finance.Application.Common;

/// <summary>Inclusive date range of a query.</summary>
public sealed record DateRange(DateOnly From, DateOnly To);

internal sealed class DateRangeValidator : AbstractValidator<DateRange>
{
    public const int MaxDays = 800;

    public DateRangeValidator()
    {
        RuleFor(x => x.To).GreaterThanOrEqualTo(x => x.From);
        RuleFor(x => x.To)
            .Must((range, to) => to.DayNumber - range.From.DayNumber <= MaxDays)
            .WithMessage($"The range can be at most {MaxDays} days.");
    }
}
