using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Finance.Application.Abstractions;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Auth;
using Finance.Application.Features.Categories;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Transactions;
using Finance.Domain.Users;
using Finance.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Finance.Tests.Integration.Infrastructure;

public static class Json
{
    public static readonly JsonSerializerOptions Options = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() },
    };
}

/// <summary>A registered user with an authenticated client.</summary>
public sealed class TestUser(HttpClient client, AuthResponse auth, string email, string password)
{
    public HttpClient Client { get; } = client;

    public AuthResponse Auth { get; } = auth;

    public Guid Id => Auth.UserId;

    public string Email { get; } = email;

    public string Password { get; } = password;

    public async Task<T> GetAsync<T>(string url)
    {
        var response = await Client.GetAsync(url);
        await response.EnsureStatusAsync(HttpStatusCode.OK);
        return (await response.Content.ReadFromJsonAsync<T>(Json.Options))!;
    }

    public Task<HttpResponseMessage> PostAsync(string url, object body) => Client.PostAsJsonAsync(url, body, Json.Options);

    public Task<HttpResponseMessage> PutAsync(string url, object body) => Client.PutAsJsonAsync(url, body, Json.Options);

    public async Task<T> PostAsync<T>(string url, object body, HttpStatusCode expected = HttpStatusCode.Created)
    {
        var response = await PostAsync(url, body);
        await response.EnsureStatusAsync(expected);
        return (await response.Content.ReadFromJsonAsync<T>(Json.Options))!;
    }

    public async Task<T> PutAsync<T>(string url, object body)
    {
        var response = await PutAsync(url, body);
        await response.EnsureStatusAsync(HttpStatusCode.OK);
        return (await response.Content.ReadFromJsonAsync<T>(Json.Options))!;
    }

    public Task<AccountResponse> CreateAccountAsync(
        string name = "Карта",
        string currency = "BYN",
        long initialBalance = 0,
        AccountType type = AccountType.DebitCard) =>
        PostAsync<AccountResponse>("/api/v1/accounts", new CreateAccountRequest
        {
            Id = UuidV7.New(),
            Name = name,
            Type = type,
            Currency = currency,
            InitialBalance = initialBalance,
        });

    public async Task<CategoryResponse> CategoryAsync(string name, CategoryKind kind = CategoryKind.Expense)
    {
        var categories = await GetAsync<List<CategoryResponse>>($"/api/v1/categories?kind={kind}");
        return categories.First(c => c.Name == name);
    }

    public Task<TransactionResponse> CreateTransactionAsync(TransactionPayload payload) =>
        PostAsync<TransactionResponse>("/api/v1/transactions", new CreateTransactionRequest
        {
            Id = UuidV7.New(),
            AccountId = payload.AccountId,
            Type = payload.Type,
            Amount = payload.Amount,
            CategoryId = payload.CategoryId,
            Date = payload.Date,
            Note = payload.Note,
            Tags = payload.Tags,
            Status = payload.Status,
            ToAccountId = payload.ToAccountId,
            ToAmount = payload.ToAmount,
            SavingsGoalId = payload.SavingsGoalId,
            RecurringRuleId = payload.RecurringRuleId,
            RecurrenceDate = payload.RecurrenceDate,
        });

    public async Task<TransactionResponse> ExpenseAsync(Guid accountId, long amount, DateOnly date, string category = "Продукты",
        string? note = null, string[]? tags = null, TransactionStatus? status = null)
    {
        var categoryId = (await CategoryAsync(category)).Id;
        return await CreateTransactionAsync(new TransactionPayload
        {
            AccountId = accountId,
            Type = TransactionType.Expense,
            Amount = amount,
            CategoryId = categoryId,
            Date = date,
            Note = note,
            Tags = tags,
            Status = status,
        });
    }

    public async Task<TransactionResponse> IncomeAsync(Guid accountId, long amount, DateOnly date)
    {
        var categoryId = (await CategoryAsync("Зарплата", CategoryKind.Income)).Id;
        return await CreateTransactionAsync(new TransactionPayload
        {
            AccountId = accountId,
            Type = TransactionType.Income,
            Amount = amount,
            CategoryId = categoryId,
            Date = date,
        });
    }
}

public static class TestApiExtensions
{
    /// <summary>
    /// Global rates used by tests that convert currencies. Every test seeds the same values, so parallel tests
    /// agree: USD = 3.0 BYN and EUR = 3.5 BYN, with no other USD/EUR rates in the database.
    /// </summary>
    public static async Task SeedStandardRatesAsync(this ApiFactory factory)
    {
        var date = new DateOnly(2026, 10, 20);
        await using var scope = factory.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.ExecuteSqlRawAsync(
            "INSERT INTO exchange_rates (from_currency, to_currency, date, rate, source, fetched_at) VALUES " +
            "('USD', 'BYN', {0}, 3.0, 'TEST', now()), ('EUR', 'BYN', {0}, 3.5, 'TEST', now()) ON CONFLICT DO NOTHING",
            date);
        scope.ServiceProvider.GetRequiredService<IExchangeRateProvider>().Invalidate();
    }

    /// <summary>Runs <paramref name="action"/> in a scope without an HTTP user, like a background job.</summary>
    public static async Task<T> InJobScopeAsync<T>(this ApiFactory factory, Func<IServiceProvider, Task<T>> action)
    {
        await using var scope = factory.Services.CreateAsyncScope();
        return await action(scope.ServiceProvider);
    }

    /// <summary>The user's current local date, as the server computes it.</summary>
    public static DateOnly TodayFor(string timezone = User.DefaultTimezone) => UserClock.LocalDate(timezone, DateTimeOffset.UtcNow);

    public static async Task<TestUser> RegisterUserAsync(this ApiFactory factory, RegisterRequest? request = null)
    {
        var email = request?.Email ?? $"user-{Guid.NewGuid():N}@test.by";
        var password = request?.Password ?? "password123";
        var anonymous = factory.CreateClient();
        var response = await anonymous.PostAsJsonAsync(
            "/api/v1/auth/register",
            (request ?? new RegisterRequest()) with { Email = email, Password = password },
            Json.Options);
        await response.EnsureStatusAsync(HttpStatusCode.Created);
        var auth = (await response.Content.ReadFromJsonAsync<AuthResponse>(Json.Options))!;

        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", auth.AccessToken);
        return new TestUser(client, auth, email, password);
    }

    public static async Task EnsureStatusAsync(this HttpResponseMessage response, HttpStatusCode expected)
    {
        if (response.StatusCode != expected)
        {
            var body = await response.Content.ReadAsStringAsync();
            throw new Xunit.Sdk.XunitException(
                $"Expected {(int)expected} {expected} but got {(int)response.StatusCode} {response.StatusCode}: {body}");
        }
    }

    /// <summary>Asserts an RFC 9457 problem with the given status and <c>code</c> extension.</summary>
    public static async Task<ProblemDetails> ShouldBeProblemAsync(this HttpResponseMessage response, HttpStatusCode status, string code)
    {
        await response.EnsureStatusAsync(status);
        response.Content.Headers.ContentType?.MediaType.Should().Be("application/problem+json");
        var problem = (await response.Content.ReadFromJsonAsync<ProblemDetails>(Json.Options))!;
        problem.Status.Should().Be((int)status);
        problem.Extensions["code"]!.ToString().Should().Be(code);
        return problem;
    }
}
