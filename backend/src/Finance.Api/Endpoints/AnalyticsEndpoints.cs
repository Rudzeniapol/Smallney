using Finance.Application.Features.Analytics;
using Finance.Domain.Categories;

namespace Finance.Api.Endpoints;

internal static class AnalyticsEndpoints
{
    public static RouteGroupBuilder MapAnalytics(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/analytics").WithTags("Analytics");

        group.MapGet("/categories", async (DateOnly? from, DateOnly? to, CategoryKind? kind, AnalyticsService analytics, CancellationToken ct) =>
                TypedResults.Ok(await analytics.CategoriesAsync(from, to, kind ?? CategoryKind.Expense, ct)))
            .WithName("GetCategoryBreakdown")
            .WithSummary("Spending (or income) by category with subcategories, share and change to the previous period")
            .ProducesValidationProblem();

        group.MapGet("/monthly", async (int? months, Guid? categoryId, AnalyticsService analytics, CancellationToken ct) =>
                TypedResults.Ok(await analytics.MonthlyAsync(months, categoryId, ct)))
            .WithName("GetMonthlyDynamics")
            .WithSummary("Income and expense per financial month (last N months, optionally one category with subcategories)")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status404NotFound);

        group.MapGet("/compare", async (DateOnly? from, DateOnly? to, AnalyticsService analytics, CancellationToken ct) =>
                TypedResults.Ok(await analytics.CompareAsync(from, to, ct)))
            .WithName("ComparePeriods")
            .WithSummary("Income, expense and net of a period against the previous one (absolute and %)")
            .ProducesValidationProblem();

        group.MapGet("/net-worth", async (int? months, bool? includeExcluded, AnalyticsService analytics, CancellationToken ct) =>
                TypedResults.Ok(await analytics.NetWorthAsync(months, includeExcluded ?? false, ct)))
            .WithName("GetNetWorth")
            .WithSummary("Sum of account balances at each month end")
            .ProducesValidationProblem();

        group.MapGet("/top-expenses", async (DateOnly? from, DateOnly? to, int? limit, AnalyticsService analytics, CancellationToken ct) =>
                TypedResults.Ok(await analytics.TopExpensesAsync(from, to, limit, ct)))
            .WithName("GetTopExpenses")
            .ProducesValidationProblem();

        group.MapGet("/averages", async (DateOnly? from, DateOnly? to, AnalyticsService analytics, CancellationToken ct) =>
                TypedResults.Ok(await analytics.AveragesAsync(from, to, ct)))
            .WithName("GetSpendingAverages")
            .WithSummary("Average spending per day, week and month over the elapsed part of the period")
            .ProducesValidationProblem();

        return api;
    }
}
