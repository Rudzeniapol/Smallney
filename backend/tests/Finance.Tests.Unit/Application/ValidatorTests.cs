using Finance.Application.Common;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Auth;
using Finance.Application.Features.Categories;
using Finance.Application.Features.Me;
using Finance.Application.Features.Transactions;
using Finance.Domain.Accounts;
using Finance.Domain.Categories;
using Finance.Domain.Common;
using Finance.Domain.Transactions;
using FluentValidation;
using FluentValidation.TestHelper;

namespace Finance.Tests.Unit.Application;

public class AccountPayloadValidatorTests
{
    private readonly AccountPayloadValidator _validator = new();

    private static AccountPayload Valid(AccountType type = AccountType.DebitCard) =>
        new() { Name = "Карта", Type = type, Currency = "BYN", InitialBalance = 10_000 };

    [Fact]
    public void Valid_debit_card_passes() => _validator.TestValidate(Valid()).ShouldNotHaveAnyValidationErrors();

    [Fact]
    public void Required_fields_are_reported()
    {
        var result = _validator.TestValidate(new AccountPayload());

        result.ShouldHaveValidationErrorFor(x => x.Name);
        result.ShouldHaveValidationErrorFor(x => x.Type);
        result.ShouldHaveValidationErrorFor(x => x.Currency);
    }

    [Theory]
    [InlineData("XYZ")]
    [InlineData("BY")]
    public void Unknown_currency_fails(string currency) =>
        _validator.TestValidate(Valid() with { Currency = currency })
            .ShouldHaveValidationErrorFor(x => x.Currency).WithErrorCode("unsupported_currency");

    [Fact]
    public void Lowercase_currency_is_accepted() =>
        _validator.TestValidate(Valid() with { Currency = "usd" }).ShouldNotHaveAnyValidationErrors();

    [Fact]
    public void Credit_limit_only_for_credit_cards()
    {
        _validator.TestValidate(Valid(AccountType.CreditCard) with { CreditLimit = 500_000 }).ShouldNotHaveAnyValidationErrors();
        _validator.TestValidate(Valid() with { CreditLimit = 500_000 })
            .ShouldHaveValidationErrorFor(x => x.CreditLimit).WithErrorCode("credit_limit_not_allowed");
        _validator.TestValidate(Valid(AccountType.CreditCard) with { CreditLimit = -1 })
            .ShouldHaveValidationErrorFor(x => x.CreditLimit);
    }

    [Fact]
    public void Deposit_requires_open_date_and_capitalization_with_rate()
    {
        var deposit = Valid(AccountType.Deposit) with { InterestRatePercent = 12.5m };
        var result = _validator.TestValidate(deposit);
        result.ShouldHaveValidationErrorFor(x => x.CapitalizationPeriod);
        result.ShouldHaveValidationErrorFor(x => x.OpenDate);

        _validator.TestValidate(deposit with
        {
            CapitalizationPeriod = CapitalizationPeriod.Monthly,
            OpenDate = new DateOnly(2026, 1, 1),
            MaturityDate = new DateOnly(2027, 1, 1),
        }).ShouldNotHaveAnyValidationErrors();
    }

    [Fact]
    public void Maturity_must_follow_open_date() =>
        _validator.TestValidate(Valid(AccountType.Deposit) with
        {
            OpenDate = new DateOnly(2026, 1, 1),
            MaturityDate = new DateOnly(2025, 1, 1),
        }).ShouldHaveValidationErrorFor(x => x.MaturityDate);

    [Fact]
    public void Interest_is_rejected_for_cash() =>
        _validator.TestValidate(Valid(AccountType.Cash) with { InterestRatePercent = 5, CapitalizationPeriod = CapitalizationPeriod.None })
            .ShouldHaveValidationErrorFor(x => x.InterestRatePercent).WithErrorCode("interest_not_allowed");

