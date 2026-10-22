using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Categories;

/// <summary>Category write rules shared by REST and sync. Does not call SaveChanges.</summary>
public sealed class CategoryWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    IValidator<CategoryPayload> validator)
{
    public async Task<Category> CreateAsync(Guid id, CategoryPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        await db.Categories.EnsureIdIsFreeAsync(id, ct);

        var category = new Category { Id = id, UserId = currentUser.RequiredUserId() };
        await EnsureParentAsync(id, payload, hasChildren: false, ct);
        Apply(category, payload);
        db.Categories.Add(category);
        return category;
    }

    public async Task<Category> UpdateAsync(Guid id, CategoryPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        var category = await db.Categories.FirstOrDefaultAsync(c => c.Id == id, ct)
                       ?? throw new NotFoundException("Category", id);

        var hasChildren = await db.Categories.AnyAsync(c => c.ParentId == id, ct);
        if (payload.Kind != category.Kind)
        {
            if (category.SystemCode is not null || hasChildren || await HasTransactionsAsync(id, ct))
            {
                throw new ConflictException(
                    "category_kind_locked",
                    "The kind of a built-in category, or of one with subcategories or transactions, cannot be changed.");
            }
        }

        await EnsureParentAsync(id, payload, hasChildren, ct);
        if (category.SystemCode is not null && payload.ParentId is not null)
        {
            throw new DomainException("category_is_system", "A built-in category cannot become a subcategory.");
        }

        Apply(category, payload);
        return category;
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var category = await db.Categories.FirstOrDefaultAsync(c => c.Id == id, ct)
                       ?? throw new NotFoundException("Category", id);

        if (category.SystemCode is not null)
        {
            throw new ConflictException("category_is_system", "A built-in category cannot be deleted.");
        }

        if (await db.Categories.AnyAsync(c => c.ParentId == id, ct))
        {
            throw new ConflictException(
                "category_has_children",
                "The category has subcategories. Delete or move them first.");
        }

        if (await HasTransactionsAsync(id, ct))
        {
            throw new ConflictException(
                "category_has_transactions",
                "The category has transactions. Recategorize them or archive the category.");
        }

        category.MarkDeleted(clock.GetUtcNow().UtcDateTime);
    }

    private Task<bool> HasTransactionsAsync(Guid categoryId, CancellationToken ct) =>
        db.Transactions.AnyAsync(t => t.CategoryId == categoryId, ct);

    private async Task EnsureParentAsync(Guid id, CategoryPayload payload, bool hasChildren, CancellationToken ct)
    {
        if (payload.ParentId is not { } parentId)
        {
            return;
        }

        var parent = await db.Categories.AsNoTracking().FirstOrDefaultAsync(c => c.Id == parentId, ct)
                     ?? throw new DomainException("parent_not_found", $"Parent category '{parentId}' was not found.");
        CategoryRules.EnsureValidParent(id, payload.Kind!.Value, parent, hasChildren);
    }

    private static void Apply(Category category, CategoryPayload p)
    {
        category.Name = p.Name!.Trim();
        category.Kind = p.Kind!.Value;
        category.ParentId = p.ParentId;
        category.Icon = p.Icon;
        category.Color = p.Color;
        category.IsArchived = p.IsArchived;
    }
}
