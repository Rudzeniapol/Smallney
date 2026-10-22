using System.Globalization;
using Finance.Domain.Forecasting;
using FluentValidation;
using FluentValidation.Results;

namespace Finance.Application.Features.Forecast;

/// <summary>An unsaved "what if" operation.</summary>
public sealed record ForecastOneOff
{
    public DateOnly? Date { get; init; }

    /// <summary>Signed minor units of the account currency: negative = money leaves the account.</summary>
    public long Amount { get; init; }

    public Guid? AccountId { get; init; }

    public string? Label { get; init; }

    /// <summary>Query form: <c>yyyy-MM-dd|amount|accountId[|label]</c>.</summary>
    public static ForecastOneOff Parse(string value, int index)
    {
        var parts = value.Split('|', 4);
        if (parts.Length >= 3
            && DateOnly.TryParseExact(parts[0], "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date)
            && long.TryParse(parts[1], NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out var amount)
            && Guid.TryParse(parts[2], out var accountId))
        {
            return new ForecastOneOff { Date = date, Amount = amount, AccountId = accountId, Label = parts.Length == 4 ? parts[3] : null };
        }

        throw new ValidationException([new ValidationFailure($"extraOneOff[{index}]", "Use yyyy-MM-dd|amount|accountId[|label].")
        {
            ErrorCode = "invalid_one_off",
        }]);
    }
}

public sealed record ForecastRequest
{
    /// <summary>First day of the returned series; defaults to (and never precedes) today.</summary>
    public DateOnly? From { get; init; }

    /// <summary>Last day; defaults to today + 3 months, at most today + 24 months.</summary>
    public DateOnly? To { get; init; }

    public ForecastGranularity? Granularity { get; init; }

    /// <summary>"What if" operations; when present the response also contains <c>scenario</c>.</summary>
    public IReadOnlyList<ForecastOneOff>? ExtraOneOffs { get; init; }
}

public sealed record VariableSpendingResponse(string Month, DateOnly Start, DateOnly End, long Total, VariableSpendingSource Source);

/// <param name="EndBalanceDifference">Scenario total minus baseline total on the last day, base currency.</param>
public sealed record ForecastScenarioResponse(
    IReadOnlyList<ForecastOneOff> ExtraOneOffs,
    IReadOnlyList<BalancePoint> Total,
    IReadOnlyList<ForecastAlarm> Alarms,
    IReadOnlyList<GoalForecast> Goals,
    long EndBalanceDifference);

/// <summary>
/// Balances per account (account currency) and in total (base currency, latest rate), alarms, goal outlook,
/// the assumed variable spending and, with "what if" operations, the scenario.
/// </summary>
public sealed record ForecastResponse(
    DateOnly Today,
    DateOnly From,
    DateOnly To,
    ForecastGranularity Granularity,
    string BaseCurrency,
    DateTime GeneratedAt,
    Guid? SpendingAccountId,
    long LowBalanceThreshold,
    IReadOnlyList<AccountSeries> Accounts,
    IReadOnlyList<BalancePoint> Total,
    IReadOnlyList<ForecastAlarm> Alarms,
    IReadOnlyList<GoalForecast> Goals,
    IReadOnlyList<VariableSpendingResponse> VariableSpending,
    ForecastScenarioResponse? Scenario);

internal sealed class ForecastRequestValidator : AbstractValidator<ForecastRequest>
{
    public const int MaxOneOffs = 20;

    public ForecastRequestValidator()
    {
        RuleFor(x => x.To).GreaterThanOrEqualTo(x => x.From).When(x => x.From is not null && x.To is not null);
        RuleFor(x => x.Granularity).IsInEnum();
        RuleFor(x => x.ExtraOneOffs).Must(o => o is null || o.Count <= MaxOneOffs)
            .WithMessage($"At most {MaxOneOffs} operations are allowed.");
        RuleForEach(x => x.ExtraOneOffs).ChildRules(o =>
        {
            o.RuleFor(x => x.Date).NotNull();
            o.RuleFor(x => x.AccountId).NotNull();
            o.RuleFor(x => x.Amount).NotEqual(0);
            o.RuleFor(x => x.Label).MaximumLength(100);
        });
    }
}
