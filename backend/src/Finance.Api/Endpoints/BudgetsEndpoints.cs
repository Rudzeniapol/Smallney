using Finance.Application.Abstractions;
using Finance.Application.Features.Budgets;
using Finance.Domain.Budgets;

namespace Finance.Api.Endpoints;

internal static class BudgetsEndpoints
{
    public static RouteGroupBuilder MapBudgets(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/budgets").WithTags("Budgets");

        group.MapGet("/", async (FinancialMonth from, FinancialMonth to, BudgetQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.ListAsync(from, to, ct)))
            .WithName("ListBudgets")
            .WithSummary("Budgets of the months from..to (yyyy-MM)")
            .ProducesValidationProblem();

        group.MapGet("/{month}", async (FinancialMonth month, BudgetQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(month, ct)))
            .WithName("GetBudget")
            .WithSummary("Budget of a financial month (yyyy-MM, named after the month it starts in)")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapPut("/{month}", async (FinancialMonth month, BudgetPayload request, BudgetWriter writer, BudgetQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                await writer.SaveAsync(month, request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(month, ct));
            })
            .WithName("SaveBudget")
            .WithSummary("Create or replace the month's plan; lines and allocations not listed are removed")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapDelete("/{month}", async (FinancialMonth month, BudgetWriter writer, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.DeleteAsync(month, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.NoContent();
            })
            .WithName("DeleteBudget")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapGet("/{month}/summary", async (FinancialMonth month, BudgetSummaryService summaries, CancellationToken ct) =>
                TypedResults.Ok(await summaries.GetAsync(month, ct)))
            .WithName("GetBudgetSummary")
            .WithSummary("Plan vs. actual: income, savings, lines with rollover, off-budget spending")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapGet("/{month}/template", async (FinancialMonth month, BudgetQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.TemplateAsync(month, ct)))
            .WithName("GetBudgetTemplate")
            .WithSummary("Suggested plan: previous month plus recommended contributions to dated goals");

        group.MapPost("/{month}/copy-from-previous", async (FinancialMonth month, BudgetWriter writer, BudgetQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                await writer.CopyFromPreviousAsync(month, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Created($"/api/v1/budgets/{month}", await queries.GetAsync(month, ct));
            })
            .WithName("CopyBudgetFromPrevious")
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        return api;
    }
}
