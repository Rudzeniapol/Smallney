using Finance.Api.Endpoints;
using Finance.Api.Infrastructure;
using Finance.Application;
using Finance.Infrastructure;
using Finance.Infrastructure.Jobs;
using Scalar.AspNetCore;
using Serilog;
using Serilog.Formatting.Compact;

Log.Logger = new LoggerConfiguration().WriteTo.Console().CreateLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Services.AddSerilog((services, logger) =>
    {
        logger
            .ReadFrom.Configuration(builder.Configuration)
            .ReadFrom.Services(services)
            .Enrich.FromLogContext();

        // Human-readable locally, structured JSON everywhere else.
        if (builder.Environment.IsDevelopment())
        {
            logger.WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {SourceContext}: {Message:lj}{NewLine}{Exception}");
        }
        else
        {
            logger.WriteTo.Console(new RenderedCompactJsonFormatter());
        }
    });

    builder.Services
        .AddApplication()
        .AddInfrastructure(builder.Configuration)
        .AddApi();

    var app = builder.Build();

    app.UseExceptionHandler();
    app.UseStatusCodePages();
    app.UseSerilogRequestLogging();
    app.UseRateLimiter();
    app.UseAuthentication();
    app.UseAuthorization();

    if (app.Environment.IsDevelopment())
    {
        app.MapOpenApi();
        app.MapScalarApiReference(o => o.WithTitle("Smallney Finance API"));
        app.MapJobsDashboard();
    }

    app.MapHealthChecks("/health").AllowAnonymous();

    var api = app.MapGroup("/api/v1");
    api.MapAuth();

    var secured = api.MapGroup(string.Empty).RequireAuthorization();
    secured
        .MapMe()
        .MapAccounts()
        .MapCategories()
        .MapTransactions()
        .MapRecurringRules()
        .MapBudgets()
        .MapSavingsGoals()
        .MapRates();

    if (app.Configuration.GetValue("Database:MigrateOnStartup", true))
    {
        await app.Services.MigrateDatabaseAsync();
    }

    await app.RunAsync();
}
catch (Exception ex) when (ex is not HostAbortedException)
{
    Log.Fatal(ex, "Application terminated unexpectedly");
    throw;
}
finally
{
    await Log.CloseAndFlushAsync();
}

public partial class Program;
