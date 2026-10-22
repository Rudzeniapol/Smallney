using Finance.Application.Abstractions;
using Finance.Application.Features.Accounts;
using Finance.Domain.Common;

namespace Finance.Api.Endpoints;

internal static class AccountsEndpoints
{
    public static RouteGroupBuilder MapAccounts(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/accounts").WithTags("Accounts");

        group.MapGet("/", async (bool? includeArchived, AccountQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.ListAsync(includeArchived ?? false, ct)))
            .WithName("ListAccounts")
            .WithSummary("Accounts with their computed balances");

        group.MapGet("/summary", async (AccountQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.SummaryAsync(ct)))
            .WithName("GetAccountsSummary")
            .WithSummary("Total capital in the base currency (accounts with includeInTotals)");

        group.MapGet("/{id:guid}", async (Guid id, AccountQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(id, ct)))
            .WithName("GetAccount")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateAccountRequest request, AccountWriter writer, AccountQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                var account = await writer.CreateAsync(request.Id ?? UuidV7.New(), request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Created($"/api/v1/accounts/{account.Id}", await queries.GetAsync(account.Id, ct));
            })
            .WithName("CreateAccount")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict);

        group.MapPut("/{id:guid}", async (Guid id, AccountPayload request, AccountWriter writer, AccountQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                await writer.UpdateAsync(id, request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("UpdateAccount")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict);

        group.MapDelete("/{id:guid}", async (Guid id, AccountWriter writer, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.DeleteAsync(id, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.NoContent();
            })
            .WithName("DeleteAccount")
            .WithSummary("Soft-delete an account without transactions (archive it otherwise)")
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict);

        return api;
    }
}
