using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Finance.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RecurringBudgetsGoals : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateOnly>(
                name: "recurrence_date",
                table: "transactions",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "recurring_rule_id",
                table: "transactions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "savings_goal_id",
                table: "transactions",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "budgets",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    month = table.Column<DateOnly>(type: "date", nullable: false),
                    currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    expected_income = table.Column<long>(type: "bigint", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    version = table.Column<long>(type: "bigint", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_budgets", x => x.id);
                    table.CheckConstraint("ck_budgets_expected_income", "expected_income >= 0");
                    table.CheckConstraint("ck_budgets_month_first_day", "extract(day from month) = 1");
                    table.ForeignKey(
                        name: "fk_budgets_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "savings_goals",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    target_amount = table.Column<long>(type: "bigint", nullable: false),
                    currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    target_date = table.Column<DateOnly>(type: "date", nullable: true),
                    linked_account_id = table.Column<Guid>(type: "uuid", nullable: true),
                    priority = table.Column<int>(type: "integer", nullable: false),
                    is_completed = table.Column<bool>(type: "boolean", nullable: false),
                    completed_on = table.Column<DateOnly>(type: "date", nullable: true),
                    color = table.Column<string>(type: "character varying(9)", maxLength: 9, nullable: true),
                    icon = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    version = table.Column<long>(type: "bigint", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_savings_goals", x => x.id);
                    table.CheckConstraint("ck_savings_goals_target_positive", "target_amount > 0");
                    table.ForeignKey(
                        name: "fk_savings_goals_accounts_linked_account_id",
                        column: x => x.linked_account_id,
                        principalTable: "accounts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_savings_goals_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "budget_lines",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    budget_id = table.Column<Guid>(type: "uuid", nullable: false),
                    category_id = table.Column<Guid>(type: "uuid", nullable: false),
                    planned_amount = table.Column<long>(type: "bigint", nullable: false),
                    rollover = table.Column<bool>(type: "boolean", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    version = table.Column<long>(type: "bigint", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_budget_lines", x => x.id);
                    table.CheckConstraint("ck_budget_lines_planned", "planned_amount >= 0");
                    table.ForeignKey(
                        name: "fk_budget_lines_budgets_budget_id",
                        column: x => x.budget_id,
                        principalTable: "budgets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_budget_lines_categories_category_id",
                        column: x => x.category_id,
                        principalTable: "categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_budget_lines_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "budget_goal_allocations",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    budget_id = table.Column<Guid>(type: "uuid", nullable: false),
                    savings_goal_id = table.Column<Guid>(type: "uuid", nullable: false),
                    planned_amount = table.Column<long>(type: "bigint", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    version = table.Column<long>(type: "bigint", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_budget_goal_allocations", x => x.id);
                    table.CheckConstraint("ck_budget_goal_allocations_planned", "planned_amount >= 0");
                    table.ForeignKey(
                        name: "fk_budget_goal_allocations_budgets_budget_id",
                        column: x => x.budget_id,
                        principalTable: "budgets",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_budget_goal_allocations_savings_goals_savings_goal_id",
                        column: x => x.savings_goal_id,
                        principalTable: "savings_goals",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_budget_goal_allocations_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "recurring_rules",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    account_id = table.Column<Guid>(type: "uuid", nullable: false),
                    type = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    amount = table.Column<long>(type: "bigint", nullable: false),
                    category_id = table.Column<Guid>(type: "uuid", nullable: true),
                    note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    tags = table.Column<string[]>(type: "text[]", nullable: false),
                    to_account_id = table.Column<Guid>(type: "uuid", nullable: true),
                    to_amount = table.Column<long>(type: "bigint", nullable: true),
                    savings_goal_id = table.Column<Guid>(type: "uuid", nullable: true),
                    frequency = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    interval = table.Column<int>(type: "integer", nullable: false),
                    day_of_month = table.Column<int>(type: "integer", nullable: true),
                    day_of_week = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    start_date = table.Column<DateOnly>(type: "date", nullable: false),
                    end_date = table.Column<DateOnly>(type: "date", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    version = table.Column<long>(type: "bigint", nullable: false),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_recurring_rules", x => x.id);
                    table.CheckConstraint("ck_recurring_rules_amount_positive", "amount > 0");
                    table.CheckConstraint("ck_recurring_rules_dates", "end_date IS NULL OR end_date >= start_date");
                    table.CheckConstraint("ck_recurring_rules_day_of_month", "day_of_month IS NULL OR day_of_month BETWEEN 1 AND 31");
                    table.CheckConstraint("ck_recurring_rules_interval", "interval >= 1");
                    table.CheckConstraint("ck_recurring_rules_shape", "(type = 'Transfer' AND to_account_id IS NOT NULL AND to_amount IS NOT NULL AND category_id IS NULL) OR (type <> 'Transfer' AND to_account_id IS NULL AND to_amount IS NULL AND category_id IS NOT NULL AND savings_goal_id IS NULL)");
                    table.ForeignKey(
                        name: "fk_recurring_rules_accounts_account_id",
                        column: x => x.account_id,
                        principalTable: "accounts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_recurring_rules_accounts_to_account_id",
                        column: x => x.to_account_id,
                        principalTable: "accounts",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_recurring_rules_categories_category_id",
                        column: x => x.category_id,
                        principalTable: "categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_recurring_rules_savings_goals_savings_goal_id",
                        column: x => x.savings_goal_id,
                        principalTable: "savings_goals",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_recurring_rules_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "ix_transactions_recurrence",
                table: "transactions",
                columns: new[] { "recurring_rule_id", "recurrence_date" },
                unique: true,
                filter: "recurring_rule_id IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "ix_transactions_savings_goal_id",
                table: "transactions",
                column: "savings_goal_id",
                filter: "savings_goal_id IS NOT NULL");

            migrationBuilder.AddCheckConstraint(
                name: "ck_transactions_goal_transfer",
                table: "transactions",
                sql: "savings_goal_id IS NULL OR type = 'Transfer'");

            migrationBuilder.AddCheckConstraint(
                name: "ck_transactions_recurrence",
                table: "transactions",
                sql: "(recurring_rule_id IS NULL) = (recurrence_date IS NULL)");

            migrationBuilder.CreateIndex(
                name: "ix_budget_goal_allocations_budget_id_savings_goal_id",
                table: "budget_goal_allocations",
                columns: new[] { "budget_id", "savings_goal_id" },
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_budget_goal_allocations_savings_goal_id",
                table: "budget_goal_allocations",
                column: "savings_goal_id");

            migrationBuilder.CreateIndex(
                name: "ix_budget_goal_allocations_user_id_version",
                table: "budget_goal_allocations",
                columns: new[] { "user_id", "version" });

            migrationBuilder.CreateIndex(
                name: "ix_budget_lines_budget_id_category_id",
                table: "budget_lines",
                columns: new[] { "budget_id", "category_id" },
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_budget_lines_category_id",
                table: "budget_lines",
                column: "category_id");

            migrationBuilder.CreateIndex(
                name: "ix_budget_lines_user_id_version",
                table: "budget_lines",
                columns: new[] { "user_id", "version" });

            migrationBuilder.CreateIndex(
                name: "ix_budgets_user_id_month",
                table: "budgets",
                columns: new[] { "user_id", "month" },
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_budgets_user_id_version",
                table: "budgets",
                columns: new[] { "user_id", "version" });

            migrationBuilder.CreateIndex(
                name: "ix_recurring_rules_account_id",
                table: "recurring_rules",
                column: "account_id");

            migrationBuilder.CreateIndex(
                name: "ix_recurring_rules_category_id",
                table: "recurring_rules",
                column: "category_id");

            migrationBuilder.CreateIndex(
                name: "ix_recurring_rules_savings_goal_id",
                table: "recurring_rules",
                column: "savings_goal_id");

            migrationBuilder.CreateIndex(
                name: "ix_recurring_rules_to_account_id",
                table: "recurring_rules",
                column: "to_account_id");

            migrationBuilder.CreateIndex(
                name: "ix_recurring_rules_user_id_version",
                table: "recurring_rules",
                columns: new[] { "user_id", "version" });

            migrationBuilder.CreateIndex(
                name: "ix_savings_goals_linked_account_id",
                table: "savings_goals",
                column: "linked_account_id");

            migrationBuilder.CreateIndex(
                name: "ix_savings_goals_user_id_version",
                table: "savings_goals",
                columns: new[] { "user_id", "version" });

            migrationBuilder.AddForeignKey(
                name: "fk_transactions_recurring_rules_recurring_rule_id",
                table: "transactions",
                column: "recurring_rule_id",
                principalTable: "recurring_rules",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "fk_transactions_savings_goals_savings_goal_id",
                table: "transactions",
                column: "savings_goal_id",
                principalTable: "savings_goals",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_transactions_recurring_rules_recurring_rule_id",
                table: "transactions");

            migrationBuilder.DropForeignKey(
                name: "fk_transactions_savings_goals_savings_goal_id",
                table: "transactions");

            migrationBuilder.DropTable(
                name: "budget_goal_allocations");

            migrationBuilder.DropTable(
                name: "budget_lines");

            migrationBuilder.DropTable(
                name: "recurring_rules");

            migrationBuilder.DropTable(
                name: "budgets");

            migrationBuilder.DropTable(
                name: "savings_goals");

            migrationBuilder.DropIndex(
                name: "ix_transactions_recurrence",
                table: "transactions");

            migrationBuilder.DropIndex(
                name: "ix_transactions_savings_goal_id",
                table: "transactions");

            migrationBuilder.DropCheckConstraint(
                name: "ck_transactions_goal_transfer",
                table: "transactions");

            migrationBuilder.DropCheckConstraint(
                name: "ck_transactions_recurrence",
                table: "transactions");

            migrationBuilder.DropColumn(
                name: "recurrence_date",
                table: "transactions");

            migrationBuilder.DropColumn(
                name: "recurring_rule_id",
                table: "transactions");

            migrationBuilder.DropColumn(
                name: "savings_goal_id",
                table: "transactions");
        }
    }
}
