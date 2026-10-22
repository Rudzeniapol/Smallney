using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Finance.Application.Features.Auth;
using Finance.Application.Features.Categories;
using Finance.Application.Features.Me;
using Finance.Domain.Categories;
using Finance.Tests.Integration.Infrastructure;

namespace Finance.Tests.Integration.Features;

public class AuthTests(ApiFactory factory)
{
    private readonly HttpClient _anonymous = factory.CreateClient();

    [Fact]
    public async Task Register_creates_user_with_settings_and_default_categories()
    {
        var user = await factory.RegisterUserAsync(new RegisterRequest
        {
            BaseCurrency = "usd",
            Timezone = "Europe/Warsaw",
            FirstDayOfMonth = 10,
        });

        user.Auth.AccessToken.Should().NotBeNullOrEmpty();
        user.Auth.RefreshToken.Should().NotBeNullOrEmpty();
        user.Auth.AccessTokenExpiresAt.Should().BeCloseTo(DateTime.UtcNow.AddMinutes(15), TimeSpan.FromMinutes(1));

        var me = await user.GetAsync<MeResponse>("/api/v1/me");
        me.Email.Should().Be(user.Email);
        me.BaseCurrency.Should().Be("USD");
        me.Timezone.Should().Be("Europe/Warsaw");
        me.FirstDayOfMonth.Should().Be(10);

        var categories = await user.GetAsync<List<CategoryResponse>>("/api/v1/categories");
        categories.Should().Contain(c => c.Name == "Продукты" && c.Kind == CategoryKind.Expense);
        categories.Should().Contain(c => c.Name == "Такси" && c.ParentId != null);
        categories.Where(c => c.SystemCode == Category.UncategorizedCode).Should().HaveCount(2);
    }

    [Fact]
    public async Task Register_defaults_to_byn_and_minsk()
    {
        var user = await factory.RegisterUserAsync();
        var me = await user.GetAsync<MeResponse>("/api/v1/me");

        me.BaseCurrency.Should().Be("BYN");
        me.Timezone.Should().Be("Europe/Minsk");
        me.FirstDayOfMonth.Should().Be(1);
    }

    [Fact]
    public async Task Register_with_taken_email_is_a_conflict_regardless_of_case()
    {
        var user = await factory.RegisterUserAsync();

        var response = await _anonymous.PostAsJsonAsync("/api/v1/auth/register",
            new RegisterRequest { Email = user.Email.ToUpperInvariant(), Password = "password123" }, Json.Options);

        await response.ShouldBeProblemAsync(HttpStatusCode.Conflict, "email_taken");
    }

    [Fact]
    public async Task Register_validates_input()
    {
        var response = await _anonymous.PostAsJsonAsync("/api/v1/auth/register",
            new RegisterRequest { Email = "nope", Password = "123", FirstDayOfMonth = 29 }, Json.Options);

        var problem = await response.ShouldBeProblemAsync(HttpStatusCode.BadRequest, "validation_failed");
        problem.Extensions["errors"]!.ToString().Should().Contain("email").And.Contain("password").And.Contain("firstDayOfMonth");
    }

    [Fact]
    public async Task Login_with_correct_and_wrong_password()
    {
        var user = await factory.RegisterUserAsync();

        var ok = await _anonymous.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest(user.Email, user.Password), Json.Options);
        await ok.EnsureStatusAsync(HttpStatusCode.OK);
        (await ok.Content.ReadFromJsonAsync<AuthResponse>(Json.Options))!.UserId.Should().Be(user.Id);

        var wrong = await _anonymous.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest(user.Email, "bad-password"), Json.Options);
        await wrong.ShouldBeProblemAsync(HttpStatusCode.Unauthorized, "invalid_credentials");

        var unknown = await _anonymous.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest("ghost@test.by", "password123"), Json.Options);
        await unknown.ShouldBeProblemAsync(HttpStatusCode.Unauthorized, "invalid_credentials");
    }

    [Fact]
    public async Task Refresh_rotates_the_token()
    {
        var user = await factory.RegisterUserAsync();

        var refreshed = await RefreshAsync(user.Auth.RefreshToken);
        await refreshed.EnsureStatusAsync(HttpStatusCode.OK);
        var auth = (await refreshed.Content.ReadFromJsonAsync<AuthResponse>(Json.Options))!;

        auth.RefreshToken.Should().NotBe(user.Auth.RefreshToken);
        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", auth.AccessToken);
        (await client.GetAsync("/api/v1/me")).StatusCode.Should().Be(HttpStatusCode.OK);

        // The new token keeps working.
        await (await RefreshAsync(auth.RefreshToken)).EnsureStatusAsync(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Reusing_a_rotated_refresh_token_revokes_the_whole_session()
    {
        var user = await factory.RegisterUserAsync();
        var first = await RefreshAsync(user.Auth.RefreshToken);
        var current = (await first.Content.ReadFromJsonAsync<AuthResponse>(Json.Options))!.RefreshToken;

        var replay = await RefreshAsync(user.Auth.RefreshToken);
        await replay.ShouldBeProblemAsync(HttpStatusCode.Unauthorized, "invalid_refresh_token");

        // The legitimate successor was revoked together with the family.
        var successor = await RefreshAsync(current);
        await successor.ShouldBeProblemAsync(HttpStatusCode.Unauthorized, "invalid_refresh_token");
    }

    [Fact]
    public async Task Logout_revokes_the_refresh_token()
    {
        var user = await factory.RegisterUserAsync();

        var logout = await _anonymous.PostAsJsonAsync("/api/v1/auth/logout", new RefreshRequest(user.Auth.RefreshToken), Json.Options);
        logout.StatusCode.Should().Be(HttpStatusCode.NoContent);

        await (await RefreshAsync(user.Auth.RefreshToken)).ShouldBeProblemAsync(HttpStatusCode.Unauthorized, "invalid_refresh_token");

        // Unknown tokens are accepted silently.
        (await _anonymous.PostAsJsonAsync("/api/v1/auth/logout", new RefreshRequest("unknown"), Json.Options))
            .StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task Other_logins_survive_a_logout()
    {
        var user = await factory.RegisterUserAsync();
        var login = await _anonymous.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest(user.Email, user.Password), Json.Options);
        var second = (await login.Content.ReadFromJsonAsync<AuthResponse>(Json.Options))!;

        await _anonymous.PostAsJsonAsync("/api/v1/auth/logout", new RefreshRequest(user.Auth.RefreshToken), Json.Options);

        await (await RefreshAsync(second.RefreshToken)).EnsureStatusAsync(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Protected_endpoints_require_a_valid_token()
    {
        var response = await _anonymous.GetAsync("/api/v1/accounts");
        await response.ShouldBeProblemAsync(HttpStatusCode.Unauthorized, "unauthorized");

        var forged = factory.CreateClient();
        forged.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiJ9.e30.x");
        (await forged.GetAsync("/api/v1/me")).StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Health_endpoint_is_public()
    {
        var response = await _anonymous.GetAsync("/health");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        (await response.Content.ReadAsStringAsync()).Should().Be("Healthy");
    }

    private Task<HttpResponseMessage> RefreshAsync(string token) =>
        _anonymous.PostAsJsonAsync("/api/v1/auth/refresh", new RefreshRequest(token), Json.Options);
}
