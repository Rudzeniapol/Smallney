using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Transactions;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Transactions;

public sealed class TransactionQueries(IAppDbContext db, IValidator<TransactionFilter> validator)
{
    public const int DefaultLimit = 50;

    /// <summary>Newest first, keyset-paginated by (date, id).</summary>
    public async Task<CursorPage<TransactionResponse>> ListAsync(TransactionFilter filter, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(filter, ct);
        var limit = filter.Limit ?? DefaultLimit;
        var query = db.Transactions.AsNoTracking();

        if (filter.From is { } from)
        {
            query = query.Where(t => t.Date >= from);
        }

        if (filter.To is { } to)
        {
            query = query.Where(t => t.Date <= to);
        }

        if (filter.AccountId is { } accountId)
        {
            query = query.Where(t => t.AccountId == accountId || t.ToAccountId == accountId);
        }

        if (filter.CategoryId is { } categoryId)
        {
            var categoryIds = await db.Categories
                .Where(c => c.Id == categoryId || c.ParentId == categoryId)
                .Select(c => c.Id)
                .ToListAsync(ct);
            query = query.Where(t => t.CategoryId != null && categoryIds.Contains(t.CategoryId.Value));
        }

        if (filter.Type is { } type)
        {
            query = query.Where(t => t.Type == type);
        }

        if (filter.Status is { } status)
        {
            query = query.Where(t => t.Status == status);
        }
        else
        {
            query = query.Where(t => t.Status != TransactionStatus.Skipped);
        }

        if (!string.IsNullOrWhiteSpace(filter.Tag))
        {
            // Tags are deduplicated case-insensitively, so the filter is case-insensitive too.
            var tag = EscapeLike(filter.Tag.Trim());
            query = query.Where(t => t.Tags.Any(x => EF.Functions.ILike(x, tag)));
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var pattern = $"%{EscapeLike(filter.Search.Trim())}%";
            query = query.Where(t => t.Note != null && EF.Functions.ILike(t.Note, pattern));
        }

        if (filter.Cursor is not null)
        {
            var cursor = DateIdCursor.Decode(filter.Cursor);
            query = query.Where(t => EF.Functions.LessThan(
                ValueTuple.Create(t.Date, t.Id),
                ValueTuple.Create(cursor.Date, cursor.Id)));
        }

        var rows = await query
            .OrderByDescending(t => t.Date)
            .ThenByDescending(t => t.Id)
            .Take(limit + 1)
            .ToListAsync(ct);

        var items = rows.Take(limit).Select(TransactionResponse.From).ToList();
        var next = rows.Count > limit ? new DateIdCursor(items[^1].Date, items[^1].Id).Encode() : null;
        return new CursorPage<TransactionResponse>(items, next);
    }

    public async Task<TransactionResponse> GetAsync(Guid id, CancellationToken ct)
    {
        var transaction = await db.Transactions.AsNoTracking().FirstOrDefaultAsync(t => t.Id == id, ct)
                          ?? throw new NotFoundException("Transaction", id);
        return TransactionResponse.From(transaction);
    }

    private static string EscapeLike(string value) =>
        value.Replace(@"\", @"\\").Replace("%", @"\%").Replace("_", @"\_");
}
