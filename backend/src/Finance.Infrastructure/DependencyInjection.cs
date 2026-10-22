using Finance.Application.Abstractions;
using Finance.Infrastructure.Auth;
using Finance.Infrastructure.ExchangeRates;
using Finance.Infrastructure.Jobs;
using Finance.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;
using Npgsql;

namespace Finance.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>((sp, options) =>
            ConfigureDbContext(options, GetConnectionString(sp.GetRequiredService<IConfiguration>())));
        services.AddScoped<IAppDbContext>(sp => sp.GetRequiredService<AppDbContext>());

        services.AddJwtAuthentication();
        services.AddSingleton<ITokenService, TokenService>();
        services.AddSingleton<IPasswordService, PasswordService>();

        services.AddMemoryCache();
        services.AddOptions<ExchangeRatesOptions>().BindConfiguration(ExchangeRatesOptions.SectionName);
        services.AddSingleton<IExchangeRateProvider, ExchangeRateProvider>();
        services.AddScoped<ICurrencyConverter, CurrencyConverter>();
        services.AddScoped<ExchangeRatesJob>();
        services.AddScoped<Recurring.RecurringTransactionsJob>();
        services.AddScoped<Sync.SyncLogCleanupJob>();
        services.AddHttpClient<INbrbClient, NbrbClient>((sp, http) =>
        {
            http.BaseAddress = new Uri(sp.GetRequiredService<IOptions<ExchangeRatesOptions>>().Value.NbrbBaseUrl);
            http.Timeout = TimeSpan.FromSeconds(30);
        });

        services.AddHealthChecks().AddDbContextCheck<AppDbContext>("postgres");

        if (configuration.GetValue("Hangfire:Enabled", true))
        {
            services.AddJobs();
        }

        return services;
    }

    public static string GetConnectionString(IConfiguration configuration)
    {
        var raw = configuration.GetConnectionString("Postgres")
                  ?? throw new InvalidOperationException("Connection string 'ConnectionStrings:Postgres' is not configured.");
        var builder = new NpgsqlConnectionStringBuilder(raw);
        if (!raw.Contains("Gss", StringComparison.OrdinalIgnoreCase))
        {
            // Npgsql probes Kerberos (libgssapi) for GSS encryption by default; the container has no Kerberos.
            builder.GssEncryptionMode = GssEncryptionMode.Disable;
        }

        return builder.ConnectionString;
    }

    public static async Task MigrateDatabaseAsync(this IServiceProvider services, CancellationToken ct = default)
    {
        await using var scope = services.CreateAsyncScope();
        await scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.MigrateAsync(ct);
    }

    internal static void ConfigureDbContext(DbContextOptionsBuilder options, string connectionString) =>
        options
            .UseNpgsql(connectionString, npgsql => npgsql.MigrationsHistoryTable("__ef_migrations_history"))
            .UseSnakeCaseNamingConvention();

    private static void AddJwtAuthentication(this IServiceCollection services)
    {
        services.AddOptions<JwtOptions>()
            .BindConfiguration(JwtOptions.SectionName)
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
        services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
            .Configure<IOptions<JwtOptions>>((bearer, jwt) =>
            {
                bearer.MapInboundClaims = false;
                bearer.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidIssuer = jwt.Value.Issuer,
                    ValidAudience = jwt.Value.Audience,
                    IssuerSigningKey = TokenService.CreateSigningKey(jwt.Value),
                    ValidAlgorithms = [SecurityAlgorithms.HmacSha256],
                    ClockSkew = TimeSpan.FromSeconds(30),
                    NameClaimType = JwtRegisteredClaimNames.Sub,
                };
            });
        services.AddAuthorization();
    }
}
