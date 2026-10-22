using Finance.Application.Features.Recurring;
using Microsoft.Extensions.Logging;

namespace Finance.Infrastructure.Recurring;

/// <summary>Hangfire entry point: materializes due rule occurrences of every user as Planned transactions.</summary>
public sealed class RecurringTransactionsJob(RecurringMaterializer materializer, ILogger<RecurringTransactionsJob> logger)
{
    public async Task RunAsync(CancellationToken ct)
    {
        var created = await materializer.MaterializeAllAsync(ct);
        if (created > 0)
        {
            logger.LogInformation("Materialized {Count} planned transactions from recurring rules", created);
        }
    }
}
