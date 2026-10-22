using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using Finance.Application.Abstractions;

namespace Finance.Api.Infrastructure;

internal static class ApiServiceCollectionExtensions
{
    public const string AuthRateLimitPolicy = "auth";

    public static IServiceCollection AddApi(this IServiceCollection services)
    {
        services.AddHttpContextAccessor();
        services.AddScoped<ICurrentUser, HttpCurrentUser>();

        services.ConfigureHttpJsonOptions(o =>
        {
            o.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
            // Numbers are numbers: no "123" strings, so OpenAPI describes int64 as a plain integer.
            o.SerializerOptions.NumberHandling = JsonNumberHandling.Strict;
        });

        services.AddProblemDetails(o => o.CustomizeProblemDetails = context =>
        {
            // Problems produced by the framework (401, 404, 405, 429, ...) get a code as well.
            context.ProblemDetails.Extensions.TryAdd("code", context.ProblemDetails.Status switch
            {
                StatusCodes.Status400BadRequest => "bad_request",
                StatusCodes.Status401Unauthorized => "unauthorized",
                StatusCodes.Status403Forbidden => "forbidden",
                StatusCodes.Status404NotFound => "not_found",
                StatusCodes.Status405MethodNotAllowed => "method_not_allowed",
                StatusCodes.Status429TooManyRequests => "rate_limited",
                _ => "error",
            });
        });
        services.AddExceptionHandler<ProblemDetailsExceptionHandler>();

        services.AddOpenApi(o =>
        {
            o.AddDocumentTransformer<BearerSecurityTransformer>();
            o.AddOperationTransformer<BearerSecurityTransformer>();
            o.AddDocumentTransformer((document, _, _) =>
            {
                document.Info.Title = "Smallney Finance API";
                document.Info.Description = "Personal finance: accounts, transactions, budgets, forecast, sync. " +
                                            "Money is always integer minor units + ISO 4217 code.";
                return Task.CompletedTask;
            });
        });

        services.AddRateLimiter(o =>
        {
            o.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            o.AddPolicy(AuthRateLimitPolicy, context =>
            {
                var limit = context.RequestServices.GetRequiredService<IConfiguration>()
                    .GetValue("RateLimiting:AuthPermitPerMinute", 20);
                return RateLimitPartition.GetFixedWindowLimiter(
                    context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                    _ => new FixedWindowRateLimiterOptions { PermitLimit = limit, Window = TimeSpan.FromMinutes(1) });
            });
        });

        return services;
    }
}
