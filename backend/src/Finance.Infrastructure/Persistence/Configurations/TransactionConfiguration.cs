using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.Transactions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Finance.Infrastructure.Persistence.Configurations;

internal sealed class TransactionConfiguration : IEntityTypeConfiguration<Transaction>
{
    // Both partial indexes match the predicate EF generates for balance queries
    // (status literal + soft-delete filter), so balances are computed with index-only scans.
    private const string ClearedAndAlive = "status = 'Cleared' AND deleted_at IS NULL";

    public void Configure(EntityTypeBuilder<Transaction> builder)
    {
        builder.Property(t => t.Type).HasConversion<string>().HasMaxLength(10);
        builder.Property(t => t.Status).HasConversion<string>().HasMaxLength(10);
        builder.Property(t => t.Note).HasMaxLength(TransactionRules.MaxNoteLength);
        builder.Property(t => t.Tags).HasColumnType("text[]");

        builder.HasOne<Account>().WithMany().HasForeignKey(t => t.AccountId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Account>().WithMany().HasForeignKey(t => t.ToAccountId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Category>().WithMany().HasForeignKey(t => t.CategoryId).OnDelete(DeleteBehavior.Restrict);

        // Listing / pagination: newest first.
        builder.HasIndex(t => new { t.UserId, t.Date, t.Id })
            .IsDescending(false, true, true)
            .HasDatabaseName("ix_transactions_user_id_date_id");

        // Balance: InitialBalance + Σ cleared effects on the source account.
        builder.HasIndex(t => new { t.AccountId, t.Date })
            .IncludeProperties(t => new { t.UserId, t.Type, t.Amount })
            .HasFilter(ClearedAndAlive)
            .HasDatabaseName("ix_transactions_balance_source");

        // Balance: incoming side of transfers.
        builder.HasIndex(t => new { t.ToAccountId, t.Date })
            .IncludeProperties(t => new { t.UserId, t.ToAmount })
            .HasFilter(ClearedAndAlive + " AND to_account_id IS NOT NULL")
            .HasDatabaseName("ix_transactions_balance_destination");

        builder.HasIndex(t => t.CategoryId);

        builder.HasIndex(t => t.Note)
            .HasMethod("gin")
            .HasOperators("gin_trgm_ops")
            .HasDatabaseName("ix_transactions_note_trgm");

        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_transactions_amount_positive", "amount > 0");
            t.HasCheckConstraint("ck_transactions_to_amount_positive", "to_amount IS NULL OR to_amount > 0");
            t.HasCheckConstraint(
                "ck_transactions_shape",
                "(type = 'Transfer' AND to_account_id IS NOT NULL AND to_amount IS NOT NULL AND category_id IS NULL) OR " +
                "(type <> 'Transfer' AND to_account_id IS NULL AND to_amount IS NULL AND category_id IS NOT NULL)");
        });
    }
}
