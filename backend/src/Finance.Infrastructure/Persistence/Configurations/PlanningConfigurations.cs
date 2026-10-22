using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Goals;
using Finance.Domain.Recurring;
using Finance.Domain.Transactions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Finance.Infrastructure.Persistence.Configurations;

internal sealed class RecurringRuleConfiguration : IEntityTypeConfiguration<RecurringRule>
{
    public void Configure(EntityTypeBuilder<RecurringRule> builder)
    {
        builder.Property(r => r.Name).HasMaxLength(100);
        builder.Property(r => r.Type).HasConversion<string>().HasMaxLength(10);
        builder.Property(r => r.Note).HasMaxLength(TransactionRules.MaxNoteLength);
        builder.Property(r => r.Tags).HasColumnType("text[]");
        builder.Property(r => r.Frequency).HasConversion<string>().HasMaxLength(10);
        builder.Property(r => r.DayOfWeek).HasConversion<string>().HasMaxLength(10);
        builder.Ignore(r => r.Schedule);

        builder.HasOne<Account>().WithMany().HasForeignKey(r => r.AccountId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Account>().WithMany().HasForeignKey(r => r.ToAccountId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Category>().WithMany().HasForeignKey(r => r.CategoryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<SavingsGoal>().WithMany().HasForeignKey(r => r.SavingsGoalId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(r => r.AccountId);
        builder.HasIndex(r => r.ToAccountId);
        builder.HasIndex(r => r.CategoryId);
        builder.HasIndex(r => r.SavingsGoalId);

        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_recurring_rules_amount_positive", "amount > 0");
            t.HasCheckConstraint("ck_recurring_rules_interval", "interval >= 1");
            t.HasCheckConstraint("ck_recurring_rules_day_of_month", "day_of_month IS NULL OR day_of_month BETWEEN 1 AND 31");
            t.HasCheckConstraint("ck_recurring_rules_dates", "end_date IS NULL OR end_date >= start_date");
            t.HasCheckConstraint(
                "ck_recurring_rules_shape",
                "(type = 'Transfer' AND to_account_id IS NOT NULL AND to_amount IS NOT NULL AND category_id IS NULL) OR " +
                "(type <> 'Transfer' AND to_account_id IS NULL AND to_amount IS NULL AND category_id IS NOT NULL AND savings_goal_id IS NULL)");
        });
    }
}

internal sealed class SavingsGoalConfiguration : IEntityTypeConfiguration<SavingsGoal>
{
    public void Configure(EntityTypeBuilder<SavingsGoal> builder)
    {
        builder.Property(g => g.Name).HasMaxLength(100);
        builder.Property(g => g.Currency).HasMaxLength(3);
        builder.Property(g => g.Color).HasMaxLength(9);
        builder.Property(g => g.Icon).HasMaxLength(50);
        builder.HasOne<Account>().WithMany().HasForeignKey(g => g.LinkedAccountId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(g => g.LinkedAccountId);
        builder.ToTable(t => t.HasCheckConstraint("ck_savings_goals_target_positive", "target_amount > 0"));
    }
}

internal sealed class BudgetConfiguration : IEntityTypeConfiguration<Budget>
{
    public void Configure(EntityTypeBuilder<Budget> builder)
    {
        builder.Property(b => b.Currency).HasMaxLength(3);
        builder.Ignore(b => b.Period);
        builder.HasIndex(b => new { b.UserId, b.Month }).IsUnique().HasFilter("deleted_at IS NULL");
        builder.ToTable(t =>
        {
            t.HasCheckConstraint("ck_budgets_month_first_day", "extract(day from month) = 1");
            t.HasCheckConstraint("ck_budgets_expected_income", "expected_income >= 0");
        });
    }
}

internal sealed class BudgetLineConfiguration : IEntityTypeConfiguration<BudgetLine>
{
    public void Configure(EntityTypeBuilder<BudgetLine> builder)
    {
        builder.HasOne<Budget>().WithMany().HasForeignKey(l => l.BudgetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<Category>().WithMany().HasForeignKey(l => l.CategoryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(l => new { l.BudgetId, l.CategoryId }).IsUnique().HasFilter("deleted_at IS NULL");
        builder.HasIndex(l => l.CategoryId);
        builder.ToTable(t => t.HasCheckConstraint("ck_budget_lines_planned", "planned_amount >= 0"));
    }
}

internal sealed class BudgetGoalAllocationConfiguration : IEntityTypeConfiguration<BudgetGoalAllocation>
{
    public void Configure(EntityTypeBuilder<BudgetGoalAllocation> builder)
    {
        builder.HasOne<Budget>().WithMany().HasForeignKey(a => a.BudgetId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne<SavingsGoal>().WithMany().HasForeignKey(a => a.SavingsGoalId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(a => new { a.BudgetId, a.SavingsGoalId }).IsUnique().HasFilter("deleted_at IS NULL");
        builder.HasIndex(a => a.SavingsGoalId);
        builder.ToTable(t => t.HasCheckConstraint("ck_budget_goal_allocations_planned", "planned_amount >= 0"));
    }
}
