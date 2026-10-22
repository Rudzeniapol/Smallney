using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Domain.Accounts;
using Finance.Domain.Common;
using Finance.Domain.Transactions;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Transactions;

/// <summary>Transaction write rules shared by REST and sync. Does not call SaveChanges.</summary>
public sealed class TransactionWriter(
    IAppDbContext db,
    ICurrentUser currentUser,
    TimeProvider clock,
    IValidator<TransactionPayload> validator)
{
    public async Task<Transaction> CreateAsync(Guid id, TransactionPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        await db.Transactions.EnsureIdIsFreeAsync(id, ct);

        var transaction = new Transaction { Id = id, UserId = currentUser.RequiredUserId() };
        await ApplyAsync(transaction, payload, ct);
        db.Transactions.Add(transaction);
        return transaction;
    }

    public async Task<Transaction> UpdateAsync(Guid id, TransactionPayload payload, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(payload, ct);
        var transaction = await db.Transactions.FirstOrDefaultAsync(t => t.Id == id, ct)
                          ?? throw new NotFoundException("Transaction", id);
        await ApplyAsync(transaction, payload, ct);
        return transaction;
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var transaction = await db.Transactions.FirstOrDefaultAsync(t => t.Id == id, ct)
                          ?? throw new NotFoundException("Transaction", id);
        transaction.MarkDeleted(clock.GetUtcNow().UtcDateTime);
    }

    private async Task ApplyAsync(Transaction transaction, TransactionPayload p, CancellationToken ct)
    {
        var type = p.Type!.Value;
        var account = await FindAccountAsync(p.AccountId!.Value, ct);

        Guid? categoryId = null;
        Guid? toAccountId = null;
        long? toAmount = null;

        if (type == TransactionType.Transfer)
        {
            var toAccount = await FindAccountAsync(p.ToAccountId!.Value, ct);
            toAmount = TransactionRules.ResolveTransferToAmount(account, toAccount, p.Amount, p.ToAmount);
            toAccountId = toAccount.Id;
        }
        else
        {
            var category = await db.Categories.AsNoTracking().FirstOrDefaultAsync(c => c.Id == p.CategoryId, ct)
                           ?? throw new DomainException("category_not_found", $"Category '{p.CategoryId}' was not found.");
            TransactionRules.EnsureCategoryMatches(type, category);
            categoryId = category.Id;
        }

        transaction.AccountId = account.Id;
        transaction.Type = type;
        transaction.Amount = p.Amount;
        transaction.CategoryId = categoryId;
        transaction.Date = p.Date!.Value;
        transaction.Note = string.IsNullOrWhiteSpace(p.Note) ? null : p.Note.Trim();
        transaction.Tags = TransactionRules.NormalizeTags(p.Tags);
        transaction.Status = p.Status ?? TransactionStatus.Cleared;
        transaction.ToAccountId = toAccountId;
        transaction.ToAmount = toAmount;
    }

    private async Task<Account> FindAccountAsync(Guid id, CancellationToken ct) =>
        await db.Accounts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id, ct)
        ?? throw new DomainException("account_not_found", $"Account '{id}' was not found.");
}
