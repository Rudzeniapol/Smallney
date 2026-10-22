using Finance.Api.Infrastructure;
using Finance.Application.Features.Auth;

namespace Finance.Api.Endpoints;

internal static class AuthEndpoints
{
    public static RouteGroupBuilder MapAuth(this RouteGroupBuilder api)
    {
        var group = api.MapGroup("/auth")
            .WithTags("Auth")
            .AllowAnonymous()
            .RequireRateLimiting(ApiServiceCollectionExtensions.AuthRateLimitPolicy);

        group.MapPost("/register", async (RegisterRequest request, AuthService auth, CancellationToken ct) =>
                TypedResults.Created("/api/v1/me", await auth.RegisterAsync(request, ct)))
            .WithName("Register")
            .WithSummary("Create a user with the default categories and sign in")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status409Conflict);

        group.MapPost("/login", async (LoginRequest request, AuthService auth, CancellationToken ct) =>
                TypedResults.Ok(await auth.LoginAsync(request, ct)))
            .WithName("Login")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status401Unauthorized);

        group.MapPost("/refresh", async (RefreshRequest request, AuthService auth, CancellationToken ct) =>
                TypedResults.Ok(await auth.RefreshAsync(request, ct)))
            .WithName("RefreshToken")
            .WithSummary("Rotate the refresh token and get a new access token")
            .WithDescription("A refresh token can be used once. Reusing a rotated token revokes the whole session.")
            .ProducesValidationProblem()
            .ProducesProblem(StatusCodes.Status401Unauthorized);

        group.MapPost("/logout", async (RefreshRequest request, AuthService auth, CancellationToken ct) =>
            {
                await auth.LogoutAsync(request, ct);
                return TypedResults.NoContent();
            })
            .WithName("Logout")
            .WithSummary("Revoke the session the refresh token belongs to");

        return api;
    }
}
