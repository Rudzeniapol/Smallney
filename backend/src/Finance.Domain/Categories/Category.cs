using Finance.Domain.Common;

namespace Finance.Domain.Categories;

public enum CategoryKind
{
    Income,
    Expense,
}

/// <summary>Income or expense category. At most two levels: a root and its children.</summary>
public sealed class Category : UserOwnedEntity
{
    /// <summary><see cref="SystemCode"/> of the fallback category used when nothing else matches.</summary>
    public const string UncategorizedCode = "uncategorized";

    public string Name { get; set; } = string.Empty;

    public CategoryKind Kind { get; set; }

    public Guid? ParentId { get; set; }

    public string? Icon { get; set; }

    public string? Color { get; set; }

    public bool IsArchived { get; set; }

    /// <summary>Stable identifier of a built-in category (e.g. "uncategorized"); null for user-created ones.</summary>
    public string? SystemCode { get; set; }
}
