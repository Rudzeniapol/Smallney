using Finance.Application.Features.Forecast;
using Finance.Domain.Forecasting;

namespace Finance.Api.Endpoints;

internal static class ForecastEndpoints
{
    public static RouteGroupBuilder MapForecast(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/forecast").WithTags("Forecast");

        group.MapGet("/", async (DateOnly? from, DateOnly? to, ForecastGranularity? granularity, string[]? extraOneOff,
                ForecastService forecast, CancellationToken ct) =>
            {
                var request = new ForecastRequest
                {
                    From = from,
                    To = to,
                    Granularity = granularity,
                    ExtraOneOffs = extraOneOff?.Select(ForecastOneOff.Parse).ToList(),
                };
                return TypedResults.Ok(await forecast.GetAsync(request, ct));
            })
            .WithName("GetForecast")
            .WithSummary("Balance forecast (up to 24 months)")
            .WithDescription(
                "Repeat extraOneOff=yyyy-MM-dd|amount|accountId[|label] for a \"what if\" scenario " +
                "(amount: signed minor units of the account currency, negative = spending).")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapPost("/", async (ForecastRequest request, ForecastService forecast, CancellationToken ct) =>
                TypedResults.Ok(await forecast.GetAsync(request, ct)))
            .WithName("PostForecast")
            .WithSummary("Same as GET, with the \"what if\" operations in the body; nothing is saved")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        return api;
    }
}
