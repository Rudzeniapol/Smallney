using Finance.Application.Abstractions;
using Finance.Domain.Accounts;
using Finance.Domain.Common;
using Finance.Domain.Transactions;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Common;

/// <summary>The transaction fields shared by transactions and recurring rule templates.</summary>
public interface ITransactionTemplate
{
    Guid? AccountId { get; }

    TransactionType? Type { get; }

    long Amount { get; }

    Guid? CategoryId { get; }

    string? Note { get; }

    IReadOnlyList<string>? Tags { get; }

    Guid? ToAccountId { get; }

    long? ToAmount { get; }

    Guid? SavingsGoalId { get; }
}

/// <summary>Shape rules for <see cref="ITransactionTemplate"/>; included by the concrete validators.</summary>
internal sealed class TransactionTemplateValidator<T> : AbstractValidator<T>
    where T : ITransactionTemplate
{
    public TransactionTemplateValidator()
    {
        RuleFor(x => x.AccountId).NotNull();
        RuleFor(x => x.Type).NotNull().IsInEnum();
        RuleFor(x => x.Amount).GreaterThan(0);
        RuleFor(x => x.Note).MaximumLength(TransactionRules.MaxNoteLength);
        RuleFor(x => x.Tags).Must(t => t is null || t.Count <= TransactionRules.MaxTags)
            .WithMessage($"At most {TransactionRules.MaxTags} tags are allowed.");
        RuleForEach(x => x.Tags).NotEmpty().MaximumLength(TransactionRules.MaxTagLength);

        When(x => x.Type == TransactionType.Transfer, () =>
        {
            RuleFor(x => x.CategoryId).Null().WithErrorCode("category_not_allowed")
                .WithMessage("Transfers do not have a category.");
            RuleFor(x => x.ToAccountId).NotNull()
                .NotEqual(x => x.AccountId).WithErrorCode("transfer_same_account")
                .WithMessage("A transfer needs two different accounts.");
            RuleFor(x => x.ToAmount).GreaterThan(0).When(x => x.ToAmount is not null);
        }).Otherwise(() =>
        {
            RuleFor(x => x.CategoryId).NotNull().WithErrorCode("category_required")
                .WithMessage("Income and expense transactions need a category.");
            RuleFor(x => x.ToAccountId).Null().WithErrorCode("transfer_fields_not_allowed")
                .WithMessage("Only transfers have a destination account.");
            RuleFor(x => x.ToAmount).Null().WithErrorCode("transfer_fields_not_allowed")
                .WithMessage("Only transfers have a destination amount.");
            RuleFor(x => x.SavingsGoalId).Null().WithErrorCode("savings_goal_only_for_transfers")
                .WithMessage("Only transfers can contribute to a savings goal.");
        });
    }
}

public sealed record ResolvedTemplate(
    Account Account,
    TransactionType Type,
    Guid? CategoryId,
    Guid? ToAccountId,
    long? ToAmount,
    Guid? SavingsGoalId);

/// <summary>Checks the references of a template against the current user's data.</summary>
public sealed class TransactionTemplateResolver(IAppDbContext db)
{
    public async Task<ResolvedTemplate> ResolveAsync(ITransactionTemplate p, CancellationToken ct)
    {
        var type = p.Type!.Value;
        var account = await FindAccountAsync(p.AccountId!.Value, ct);

        if (type == TransactionType.Transfer)
        {
            var toAccount = await FindAccountAsync(p.ToAccountId!.Value, ct);
            var toAmount = TransactionRules.ResolveTransferToAmount(account, toAccount, p.Amount, p.ToAmount);
            if (p.SavingsGoalId is { } goalId && !await db.SavingsGoals.AnyAsync(g => g.Id == goalId, ct))
            {
                throw new DomainException("savings_goal_not_found", $"Savings goal '{goalId}' was not found.");
            }

            return new ResolvedTemplate(account, type, null, toAccount.Id, toAmount, p.SavingsGoalId);
        }

        var category = await db.Categories.AsNoTracking().FirstOrDefaultAsync(c => c.Id == p.CategoryId, ct)
                       ?? throw new DomainException("category_not_found", $"Category '{p.CategoryId}' was not found.");
        TransactionRules.EnsureCategoryMatches(type, category);
        return new ResolvedTemplate(account, type, category.Id, null, null, null);
    }

    private async Task<Account> FindAccountAsync(Guid id, CancellationToken ct) =>
        await db.Accounts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id, ct)
        ?? throw new DomainException("account_not_found", $"Account '{id}' was not found.");
}
