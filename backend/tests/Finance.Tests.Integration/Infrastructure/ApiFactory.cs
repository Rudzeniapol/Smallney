using Finance.Infrastructure.ExchangeRates;
using Finance.Tests.Integration.Infrastructure;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Testcontainers.PostgreSql;

[assembly: AssemblyFixture(typeof(ApiFactory))]

namespace Finance.Tests.Integration.Infrastructure;

/// <summary>
/// One API + one PostgreSQL 17 container for the whole test assembly.
/// Tests stay independent by registering a fresh user each.
/// </summary>
public sealed class ApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder("postgres:17").Build();

    public FakeNbrbClient Nbrb { get; } = new();

    public async ValueTask InitializeAsync()
    {
        await _postgres.StartAsync();

        // Environment variables are read by WebApplication.CreateBuilder before Program registers services.
        Environment.SetEnvironmentVariable("ConnectionStrings__Postgres", _postgres.GetConnectionString());
        Environment.SetEnvironmentVariable("Hangfire__Enabled", "false");
        Environment.SetEnvironmentVariable("Jwt__SigningKey", "integration-tests-signing-key-0123456789abcdef");
        Environment.SetEnvironmentVariable("RateLimiting__AuthPermitPerMinute", "100000");
        Environment.SetEnvironmentVariable("Serilog__MinimumLevel__Default", "Warning");

        _ = Server; // Builds the host and applies migrations.
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.ConfigureTestServices(services =>
        {
            services.RemoveAll<INbrbClient>();
            services.AddSingleton<INbrbClient>(Nbrb);
        });
    }

    public override async ValueTask DisposeAsync()
    {
        await base.DisposeAsync();
        await _postgres.DisposeAsync();
    }
}

public sealed class FakeNbrbClient : INbrbClient
{
    private readonly Dictionary<DateOnly, IReadOnlyList<NbrbRate>> _byDate = [];

    public IReadOnlyList<NbrbRate> Today { get; set; } = [];

    public List<DateOnly?> Requests { get; } = [];

    public void SetRatesFor(DateOnly date, params NbrbRate[] rates)
    {
        lock (_byDate)
        {
            _byDate[date] = rates;
        }
    }

    public Task<IReadOnlyList<NbrbRate>> GetDailyRatesAsync(DateOnly? onDate, CancellationToken ct)
    {
        lock (_byDate)
        {
            Requests.Add(onDate);
            if (onDate is null)
            {
                return Task.FromResult(Today);
            }

            return Task.FromResult(_byDate.TryGetValue(onDate.Value, out var rates) ? rates : (IReadOnlyList<NbrbRate>)[]);
        }
    }
}
