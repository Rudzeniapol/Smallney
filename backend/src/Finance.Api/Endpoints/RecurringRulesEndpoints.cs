using Finance.Application.Abstractions;
using Finance.Application.Features.Recurring;
using Finance.Domain.Common;

namespace Finance.Api.Endpoints;

internal static class RecurringRulesEndpoints
{
    public static RouteGroupBuilder MapRecurringRules(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/recurring-rules").WithTags("Recurring rules");

        group.MapGet("/", async (bool? includeInactive, RecurringQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.ListAsync(includeInactive ?? false, ct)))
            .WithName("ListRecurringRules")
            .WithSummary("Rules ordered by their next occurrence");

        group.MapGet("/occurrences", async (DateOnly from, DateOnly to, RecurringQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.OccurrencesAsync(from, to, ruleId: null, ct)))
            .WithName("ListOccurrences")
            .WithSummary("Occurrences of all active rules in a period, merged with materialized transactions")
            .ProducesValidationProblem();

        group.MapGet("/{id:guid}", async (Guid id, RecurringQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(id, ct)))
            .WithName("GetRecurringRule")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapGet("/{id:guid}/occurrences", async (Guid id, DateOnly from, DateOnly to, RecurringQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.OccurrencesAsync(from, to, id, ct)))
            .WithName("ListRuleOccurrences")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateRecurringRuleRequest request, RecurringRuleWriter writer, RecurringQueries queries,
                RecurringMaterializer materializer, IAppDbContext db, ICurrentUser user, CancellationToken ct) =>
            {
                var rule = await writer.CreateAsync(request.Id ?? UuidV7.New(), request, ct);
                await db.SaveChangesAsync(ct);
                await materializer.MaterializeForUserAsync(user.RequiredUserId(), ct);
                return TypedResults.Created($"/api/v1/recurring-rules/{rule.Id}", await queries.GetAsync(rule.Id, ct));
            })
            .WithName("CreateRecurringRule")
            .WithSummary("Create a rule; an occurrence due today becomes a Planned transaction right away")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapPut("/{id:guid}", async (Guid id, RecurringRulePayload request, RecurringRuleWriter writer, RecurringQueries queries,
                RecurringMaterializer materializer, IAppDbContext db, ICurrentUser user, CancellationToken ct) =>
            {
                await writer.UpdateAsync(id, request, ct);
                await db.SaveChangesAsync(ct);
                await materializer.MaterializeForUserAsync(user.RequiredUserId(), ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("UpdateRecurringRule")
            .WithSummary("Update a rule; already materialized transactions are not changed")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapDelete("/{id:guid}", async (Guid id, RecurringRuleWriter writer, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.DeleteAsync(id, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.NoContent();
            })
            .WithName("DeleteRecurringRule")
            .WithSummary("Delete a rule and its unconfirmed Planned transactions")
            .ProducesProblem(StatusCodes.Status404NotFound);

        return api;
    }
}