    [Theory]
    [InlineData("#85BB65", true)]
    [InlineData("#85BB6524", true)]
    [InlineData("85BB65", false)]
    [InlineData("#XYZXYZ", false)]
    public void Color_must_be_hex(string color, bool valid)
    {
        var result = _validator.TestValidate(Valid() with { Color = color });
        if (valid)
        {
            result.ShouldNotHaveValidationErrorFor(x => x.Color);
        }
        else
        {
            result.ShouldHaveValidationErrorFor(x => x.Color).WithErrorCode("invalid_color");
        }
    }
}

public class TransactionPayloadValidatorTests
{
    private readonly TransactionPayloadValidator _validator = new();

    private static TransactionPayload Expense() => new()
    {
        AccountId = UuidV7.New(),
        Type = TransactionType.Expense,
        Amount = 2450,
        CategoryId = UuidV7.New(),
        Date = new DateOnly(2026, 10, 22),
    };

    [Fact]
    public void Valid_expense_passes() => _validator.TestValidate(Expense()).ShouldNotHaveAnyValidationErrors();

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public void Amount_must_be_positive(long amount) =>
        _validator.TestValidate(Expense() with { Amount = amount }).ShouldHaveValidationErrorFor(x => x.Amount);

    [Fact]
    public void Expense_requires_category_and_no_transfer_fields()
    {
        var result = _validator.TestValidate(Expense() with { CategoryId = null, ToAccountId = UuidV7.New(), ToAmount = 1 });

        result.ShouldHaveValidationErrorFor(x => x.CategoryId).WithErrorCode("category_required");
        result.ShouldHaveValidationErrorFor(x => x.ToAccountId).WithErrorCode("transfer_fields_not_allowed");
        result.ShouldHaveValidationErrorFor(x => x.ToAmount).WithErrorCode("transfer_fields_not_allowed");
    }

    [Fact]
    public void Transfer_rules()
    {
        var accountId = UuidV7.New();
        var transfer = Expense() with { Type = TransactionType.Transfer, AccountId = accountId, ToAccountId = accountId };
        var result = _validator.TestValidate(transfer);

        result.ShouldHaveValidationErrorFor(x => x.CategoryId).WithErrorCode("category_not_allowed");
        result.ShouldHaveValidationErrorFor(x => x.ToAccountId).WithErrorCode("transfer_same_account");

        _validator.TestValidate(transfer with { CategoryId = null, ToAccountId = UuidV7.New(), ToAmount = 10 })
            .ShouldNotHaveAnyValidationErrors();
    }

    [Fact]
    public void Tags_and_note_are_limited()
    {
        var tooMany = Enumerable.Range(0, 21).Select(i => $"t{i}").ToArray();
        _validator.TestValidate(Expense() with { Tags = tooMany }).ShouldHaveValidationErrorFor(x => x.Tags);
        _validator.TestValidate(Expense() with { Tags = [new string('x', 51)] }).ShouldHaveValidationErrorFor("Tags[0]");
        _validator.TestValidate(Expense() with { Note = new string('x', 501) }).ShouldHaveValidationErrorFor(x => x.Note);
    }

    [Fact]
    public void Date_is_required_and_sane()
    {
        _validator.TestValidate(Expense() with { Date = null }).ShouldHaveValidationErrorFor(x => x.Date);
        _validator.TestValidate(Expense() with { Date = new DateOnly(1800, 1, 1) })
            .ShouldHaveValidationErrorFor(x => x.Date).WithErrorCode("date_out_of_range");
    }

    [Fact]
    public void Filter_limits_page_size_and_period()
    {
        var validator = new TransactionFilterValidator();
        validator.TestValidate(new TransactionFilter { Limit = 500 }).ShouldHaveValidationErrorFor(x => x.Limit);
        validator.TestValidate(new TransactionFilter { From = new DateOnly(2026, 2, 1), To = new DateOnly(2026, 1, 1) })
            .ShouldHaveValidationErrorFor(x => x.To);
        validator.TestValidate(new TransactionFilter { Limit = 10 }).ShouldNotHaveAnyValidationErrors();
    }
}

