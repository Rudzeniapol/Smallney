using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.Common;

namespace Finance.Domain.Transactions;

public static class TransactionRules
{
    public const int MaxTags = 20;
    public const int MaxTagLength = 50;
    public const int MaxNoteLength = 500;

    public static void EnsureCategoryMatches(TransactionType type, Category category)
    {
        var expected = type switch
        {
            TransactionType.Income => CategoryKind.Income,
            TransactionType.Expense => CategoryKind.Expense,
            _ => throw new DomainException("category_not_allowed", "Transfers do not have a category."),
        };

        if (category.Kind != expected)
        {
            throw new DomainException(
                "category_kind_mismatch",
                $"{type} transactions need a category of kind {expected}.");
        }
    }

    /// <summary>
    /// Resolves the amount credited to the destination of a transfer.
    /// Same currency: must equal <paramref name="amount"/> (defaults to it). Different currencies: required.
    /// </summary>
    public static long ResolveTransferToAmount(Account from, Account to, long amount, long? toAmount)
    {
        if (from.Id == to.Id)
        {
            throw new DomainException("transfer_same_account", "A transfer needs two different accounts.");
        }

        if (from.Currency == to.Currency)
        {
            if (toAmount is not null && toAmount != amount)
            {
                throw new DomainException(
                    "transfer_amount_mismatch",
                    "For accounts in the same currency the credited amount must equal the debited amount.");
            }

            return amount;
        }

        return toAmount ?? throw new DomainException(
            "transfer_to_amount_required",
            "For accounts in different currencies the credited amount (toAmount) is required.");
    }

    /// <summary>Trims tags, drops empty ones and removes case-insensitive duplicates, keeping the first spelling.</summary>
    public static string[] NormalizeTags(IEnumerable<string>? tags) =>
        (tags ?? [])
        .Select(t => t.Trim())
        .Where(t => t.Length > 0)
        .DistinctBy(t => t.ToUpperInvariant())
        .ToArray();
}
