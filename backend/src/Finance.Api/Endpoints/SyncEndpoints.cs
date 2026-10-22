using Finance.Application.Features.Sync;

namespace Finance.Api.Endpoints;

internal static class SyncEndpoints
{
    public static RouteGroupBuilder MapSync(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/sync").WithTags("Sync");

        group.MapPost("/push", async (SyncPushRequest request, SyncService sync, CancellationToken ct) =>
                TypedResults.Ok(await sync.PushAsync(request, ct)))
            .WithName("SyncPush")
            .WithSummary("Apply a batch of client changes (idempotent by id + clientUpdatedAt)")
            .WithDescription(
                "Each change is accepted (with the entity's new version) or rejected with a reason; one rejection does not " +
                "affect the rest. Last write wins in arrival order; a deleted entity cannot be changed again. " +
                "Payloads have the same shape as the data returned by pull.")
            .ProducesValidationProblem();

        group.MapGet("/pull", async (long? since, int? limit, SyncService sync, CancellationToken ct) =>
                TypedResults.Ok(await sync.PullAsync(since ?? 0, limit, ct)))
            .WithName("SyncPull")
            .WithSummary("Changes with version > since (deleted ones included), oldest first")
            .ProducesValidationProblem();

        return api;
    }
}
