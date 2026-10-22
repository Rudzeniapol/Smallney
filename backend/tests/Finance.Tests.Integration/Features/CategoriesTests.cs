using System.Net;
using Finance.Application.Features.Categories;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class CategoriesTests(ApiFactory factory)
{
    [Fact]
    public async Task Create_child_update_and_delete()
    {
        var user = await factory.RegisterUserAsync();
        var parent = await user.CategoryAsync("Кафе и рестораны");

        var child = await user.PostAsync<CategoryResponse>("/api/v1/categories", new CreateCategoryRequest
        {
            Id = UuidV7.New(), Name = "Кофе", Kind = CategoryKind.Expense, ParentId = parent.Id, Icon = "coffee", Color = "#FF8A5B",
        });
        child.ParentId.Should().Be(parent.Id);

        var renamed = await user.PutAsync<CategoryResponse>($"/api/v1/categories/{child.Id}", new CategoryPayload
        {
            Name = "Кофейни", Kind = CategoryKind.Expense, ParentId = parent.Id, IsArchived = true,
        });
        renamed.Name.Should().Be("Кофейни");
        renamed.IsArchived.Should().BeTrue();
        (await user.GetAsync<List<CategoryResponse>>("/api/v1/categories")).Should().NotContain(c => c.Id == child.Id);
        (await user.GetAsync<List<CategoryResponse>>("/api/v1/categories?includeArchived=true")).Should().Contain(c => c.Id == child.Id);

        (await user.Client.DeleteAsync($"/api/v1/categories/{child.Id}")).StatusCode.Should().Be(HttpStatusCode.NoContent);
        await (await user.Client.GetAsync($"/api/v1/categories/{child.Id}")).ShouldBeProblemAsync(HttpStatusCode.NotFound, "not_found");
    }

    [Fact]
    public async Task Third_level_is_rejected()
    {
        var user = await factory.RegisterUserAsync();
        var taxi = await user.CategoryAsync("Такси");

        var response = await user.PostAsync("/api/v1/categories",
            new CreateCategoryRequest { Name = "Яндекс", Kind = CategoryKind.Expense, ParentId = taxi.Id });

        await response.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_depth_exceeded");
    }

    [Fact]
    public async Task Parent_with_children_cannot_be_nested()
    {
        var user = await factory.RegisterUserAsync();
        var transport = await user.CategoryAsync("Транспорт");
        var food = await user.CategoryAsync("Продукты");

        var response = await user.PutAsync($"/api/v1/categories/{transport.Id}",
            new CategoryPayload { Name = transport.Name, Kind = CategoryKind.Expense, ParentId = food.Id });

        await response.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_depth_exceeded");
    }

    [Fact]
    public async Task Child_kind_must_match_parent()
    {
        var user = await factory.RegisterUserAsync();
        var food = await user.CategoryAsync("Продукты");

        var response = await user.PostAsync("/api/v1/categories",
            new CreateCategoryRequest { Name = "Возврат", Kind = CategoryKind.Income, ParentId = food.Id });

        await response.ShouldBeProblemAsync(HttpStatusCode.UnprocessableEntity, "category_kind_mismatch");
    }

    [Fact]
    public async Task Delete_rules()
    {
        var user = await factory.RegisterUserAsync();
        var transport = await user.CategoryAsync("Транспорт");
        var uncategorized = (await user.GetAsync<List<CategoryResponse>>("/api/v1/categories"))
            .First(c => c.SystemCode == Category.UncategorizedCode);
        var food = await user.CategoryAsync("Продукты");
        var card = await user.CreateAccountAsync();
        await user.ExpenseAsync(card.Id, 100, new DateOnly(2026, 10, 1));

        await (await user.Client.DeleteAsync($"/api/v1/categories/{transport.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "category_has_children");
        await (await user.Client.DeleteAsync($"/api/v1/categories/{uncategorized.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "category_is_system");
        await (await user.Client.DeleteAsync($"/api/v1/categories/{food.Id}"))
            .ShouldBeProblemAsync(HttpStatusCode.Conflict, "category_has_transactions");

        var kindChange = await user.PutAsync($"/api/v1/categories/{food.Id}",
            new CategoryPayload { Name = food.Name, Kind = CategoryKind.Income });
        await kindChange.ShouldBeProblemAsync(HttpStatusCode.Conflict, "category_kind_locked");
    }

    [Fact]
    public async Task List_can_be_filtered_by_kind()
    {
        var user = await factory.RegisterUserAsync();

        var income = await user.GetAsync<List<CategoryResponse>>("/api/v1/categories?kind=Income");

        income.Should().NotBeEmpty().And.OnlyContain(c => c.Kind == CategoryKind.Income);
    }
}
