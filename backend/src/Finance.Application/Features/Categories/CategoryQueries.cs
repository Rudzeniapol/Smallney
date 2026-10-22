using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Categories;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Categories;

public sealed class CategoryQueries(IAppDbContext db)
{
    /// <summary>Flat list (parents and children); clients build the tree from <c>parentId</c>.</summary>
    public async Task<IReadOnlyList<CategoryResponse>> ListAsync(
        CategoryKind? kind,
        bool includeArchived,
        CancellationToken ct)
    {
        var query = db.Categories.AsNoTracking();
        if (kind is not null)
        {
            query = query.Where(c => c.Kind == kind);
        }

        if (!includeArchived)
        {
            query = query.Where(c => !c.IsArchived);
        }

        var categories = await query.OrderBy(c => c.Kind).ThenBy(c => c.Name).ToListAsync(ct);
        return categories.Select(CategoryResponse.From).ToList();
    }

    public async Task<CategoryResponse> GetAsync(Guid id, CancellationToken ct)
    {
        var category = await db.Categories.AsNoTracking().FirstOrDefaultAsync(c => c.Id == id, ct)
                       ?? throw new NotFoundException("Category", id);
        return CategoryResponse.From(category);
    }
}
