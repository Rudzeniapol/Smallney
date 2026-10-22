using Finance.Application.Features.Rates;

namespace Finance.Api.Endpoints;

internal static class RatesEndpoints
{
    public static RouteGroupBuilder MapRates(this RouteGroupBuilder api)
    {
        api.MapGroup("/rates").WithTags("Rates")
            .MapGet("/", async (DateOnly? date, RatesQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(date, ct)))
            .WithName("GetRates")
            .WithSummary("Official NBRB rates (BYN per 1 unit), latest on or before the date (default: today)");

        return api;
    }
}
