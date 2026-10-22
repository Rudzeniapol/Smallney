using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Domain.Transactions;
using Finance.Domain.Users;

namespace Finance.Tests.Unit.Domain;

public class UuidV7Tests
{
    [Fact]
    public void New_generates_version_7()
    {
        UuidV7.IsValid(UuidV7.New()).Should().BeTrue();
    }

    [Fact]
    public void Rejects_other_versions_and_empty()
    {
        UuidV7.IsValid(Guid.NewGuid()).Should().BeFalse(); // v4
        UuidV7.IsValid(Guid.Empty).Should().BeFalse();
        UuidV7.IsValid(Guid.Parse("01890a5d-ac96-774b-bcce-b302099a8057")).Should().BeTrue();
        UuidV7.IsValid(Guid.Parse("01890a5d-ac96-774b-0cce-b302099a8057")).Should().BeFalse(); // wrong variant
    }
}

public class BalanceCalculatorTests
{
    private static readonly Guid Main = UuidV7.New();
    private static readonly Guid Savings = UuidV7.New();

    private static Transaction Tx(TransactionType type, long amount, DateOnly date, TransactionStatus status = TransactionStatus.Cleared,
        Guid? account = null, Guid? to = null, long? toAmount = null) => new()
    {
        Id = UuidV7.New(),
        AccountId = account ?? Main,
        Type = type,
        Amount = amount,
        Date = date,
        Status = status,
        ToAccountId = to,
        ToAmount = toAmount,
    };

    [Fact]
    public void Balance_is_initial_plus_cleared_effects()
    {
        var account = new Account { Id = Main, InitialBalance = 10_000 };
        var d = new DateOnly(2026, 3, 1);
        var deleted = Tx(TransactionType.Expense, 999, d);
        deleted.MarkDeleted(DateTime.UtcNow);

        var transactions = new[]
        {
            Tx(TransactionType.Income, 5_000, d),
            Tx(TransactionType.Expense, 1_200, d),
            Tx(TransactionType.Transfer, 2_000, d, to: Savings, toAmount: 2_000),
            Tx(TransactionType.Transfer, 700, d, account: Savings, to: Main, toAmount: 700),
            Tx(TransactionType.Expense, 300, d, TransactionStatus.Planned),
            Tx(TransactionType.Expense, 50, d, account: Savings),
            deleted,
        };

        BalanceCalculator.Balance(account, transactions).Should().Be(10_000 + 5_000 - 1_200 - 2_000 + 700);
    }

    [Fact]
    public void Balance_as_of_ignores_later_transactions()
    {
        var account = new Account { Id = Main, InitialBalance = 0 };
        var transactions = new[]
        {
            Tx(TransactionType.Income, 100, new DateOnly(2026, 1, 31)),
            Tx(TransactionType.Income, 200, new DateOnly(2026, 2, 1)),
        };

        BalanceCalculator.Balance(account, transactions, new DateOnly(2026, 1, 31)).Should().Be(100);
        BalanceCalculator.Balance(account, transactions).Should().Be(300);
    }

    [Fact]
    public void Transfer_to_another_currency_credits_ToAmount()
    {
        var transfer = Tx(TransactionType.Transfer, 10_000, new DateOnly(2026, 1, 1), to: Savings, toAmount: 3_100);

        transfer.BalanceEffect(Main).Should().Be(-10_000);
        transfer.BalanceEffect(Savings).Should().Be(3_100);
        transfer.BalanceEffect(UuidV7.New()).Should().Be(0);
    }

    [Fact]
    public void Account_exposes_initial_money_and_interest_support()
    {
        new Account { InitialBalance = 150, Currency = "USD" }.InitialMoney.ToString().Should().Be("1.50 USD");
        Account.SupportsInterest(AccountType.Deposit).Should().BeTrue();
        Account.SupportsInterest(AccountType.Savings).Should().BeTrue();
        Account.SupportsInterest(AccountType.CreditCard).Should().BeFalse();
    }
}

