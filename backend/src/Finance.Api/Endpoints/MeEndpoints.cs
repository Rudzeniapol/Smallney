using System.Text.Json;
using System.Text.Json.Nodes;
using Finance.Application.Features.Me;
using Microsoft.AspNetCore.Http.Json;
using Microsoft.Extensions.Options;

namespace Finance.Api.Endpoints;

internal static class MeEndpoints
{
    public static RouteGroupBuilder MapMe(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/me").WithTags("Me");

        group.MapGet("/", async (MeService me, CancellationToken ct) => TypedResults.Ok(await me.GetAsync(ct)))
            .WithName("GetMe");

        group.MapPatch("/", async (HttpRequest http, MeService me, IOptions<JsonOptions> json, CancellationToken ct) =>
            {
                if (await JsonNode.ParseAsync(http.Body, cancellationToken: ct) is not JsonObject patch)
                {
                    throw new BadHttpRequestException("A JSON object is expected.");
                }

                var request = patch.Deserialize<UpdateMeRequest>(json.Value.SerializerOptions)!;
                var present = patch.Select(p => p.Key).ToHashSet(StringComparer.OrdinalIgnoreCase);
                return TypedResults.Ok(await me.PatchAsync(request, present, ct));
            })
            .WithName("UpdateMe")
            .WithSummary("Update settings (JSON Merge Patch: absent = unchanged, null = clear)")
            .Accepts<UpdateMeRequest>("application/merge-patch+json", "application/json")
            .Produces<MeResponse>()
            .ProducesValidationProblem();

        return api;
    }
}
