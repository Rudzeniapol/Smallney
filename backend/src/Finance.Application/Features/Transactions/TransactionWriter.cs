using Finance.Application.Abstractions;
using Finance.Application.Common;
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
    TransactionTemplateResolver resolver,
    IValidator<TransactionPayload> validator,
    IValidator<ConfirmTransactionRequest> confirmValidator)
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
        var transaction = await FindAsync(id, ct);
        await ApplyAsync(transaction, payload, ct);
        return transaction;
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var transaction = await FindAsync(id, ct);
        transaction.MarkDeleted(clock.GetUtcNow().UtcDateTime);
    }

    /// <summary>Planned or Skipped → Cleared, optionally with a corrected amount or date.</summary>
    public async Task<Transaction> ConfirmAsync(Guid id, ConfirmTransactionRequest request, CancellationToken ct)
    {
        await confirmValidator.ValidateAndThrowAsync(request, ct);
        var transaction = await FindAsync(id, ct);
        if (transaction.Status == TransactionStatus.Cleared)
        {
            throw new ConflictException("transaction_not_planned", "The transaction is already cleared.");
        }

        var amount = request.Amount ?? transaction.Amount;
        if (transaction.Type == TransactionType.Transfer)
        {
            var from = await db.Accounts.AsNoTracking().FirstAsync(a => a.Id == transaction.AccountId, ct);
            var to = await db.Accounts.AsNoTracking().FirstAsync(a => a.Id == transaction.ToAccountId, ct);
            var toAmount = request.ToAmount ?? (amount == transaction.Amount ? transaction.ToAmount : null);
            transaction.ToAmount = TransactionRules.ResolveTransferToAmount(from, to, amount, toAmount);
        }

        transaction.Amount = amount;
        transaction.Date = request.Date ?? transaction.Date;
        transaction.Status = TransactionStatus.Cleared;
        return transaction;
    }

    /// <summary>Planned → Skipped. Undo by updating the status back to Planned.</summary>
    public async Task<Transaction> SkipAsync(Guid id, CancellationToken ct)
    {
        var transaction = await FindAsync(id, ct);
        if (transaction.Status != TransactionStatus.Planned)
        {
            throw new ConflictException("transaction_not_planned", "Only planned transactions can be skipped.");
        }

        transaction.Status = TransactionStatus.Skipped;
        return transaction;
    }

    private async Task<Transaction> FindAsync(Guid id, CancellationToken ct) =>
        await db.Transactions.FirstOrDefaultAsync(t => t.Id == id, ct)
        ?? throw new NotFoundException("Transaction", id);

    private async Task ApplyAsync(Transaction transaction, TransactionPayload p, CancellationToken ct)
    {
        var resolved = await resolver.ResolveAsync(p, ct);

        if (p.RecurringRuleId is { } ruleId
            && !await db.RecurringRules.IgnoreQueryFilters([QueryFilters.SoftDelete]).AnyAsync(r => r.Id == ruleId, ct))
        {
            throw new DomainException("recurring_rule_not_found", $"Recurring rule '{ruleId}' was not found.");
        }

        transaction.AccountId = resolved.Account.Id;
        transaction.Type = resolved.Type;
        transaction.Amount = p.Amount;
        transaction.CategoryId = resolved.CategoryId;
        transaction.Date = p.Date!.Value;
        transaction.Note = string.IsNullOrWhiteSpace(p.Note) ? null : p.Note.Trim();
        transaction.Tags = TransactionRules.NormalizeTags(p.Tags);
        transaction.Status = p.Status ?? TransactionStatus.Cleared;
        transaction.ToAccountId = resolved.ToAccountId;
        transaction.ToAmount = resolved.ToAmount;
        transaction.SavingsGoalId = resolved.SavingsGoalId;
        transaction.RecurringRuleId = p.RecurringRuleId;
        transaction.RecurrenceDate = p.RecurrenceDate;
    }
}
