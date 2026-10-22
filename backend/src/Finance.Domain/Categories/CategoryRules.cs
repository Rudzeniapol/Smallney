using Finance.Domain.Common;

namespace Finance.Domain.Categories;

public static class CategoryRules
{
    /// <summary>Checks that <paramref name="parent"/> can hold the category (two levels max, same kind).</summary>
    public static void EnsureValidParent(Guid categoryId, CategoryKind kind, Category? parent, bool categoryHasChildren)
    {
        if (parent is null)
        {
            return;
        }

        if (parent.Id == categoryId)
        {
            throw new DomainException("category_self_parent", "A category cannot be its own parent.");
        }

        if (parent.ParentId is not null)
        {
            throw new DomainException("category_depth_exceeded", "Categories can be nested at most two levels deep.");
        }

        if (categoryHasChildren)
        {
            throw new DomainException(
                "category_depth_exceeded",
                "A category with subcategories cannot become a subcategory.");
        }

        if (parent.Kind != kind)
        {
            throw new DomainException("category_kind_mismatch", "A subcategory must have the same kind as its parent.");
        }
    }
}