public class DefaultCategoriesTests
{
    [Fact]
    public void Creates_a_two_level_tree_owned_by_the_user()
    {
        var userId = UuidV7.New();
        var categories = DefaultCategories.CreateFor(userId, UuidV7.New);
        var byId = categories.ToDictionary(c => c.Id);

        categories.Should().OnlyContain(c => c.UserId == userId && UuidV7.IsValid(c.Id));
        foreach (var child in categories.Where(c => c.ParentId is not null))
        {
            var parent = byId[child.ParentId!.Value];
            parent.ParentId.Should().BeNull("only two levels are allowed");
            parent.Kind.Should().Be(child.Kind);
        }
    }

    [Fact]
    public void Has_an_uncategorized_fallback_for_each_kind()
    {
        var categories = DefaultCategories.CreateFor(Guid.Empty, Guid.NewGuid);

        categories.Where(c => c.SystemCode == Category.UncategorizedCode)
            .Select(c => c.Kind)
            .Should().BeEquivalentTo([CategoryKind.Income, CategoryKind.Expense]);
    }

    [Fact]
    public void Names_are_unique_per_kind_and_parent()
    {
        var categories = DefaultCategories.CreateFor(Guid.Empty, Guid.NewGuid);

        categories.GroupBy(c => (c.Kind, c.ParentId, c.Name)).Should().OnlyContain(g => g.Count() == 1);
        categories.Should().Contain(c => c.Name == "Продукты" && c.Kind == CategoryKind.Expense);
        categories.Should().Contain(c => c.Name == "Зарплата" && c.Kind == CategoryKind.Income);
    }
}

public class CategoryRulesTests
{
    private static readonly Category Root = new() { Id = UuidV7.New(), Kind = CategoryKind.Expense };

    [Fact]
    public void Root_category_needs_no_parent()
    {
        var act = () => CategoryRules.EnsureValidParent(UuidV7.New(), CategoryKind.Expense, null, categoryHasChildren: true);
        act.Should().NotThrow();
    }

    [Fact]
    public void Child_of_a_root_with_the_same_kind_is_valid()
    {
        var act = () => CategoryRules.EnsureValidParent(UuidV7.New(), CategoryKind.Expense, Root, categoryHasChildren: false);
        act.Should().NotThrow();
    }

    [Fact]
    public void Third_level_is_rejected()
    {
        var child = new Category { Id = UuidV7.New(), Kind = CategoryKind.Expense, ParentId = Root.Id };
        var act = () => CategoryRules.EnsureValidParent(UuidV7.New(), CategoryKind.Expense, child, categoryHasChildren: false);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("category_depth_exceeded");
    }

    [Fact]
    public void Category_with_children_cannot_be_nested()
    {
        var act = () => CategoryRules.EnsureValidParent(UuidV7.New(), CategoryKind.Expense, Root, categoryHasChildren: true);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("category_depth_exceeded");
    }

    [Fact]
    public void Kind_must_match_the_parent()
    {
        var act = () => CategoryRules.EnsureValidParent(UuidV7.New(), CategoryKind.Income, Root, categoryHasChildren: false);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("category_kind_mismatch");
    }

    [Fact]
    public void Category_cannot_be_its_own_parent()
    {
        var act = () => CategoryRules.EnsureValidParent(Root.Id, CategoryKind.Expense, Root, categoryHasChildren: false);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("category_self_parent");
    }
}

public class TransactionRulesTests
{
    private static readonly Account BynA = new() { Id = UuidV7.New(), Currency = "BYN" };
    private static readonly Account BynB = new() { Id = UuidV7.New(), Currency = "BYN" };
    private static readonly Account Usd = new() { Id = UuidV7.New(), Currency = "USD" };

    [Theory]
    [InlineData(TransactionType.Income, CategoryKind.Income)]
    [InlineData(TransactionType.Expense, CategoryKind.Expense)]
    public void Category_kind_matching_the_type_is_accepted(TransactionType type, CategoryKind kind)
    {
        var act = () => TransactionRules.EnsureCategoryMatches(type, new Category { Kind = kind });
        act.Should().NotThrow();
    }

