using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Accounts;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Accounts;

/// <summary>Account write rules shared by REST and sync. Does not call SaveChanges.</summary>
public sealed class AccountWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    IValidator<AccountPayload> validator)
{
    public async Task<Account> CreateAsync(Guid id, AccountPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        await db.Accounts.EnsureIdIsFreeAsync(id, ct);

        var account = new Account { Id = id, UserId = currentUser.RequiredUserId() };
        Apply(account, payload);
        db.Accounts.Add(account);
        return account;
    }

    public async Task<Account> UpdateAsync(Guid id, AccountPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        var account = await db.Accounts.FirstOrDefaultAsync(a => a.Id == id, ct)
                      ?? throw new NotFoundException("Account", id);

        var newCurrency = NormalizeCurrency(payload.Currency);
        if (newCurrency != account.Currency && await HasTransactionsAsync(id, ct))
        {
            throw new ConflictException(
                "account_currency_locked",
                "The currency of an account with transactions cannot be changed.");
        }

        Apply(account, payload);
        return account;
    }

    /// <summary>Soft-deletes an account that has no transactions; otherwise suggests archiving.</summary>
    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var account = await db.Accounts.FirstOrDefaultAsync(a => a.Id == id, ct)
                      ?? throw new NotFoundException("Account", id);

        if (await HasTransactionsAsync(id, ct))
        {
            throw new ConflictException(
                "account_has_transactions",
                "The account has transactions. Delete them first or archive the account.");
        }

        account.MarkDeleted(clock.GetUtcNow().UtcDateTime);

        var userId = currentUser.RequiredUserId();
        var user = await db.Users.FirstAsync(u => u.Id == userId, ct);
        if (user.DefaultSpendingAccountId == id)
        {
            user.DefaultSpendingAccountId = null;
        }
    }

    private Task<bool> HasTransactionsAsync(Guid accountId, CancellationToken ct) =>
        db.Transactions.AnyAsync(t => t.AccountId == accountId || t.ToAccountId == accountId, ct);

    private static string NormalizeCurrency(string? currency) => currency!.Trim().ToUpperInvariant();

    private static void Apply(Account account, AccountPayload p)
    {
        account.Name = p.Name!.Trim();
        account.Type = p.Type!.Value;
        account.Currency = NormalizeCurrency(p.Currency);
        account.InitialBalance = p.InitialBalance;
        account.IncludeInTotals = p.IncludeInTotals;
        account.IsArchived = p.IsArchived;
        account.SortOrder = p.SortOrder;
        account.Color = p.Color;
        account.Icon = p.Icon;
        account.CreditLimit = p.CreditLimit;
        account.InterestRatePercent = p.InterestRatePercent;
        account.CapitalizationPeriod = p.CapitalizationPeriod;
        account.OpenDate = p.OpenDate;
        account.MaturityDate = p.MaturityDate;
    }
}
