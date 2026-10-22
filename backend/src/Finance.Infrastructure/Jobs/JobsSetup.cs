using Finance.Infrastructure.ExchangeRates;
using Finance.Infrastructure.Recurring;
using Finance.Infrastructure.Sync;
using Hangfire;
using Hangfire.Dashboard;
using Hangfire.PostgreSql;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Finance.Infrastructure.Jobs;

public static class JobsSetup
{
    public const string ExchangeRatesJobId = "exchange-rates";
    public const string RecurringTransactionsJobId = "recurring-transactions";

    public const string SyncLogCleanupJobId = "sync-log-cleanup";

    /// <summary>Hourly, because "today" differs between users' time zones.</summary>
    public const string RecurringTransactionsCron = "5 * * * *";

    internal static IServiceCollection AddJobs(this IServiceCollection services)
    {
        services.AddHangfire((sp, config) => config
            .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
            .UseSimpleAssemblyNameTypeSerializer()
            .UseRecommendedSerializerSettings()
            .UsePostgreSqlStorage(
                o => o.UseNpgsqlConnection(DependencyInjection.GetConnectionString(sp.GetRequiredService<IConfiguration>())),
                new PostgreSqlStorageOptions { SchemaName = "hangfire", PrepareSchemaIfNecessary = true }));
        services.AddHangfireServer(o => o.WorkerCount = 2);
        services.AddHostedService<JobsBootstrapper>();
        return services;
    }

    /// <summary>Hangfire dashboard without authentication. Only map it in Development.</summary>
    public static WebApplication MapJobsDashboard(this WebApplication app)
    {
        if (app.Services.GetService<JobStorage>() is not null)
        {
            app.UseHangfireDashboard("/hangfire", new DashboardOptions { Authorization = [new AllowAllFilter()] });
        }

        return app;
    }

    private sealed class AllowAllFilter : IDashboardAuthorizationFilter
    {
        public bool Authorize(DashboardContext context) => true;
    }
}

/// <summary>Registers recurring jobs and kicks off the initial rate import and materialization.</summary>
internal sealed class JobsBootstrapper(
    IRecurringJobManager recurringJobs,
    IBackgroundJobClient jobs,
    IServiceScopeFactory scopes,
    IOptions<ExchangeRatesOptions> options,
    ILogger<JobsBootstrapper> logger) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        recurringJobs.AddOrUpdate<ExchangeRatesJob>(
            JobsSetup.ExchangeRatesJobId,
            job => job.LoadLatestAsync(CancellationToken.None),
            options.Value.Cron);

        recurringJobs.AddOrUpdate<RecurringTransactionsJob>(
            JobsSetup.RecurringTransactionsJobId,
            job => job.RunAsync(CancellationToken.None),
            JobsSetup.RecurringTransactionsCron);
        jobs.Enqueue<RecurringTransactionsJob>(job => job.RunAsync(CancellationToken.None));
        recurringJobs.AddOrUpdate<SyncLogCleanupJob>(
            JobsSetup.SyncLogCleanupJobId,
            job => job.RunAsync(CancellationToken.None),
            "30 3 * * *");

        await using var scope = scopes.CreateAsyncScope();
        if (!await scope.ServiceProvider.GetRequiredService<ExchangeRatesJob>().HasRatesForTodayAsync(cancellationToken))
        {
            logger.LogInformation("No exchange rates for today yet, enqueueing an import");
            jobs.Enqueue<ExchangeRatesJob>(job => job.LoadLatestAsync(CancellationToken.None));
        }

        var backfillDays = options.Value.BackfillDays;
        if (backfillDays > 0)
        {
            jobs.Enqueue<ExchangeRatesJob>(job => job.BackfillAsync(backfillDays, CancellationToken.None));
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
