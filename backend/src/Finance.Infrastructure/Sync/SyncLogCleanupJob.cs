using Finance.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Finance.Infrastructure.Sync;

/// <summary>Hangfire entry point: forgets processed push changes older than <see cref="RetentionDays"/>.</summary>
public sealed class SyncLogCleanupJob(AppDbContext db, TimeProvider clock, ILogger<SyncLogCleanupJob> logger)
{
    /// <summary>A client retrying a push after this long is treated as a new change.</summary>
    public const int RetentionDays = 90;

    public async Task RunAsync(CancellationToken ct)
    {
        var cutoff = clock.GetUtcNow().UtcDateTime.AddDays(-RetentionDays);
        var removed = await db.SyncChangeLogs.Where(l => l.ProcessedAt < cutoff).ExecuteDeleteAsync(ct);
        if (removed > 0)
        {
            logger.LogInformation("Removed {Count} sync log entries older than {Days} days", removed, RetentionDays);
        }
    }
}