    [Theory]
    [InlineData(TransactionType.Income, CategoryKind.Expense, "category_kind_mismatch")]
    [InlineData(TransactionType.Expense, CategoryKind.Income, "category_kind_mismatch")]
    [InlineData(TransactionType.Transfer, CategoryKind.Expense, "category_not_allowed")]
    public void Wrong_category_is_rejected(TransactionType type, CategoryKind kind, string code)
    {
        var act = () => TransactionRules.EnsureCategoryMatches(type, new Category { Kind = kind });
        act.Should().Throw<DomainException>().Which.Code.Should().Be(code);
    }

    [Fact]
    public void Same_currency_transfer_defaults_to_amount()
    {
        TransactionRules.ResolveTransferToAmount(BynA, BynB, 500, null).Should().Be(500);
        TransactionRules.ResolveTransferToAmount(BynA, BynB, 500, 500).Should().Be(500);
    }

    [Fact]
    public void Same_currency_transfer_with_different_amount_is_rejected()
    {
        var act = () => TransactionRules.ResolveTransferToAmount(BynA, BynB, 500, 400);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("transfer_amount_mismatch");
    }

    [Fact]
    public void Cross_currency_transfer_requires_to_amount()
    {
        TransactionRules.ResolveTransferToAmount(BynA, Usd, 32_000, 10_000).Should().Be(10_000);
        var act = () => TransactionRules.ResolveTransferToAmount(BynA, Usd, 32_000, null);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("transfer_to_amount_required");
    }

    [Fact]
    public void Transfer_to_the_same_account_is_rejected()
    {
        var act = () => TransactionRules.ResolveTransferToAmount(BynA, BynA, 1, null);
        act.Should().Throw<DomainException>().Which.Code.Should().Be("transfer_same_account");
    }

    [Fact]
    public void Tags_are_trimmed_and_deduplicated_case_insensitively()
    {
        TransactionRules.NormalizeTags([" Trip ", "trip", "", "food", "  "]).Should().Equal("Trip", "food");
        TransactionRules.NormalizeTags(null).Should().BeEmpty();
    }
}

public class UserTests
{
    [Fact]
    public void Email_is_normalized_for_lookup()
    {
        User.NormalizeEmail("  Ivan@Example.COM ").Should().Be("IVAN@EXAMPLE.COM");
    }

    [Fact]
    public void Local_today_uses_the_user_time_zone()
    {
        var utc = new DateTimeOffset(2026, 3, 31, 22, 30, 0, TimeSpan.Zero);

        new User { Timezone = "Europe/Minsk" }.LocalToday(utc).Should().Be(new DateOnly(2026, 4, 1));
        new User { Timezone = "America/New_York" }.LocalToday(utc).Should().Be(new DateOnly(2026, 3, 31));
        UserClock.LocalDate("Not/AZone", utc).Should().Be(new DateOnly(2026, 3, 31));
        UserClock.IsValidTimezone("Europe/Minsk").Should().BeTrue();
        UserClock.IsValidTimezone("Mars/Olympus").Should().BeFalse();
        UserClock.IsValidTimezone(null).Should().BeFalse();
    }

    [Fact]
    public void Refresh_token_can_be_revoked_once()
    {
        var now = DateTime.UtcNow;
        var token = new RefreshToken { ExpiresAt = now.AddDays(1) };
        token.IsActive(now).Should().BeTrue();

        var replacement = Guid.NewGuid();
        token.Revoke(now, "rotated", replacement);
        token.Revoke(now.AddMinutes(1), "logout");

        token.IsActive(now).Should().BeFalse();
        token.RevokedReason.Should().Be("rotated");
        token.ReplacedByTokenId.Should().Be(replacement);
        new RefreshToken { ExpiresAt = now.AddSeconds(-1) }.IsActive(now).Should().BeFalse();
    }
}
