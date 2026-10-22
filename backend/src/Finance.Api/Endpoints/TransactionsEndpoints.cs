using Finance.Application.Abstractions;
using Finance.Application.Features.Transactions;
using Finance.Domain.Common;
using Finance.Domain.Transactions;

namespace Finance.Api.Endpoints;

internal static class TransactionsEndpoints
{
    public static RouteGroupBuilder MapTransactions(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/transactions").WithTags("Transactions");

        group.MapGet("/", async (
                DateOnly? from,
                DateOnly? to,
                Guid? accountId,
                Guid? categoryId,
                TransactionType? type,
                TransactionStatus? status,
                string? tag,
                string? search,
                string? cursor,
                int? limit,
                TransactionQueries queries,
                CancellationToken ct) =>
                TypedResults.Ok(await queries.ListAsync(
                    new TransactionFilter
                    {
                        From = from,
                        To = to,
                        AccountId = accountId,
                        CategoryId = categoryId,
                        Type = type,
                        Status = status,
                        Tag = tag,
                        Search = search,
                        Cursor = cursor,
                        Limit = limit,
                    },
                    ct)))
            .WithName("ListTransactions")
            .WithSummary("Newest first; pass nextCursor back as cursor for the next page")
            .ProducesValidationProblem();

        group.MapGet("/{id:guid}", async (Guid id, TransactionQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(id, ct)))
            .WithName("GetTransaction")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateTransactionRequest request, TransactionWriter writer, TransactionQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                var transaction = await writer.CreateAsync(request.Id ?? UuidV7.New(), request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Created($"/api/v1/transactions/{transaction.Id}", await queries.GetAsync(transaction.Id, ct));
            })
            .WithName("CreateTransaction")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapPut("/{id:guid}", async (Guid id, TransactionPayload request, TransactionWriter writer,
                TransactionQueries queries, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.UpdateAsync(id, request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("UpdateTransaction")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapPost("/{id:guid}/confirm", async (Guid id, ConfirmTransactionRequest? request, TransactionWriter writer,
                TransactionQueries queries, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.ConfirmAsync(id, request ?? new ConfirmTransactionRequest(), ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("ConfirmTransaction")
            .WithSummary("Planned/Skipped → Cleared, optionally with a corrected amount or date")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict);

        group.MapPost("/{id:guid}/skip", async (Guid id, TransactionWriter writer, TransactionQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                await writer.SkipAsync(id, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("SkipTransaction")
            .WithSummary("Planned → Skipped (undo: update the status back to Planned)")
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict);

        group.MapDelete("/{id:guid}", async (Guid id, TransactionWriter writer, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.DeleteAsync(id, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.NoContent();
            })
            .WithName("DeleteTransaction")
            .ProducesProblem(StatusCodes.Status404NotFound);

        return api;
    }
}