public class OtherValidatorTests
{
    [Fact]
    public void Category_payload()
    {
        var validator = new CategoryPayloadValidator();
        validator.TestValidate(new CategoryPayload { Name = "Кофе", Kind = CategoryKind.Expense }).ShouldNotHaveAnyValidationErrors();
        var result = validator.TestValidate(new CategoryPayload { Name = "", Kind = null, Color = "red" });
        result.ShouldHaveValidationErrorFor(x => x.Name);
        result.ShouldHaveValidationErrorFor(x => x.Kind);
        result.ShouldHaveValidationErrorFor(x => x.Color);
    }

    [Fact]
    public void Register_request()
    {
        var validator = new RegisterRequestValidator();
        validator.TestValidate(new RegisterRequest { Email = "a@b.by", Password = "12345678" }).ShouldNotHaveAnyValidationErrors();

        var result = validator.TestValidate(new RegisterRequest
        {
            Email = "not-an-email",
            Password = "short",
            BaseCurrency = "XXX",
            Timezone = "Nowhere/City",
            FirstDayOfMonth = 31,
        });
        result.ShouldHaveValidationErrorFor(x => x.Email);
        result.ShouldHaveValidationErrorFor(x => x.Password);
        result.ShouldHaveValidationErrorFor(x => x.BaseCurrency);
        result.ShouldHaveValidationErrorFor(x => x.Timezone).WithErrorCode("invalid_timezone");
        result.ShouldHaveValidationErrorFor(x => x.FirstDayOfMonth);
    }

    [Fact]
    public void Login_and_refresh_requests()
    {
        new LoginRequestValidator().TestValidate(new LoginRequest(null, "")).IsValid.Should().BeFalse();
        new RefreshRequestValidator().TestValidate(new RefreshRequest("")).IsValid.Should().BeFalse();
        new RefreshRequestValidator().TestValidate(new RefreshRequest("abc")).IsValid.Should().BeTrue();
    }

    [Fact]
    public void Update_me_request()
    {
        var validator = new UpdateMeRequestValidator();
        validator.TestValidate(new UpdateMeRequest()).ShouldNotHaveAnyValidationErrors();
        var result = validator.TestValidate(new UpdateMeRequest { FirstDayOfMonth = 0, LowBalanceThreshold = -1, BaseCurrency = "zz" });
        result.ShouldHaveValidationErrorFor(x => x.FirstDayOfMonth);
        result.ShouldHaveValidationErrorFor(x => x.LowBalanceThreshold);
        result.ShouldHaveValidationErrorFor(x => x.BaseCurrency);
    }

    [Fact]
    public void Ids_must_be_uuid_v7()
    {
        var act = () => ValidationRules.EnsureUuidV7(Guid.NewGuid());
        act.Should().Throw<ValidationException>().Which.Errors.Should().ContainSingle(e => e.ErrorCode == "invalid_id");
        ((Action)(() => ValidationRules.EnsureUuidV7(UuidV7.New()))).Should().NotThrow();
    }
}

public class CursorTests
{
    [Fact]
    public void Round_trips()
    {
        var cursor = new DateIdCursor(new DateOnly(2026, 10, 22), UuidV7.New());
        DateIdCursor.Decode(cursor.Encode()).Should().Be(cursor);
    }

    [Theory]
    [InlineData("garbage!!")]
    [InlineData("aGVsbG8")] // "hello"
    public void Malformed_cursor_is_a_validation_error(string raw)
    {
        var act = () => DateIdCursor.Decode(raw);
        act.Should().Throw<ValidationException>().Which.Errors.Should().ContainSingle(e => e.ErrorCode == "invalid_cursor");
    }

    [Fact]
    public void Page_reports_has_more()
    {
        new CursorPage<int>([1], "next").HasMore.Should().BeTrue();
        new CursorPage<int>([1], null).HasMore.Should().BeFalse();
    }
}
