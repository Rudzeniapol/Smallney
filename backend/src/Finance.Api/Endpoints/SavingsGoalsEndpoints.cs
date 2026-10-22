using Finance.Application.Abstractions;
using Finance.Application.Features.Goals;
using Finance.Domain.Common;

namespace Finance.Api.Endpoints;

internal static class SavingsGoalsEndpoints
{
    public static RouteGroupBuilder MapSavingsGoals(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/savings-goals").WithTags("Savings goals");

        group.MapGet("/", async (bool? includeCompleted, GoalQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.ListAsync(includeCompleted ?? true, ct)))
            .WithName("ListSavingsGoals")
            .WithSummary("Goals with progress and the recommended monthly contribution");

        group.MapGet("/{id:guid}", async (Guid id, GoalQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(id, ct)))
            .WithName("GetSavingsGoal")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateSavingsGoalRequest request, GoalWriter writer, GoalQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                var goal = await writer.CreateAsync(request.Id ?? UuidV7.New(), request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Created($"/api/v1/savings-goals/{goal.Id}", await queries.GetAsync(goal.Id, ct));
            })
            .WithName("CreateSavingsGoal")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapPut("/{id:guid}", async (Guid id, SavingsGoalPayload request, GoalWriter writer, GoalQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                await writer.UpdateAsync(id, request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("UpdateSavingsGoal")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapDelete("/{id:guid}", async (Guid id, GoalWriter writer, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.DeleteAsync(id, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.NoContent();
            })
            .WithName("DeleteSavingsGoal")
            .WithSummary("Delete a goal nothing refers to (otherwise mark it completed)")
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict);

        return api;
    }
}
