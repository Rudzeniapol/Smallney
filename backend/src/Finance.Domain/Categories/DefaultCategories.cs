namespace Finance.Domain.Categories;

/// <summary>The category set every new user starts with (Russian names).</summary>
public static class DefaultCategories
{
    public sealed record Template(
        string Name,
        CategoryKind Kind,
        string Icon,
        string Color,
        IReadOnlyList<Template>? Children = null,
        string? SystemCode = null);

    public static IReadOnlyList<Template> Templates { get; } =
    [
        new("Продукты", CategoryKind.Expense, "cart", "#85BB65"),
        new("Кафе и рестораны", CategoryKind.Expense, "cafe", "#FF8A5B"),
        new("Транспорт", CategoryKind.Expense, "transport", "#5CC8FF",
        [
            new("Такси", CategoryKind.Expense, "taxi", "#5CC8FF"),
            new("Общественный транспорт", CategoryKind.Expense, "bus", "#5CC8FF"),
            new("Топливо", CategoryKind.Expense, "fuel", "#5CC8FF"),
        ]),
        new("Дом", CategoryKind.Expense, "home", "#9C90FF",
        [
            new("Аренда", CategoryKind.Expense, "key", "#9C90FF"),
            new("Коммунальные услуги", CategoryKind.Expense, "utilities", "#9C90FF"),
        ]),
        new("Связь и интернет", CategoryKind.Expense, "phone", "#5CC8FF"),
        new("Подписки", CategoryKind.Expense, "subscription", "#F2C14E"),
        new("Здоровье", CategoryKind.Expense, "health", "#FF6B7F"),
        new("Одежда", CategoryKind.Expense, "clothes", "#FF7A9C"),
        new("Досуг", CategoryKind.Expense, "fun", "#C58BFF"),
        new("Подарки", CategoryKind.Expense, "gift", "#FF8A5B"),
        new("Образование", CategoryKind.Expense, "education", "#5CC8FF"),
        new("Прочее", CategoryKind.Expense, "other", "#98A1B3"),
        new("Без категории", CategoryKind.Expense, "uncategorized", "#98A1B3", SystemCode: Category.UncategorizedCode),

        new("Зарплата", CategoryKind.Income, "salary", "#85BB65"),
        new("Подработка", CategoryKind.Income, "freelance", "#A6D987"),
        new("Проценты и кэшбэк", CategoryKind.Income, "interest", "#F2C14E"),
        new("Подарки", CategoryKind.Income, "gift", "#FF8A5B"),
        new("Прочие доходы", CategoryKind.Income, "other", "#98A1B3"),
        new("Без категории", CategoryKind.Income, "uncategorized", "#98A1B3", SystemCode: Category.UncategorizedCode),
    ];

    public static List<Category> CreateFor(Guid userId, Func<Guid> newId)
    {
        var result = new List<Category>();
        foreach (var template in Templates)
        {
            var parent = Create(template, userId, newId(), parentId: null);
            result.Add(parent);
            foreach (var child in template.Children ?? [])
            {
                result.Add(Create(child, userId, newId(), parent.Id));
            }
        }

        return result;
    }

    private static Category Create(Template template, Guid userId, Guid id, Guid? parentId) => new()
    {
        Id = id,
        UserId = userId,
        Name = template.Name,
        Kind = template.Kind,
        Icon = template.Icon,
        Color = template.Color,
        ParentId = parentId,
        SystemCode = template.SystemCode,
    };
}
