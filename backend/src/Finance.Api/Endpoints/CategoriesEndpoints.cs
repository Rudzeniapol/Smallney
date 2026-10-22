using Finance.Application.Abstractions;
using Finance.Application.Features.Categories;
using Finance.Domain.Categories;
using Finance.Domain.Common;

namespace Finance.Api.Endpoints;

internal static class CategoriesEndpoints
{
    public static RouteGroupBuilder MapCategories(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/categories").WithTags("Categories");

        group.MapGet("/", async (CategoryKind? kind, bool? includeArchived, CategoryQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.ListAsync(kind, includeArchived ?? false, ct)))
            .WithName("ListCategories")
            .WithSummary("Flat list; build the two-level tree from parentId");

        group.MapGet("/{id:guid}", async (Guid id, CategoryQueries queries, CancellationToken ct) =>
                TypedResults.Ok(await queries.GetAsync(id, ct)))
            .WithName("GetCategory")
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapPost("/", async (CreateCategoryRequest request, CategoryWriter writer, CategoryQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                var category = await writer.CreateAsync(request.Id ?? UuidV7.New(), request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Created($"/api/v1/categories/{category.Id}", await queries.GetAsync(category.Id, ct));
            })
            .WithName("CreateCategory")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapPut("/{id:guid}", async (Guid id, CategoryPayload request, CategoryWriter writer, CategoryQueries queries,
                IAppDbContext db, CancellationToken ct) =>
            {
                await writer.UpdateAsync(id, request, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.Ok(await queries.GetAsync(id, ct));
            })
            .WithName("UpdateCategory")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict)
            .ProducesProblem(StatusCodes.Status422UnprocessableEntity);

        group.MapDelete("/{id:guid}", async (Guid id, CategoryWriter writer, IAppDbContext db, CancellationToken ct) =>
            {
                await writer.DeleteAsync(id, ct);
                await db.SaveChangesAsync(ct);
                return TypedResults.NoContent();
            })
            .WithName("DeleteCategory")
            .ProducesProblem(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status409Conflict);

        return api;
    }
}
