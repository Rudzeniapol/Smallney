using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Monetary;
using Finance.Domain.Users;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Accounts;

public sealed class AccountQueries(
    IAppDbContext db,
    ICurrentUser currentUser,
    BalanceQueries balances,
    IExchangeRateProvider rates,
    TimeProvider clock)
{
    public async Task<IReadOnlyList<AccountResponse>> ListAsync(bool includeArchived, CancellationToken ct)
    {
        var query = db.Accounts.AsNoTracking();
        if (!includeArchived)
        {
            query = query.Where(a => !a.IsArchived);
        }

        var accounts = await query.OrderBy(a => a.SortOrder).ThenBy(a => a.Name).ToListAsync(ct);
        var balanceById = await balances.GetBalancesAsync(accounts.Select(a => a.Id).ToList(), asOf: null, ct);
        return accounts.Select(a => AccountResponse.From(a, balanceById.GetValueOrDefault(a.Id, a.InitialBalance))).ToList();
    }

    public async Task<AccountResponse> GetAsync(Guid id, CancellationToken ct)
    {
        var account = await db.Accounts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id, ct)
                      ?? throw new NotFoundException("Account", id);
        return AccountResponse.From(account, await balances.GetBalanceAsync(id, asOf: null, ct));
    }

    public async Task<AccountsSummaryResponse> SummaryAsync(CancellationToken ct)
    {
        var userId = currentUser.RequiredUserId();
        var user = await db.Users.AsNoTracking().FirstAsync(u => u.Id == userId, ct);
        var baseCurrency = Currency.FromCode(user.BaseCurrency);
        var today = user.LocalToday(clock.GetUtcNow());

        var accounts = await db.Accounts.AsNoTracking().Where(a => a.IncludeInTotals).ToListAsync(ct);
        var balanceById = await balances.GetBalancesAsync(accounts.Select(a => a.Id).ToList(), asOf: null, ct);
        var table = await rates.GetTableAsync(ct);

        var total = Money.Zero(baseCurrency);
        var items = new List<AccountBalanceInBase>(accounts.Count);
        foreach (var account in accounts.OrderBy(a => a.SortOrder).ThenBy(a => a.Name))
        {
            var balance = new Money(balanceById.GetValueOrDefault(account.Id), Currency.FromCode(account.Currency));
            var inBase = table.Convert(balance, baseCurrency, today);
            total += inBase;
            items.Add(new AccountBalanceInBase(account.Id, MoneyDto.From(balance), MoneyDto.From(inBase)));
        }

        return new AccountsSummaryResponse(MoneyDto.From(total), today, items);
    }
}
