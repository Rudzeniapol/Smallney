using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Me;
using Finance.Domain.Analytics;
using Finance.Domain.Budgets;
using Finance.Domain.Categories;
using Finance.Domain.Monetary;
using Finance.Domain.Transactions;
using Finance.Domain.Users;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Analytics;

/// <summary>
/// Reports over cleared income and expenses (transfers excluded) in the base currency, each transaction converted
/// at the rate of its date. Periods default to the current financial month.
/// </summary>
public sealed class AnalyticsService(
    IAppDbContext db,
    MeService me,
    SpendingQueries spending,
    TimeProvider clock,
    IValidator<DateRange> rangeValidator)
{
    public const int MaxMonths = 36;
    public const int MaxTop = 50;

    public async Task<CategoryBreakdownResponse> CategoriesAsync(DateOnly? from, DateOnly? to, CategoryKind kind, CancellationToken ct)
    {
        var (user, period) = await PeriodAsync(from, to, ct);
        var previous = AnalyticsMath.PreviousPeriod(period, user.FirstDayOfMonth);
        var currency = Currency.FromCode(user.BaseCurrency);
        var type = kind.ToTransactionType();

        var current = await ByCategoryAsync(period, type, currency, ct);
        var before = await ByCategoryAsync(previous, type, currency, ct);
        var categories = await db.Categories.AsNoTracking().IgnoreQueryFilters([QueryFilters.SoftDelete])
            .ToDictionaryAsync(c => c.Id, c => c.ParentId, ct);

        Guid RootOf(Guid id) => categories.GetValueOrDefault(id) ?? id;
        var total = current.Values.Sum();
        var previousTotal = before.Values.Sum();

        CategoryBreakdownItem Item(Guid id, long amount, long direct, long previousAmount, IReadOnlyList<CategoryBreakdownItem> children) =>
            new(id, amount, direct, AnalyticsMath.Share(amount, total), previousAmount, AnalyticsMath.ChangePercent(amount, previousAmount), children);

        var roots = current.Keys.Concat(before.Keys).Select(RootOf).Distinct()
            .Select(root =>
            {
                var children = current.Keys.Concat(before.Keys).Distinct()
                    .Where(id => id != root && RootOf(id) == root)
                    .Select(id => Item(id, current.GetValueOrDefault(id), current.GetValueOrDefault(id), before.GetValueOrDefault(id), []))
                    .OrderByDescending(c => c.Amount)
                    .ToList();
                var amount = current.GetValueOrDefault(root) + children.Sum(c => c.Amount);
                var previousAmount = before.GetValueOrDefault(root) + children.Sum(c => c.PreviousAmount);
                return Item(root, amount, current.GetValueOrDefault(root), previousAmount, children);
            })
            .OrderByDescending(c => c.Amount)
            .ThenByDescending(c => c.PreviousAmount)
            .ToList();

        return new CategoryBreakdownResponse(period.From, period.To, previous.From, previous.To, kind, currency.Code,
            total, previousTotal, AnalyticsMath.ChangePercent(total, previousTotal), roots);
    }

    public async Task<MonthlyDynamicsResponse> MonthlyAsync(int? months, Guid? categoryId, CancellationToken ct)
    {
        var count = EnsureMonths(months ?? 6);
        var user = await me.GetUserAsync(ct);
        var firstDay = user.FirstDayOfMonth;
        var currency = Currency.FromCode(user.BaseCurrency);
        var current = FinancialMonth.Containing(user.LocalToday(clock.GetUtcNow()), firstDay);
        var first = current.AddMonths(-(count - 1));

        HashSet<Guid>? onlyCategories = null;
        if (categoryId is { } id)
        {
            onlyCategories = (await db.Categories.Where(c => c.Id == id || c.ParentId == id).Select(c => c.Id).ToListAsync(ct)).ToHashSet();
            if (!onlyCategories.Contains(id))
            {
                throw new NotFoundException("Category", id);
            }
        }

        var flows = (await spending.FlowsAsync(first.Start(firstDay), current.End(firstDay), ct))
            .Where(f => onlyCategories is null || onlyCategories.Contains(f.CategoryId))
            .ToList();
        var table = await spending.RatesAsync(ct);
        var sums = SpendingQueries.Sum(flows, f => (FinancialMonth.Containing(f.Date, firstDay), f.Type), f => f.Money, f => f.Date, currency, table);

        var points = Enumerable.Range(0, count).Select(i =>
        {
            var month = first.AddMonths(i);
            var income = sums.GetValueOrDefault((month, TransactionType.Income));
            var expense = sums.GetValueOrDefault((month, TransactionType.Expense));
            return new MonthlyPoint(month.ToString(), month.Start(firstDay), month.End(firstDay), income, expense, income - expense, month == current);
        }).ToList();

        return new MonthlyDynamicsResponse(currency.Code, categoryId, points);
    }

    public async Task<PeriodComparisonResponse> CompareAsync(DateOnly? from, DateOnly? to, CancellationToken ct)
    {
        var (user, period) = await PeriodAsync(from, to, ct);
        var previousPeriod = AnalyticsMath.PreviousPeriod(period, user.FirstDayOfMonth);
        var currency = Currency.FromCode(user.BaseCurrency);

        var current = await TotalsAsync(period, currency, ct);
        var previous = await TotalsAsync(previousPeriod, currency, ct);
        static Change Diff(long now, long before) => new(now - before, AnalyticsMath.ChangePercent(now, before));

        return new PeriodComparisonResponse(currency.Code, current, previous,
            Diff(current.Income, previous.Income), Diff(current.Expense, previous.Expense), Diff(current.Net, previous.Net));
    }

    /// <summary>
    /// Sum of account balances at each financial month end (today for the month in progress), each converted at the
    /// rate of that date. An account counts from the earliest of its creation, its open date and its first transaction.
    /// </summary>
    public async Task<NetWorthResponse> NetWorthAsync(int? months, bool includeExcluded, CancellationToken ct)
    {
        var count = EnsureMonths(months ?? 12);
        var user = await me.GetUserAsync(ct);
        var firstDay = user.FirstDayOfMonth;
        var currency = Currency.FromCode(user.BaseCurrency);
        var today = user.LocalToday(clock.GetUtcNow());
        var current = FinancialMonth.Containing(today, firstDay);
        var first = current.AddMonths(-(count - 1));
        var lastDate = today;

        var accounts = await db.Accounts.AsNoTracking().Where(a => includeExcluded || a.IncludeInTotals).ToListAsync(ct);
        var ids = accounts.Select(a => a.Id).ToList();
        var cleared = db.Transactions.Where(t => t.Status == TransactionStatus.Cleared && t.Date <= lastDate);
        var outgoing = await cleared.Where(t => ids.Contains(t.AccountId))
            .GroupBy(t => new { t.AccountId, t.Date })
            .Select(g => new { g.Key.AccountId, g.Key.Date, Sum = g.Sum(t => t.Type == TransactionType.Income ? t.Amount : -t.Amount) })
            .ToListAsync(ct);
        var incoming = await cleared.Where(t => t.ToAccountId != null && ids.Contains(t.ToAccountId.Value))
            .GroupBy(t => new { AccountId = t.ToAccountId!.Value, t.Date })
            .Select(g => new { g.Key.AccountId, g.Key.Date, Sum = g.Sum(t => t.ToAmount ?? 0) })
            .ToListAsync(ct);
        var movements = outgoing.Concat(incoming).ToLookup(m => m.AccountId);
        var table = await spending.RatesAsync(ct);

        var dates = Enumerable.Range(0, count).Select(i => first.AddMonths(i))
            .Select(m => (Month: m, Date: m == current ? today : m.End(firstDay)))
            .ToList();
        var points = new List<NetWorthPoint>(count);
        long? previousValue = null;
        foreach (var (month, date) in dates)
        {
            long total = 0;
            foreach (var account in accounts)
            {
                var activity = movements[account.Id].ToList();
                var created = UserClock.LocalDate(user.Timezone, new DateTimeOffset(DateTime.SpecifyKind(account.CreatedAt, DateTimeKind.Utc)));
                var since = new[] { created, account.OpenDate ?? created, activity.Count > 0 ? activity.Min(m => m.Date) : created }.Min();
                if (since > date)
                {
                    continue;
                }

                var balance = account.InitialBalance + activity.Where(m => m.Date <= date).Sum(m => m.Sum);
                total += table.Convert(new Money(balance, Currency.FromCode(account.Currency)), currency, date).Amount;
            }

            points.Add(new NetWorthPoint(month.ToString(), date, total, previousValue is { } p ? total - p : 0));
            previousValue = total;
        }

        return new NetWorthResponse(currency.Code, includeExcluded, points);
    }

    public async Task<TopExpensesResponse> TopExpensesAsync(DateOnly? from, DateOnly? to, int? limit, CancellationToken ct)
    {
        var take = limit ?? 10;
        if (take is < 1 or > MaxTop)
        {
            throw new ValidationException([new ValidationFailure("limit", $"Use 1 to {MaxTop}.")]);
        }

        var (user, period) = await PeriodAsync(from, to, ct);
        var currency = Currency.FromCode(user.BaseCurrency);
        var rows = await (
                from t in db.Transactions
                join a in db.Accounts on t.AccountId equals a.Id
                where t.Status == TransactionStatus.Cleared && t.Type == TransactionType.Expense
                      && t.Date >= period.From && t.Date <= period.To
                select new { t.Id, t.Date, t.AccountId, t.CategoryId, t.Note, t.Amount, a.Currency })
            .ToListAsync(ct);
        var table = await spending.RatesAsync(ct);

        var items = rows
            .Select(r => new TopExpense(r.Id, r.Date, r.AccountId, r.CategoryId, r.Note, r.Amount, r.Currency,
                table.Convert(new Money(r.Amount, Currency.FromCode(r.Currency)), currency, r.Date).Amount))
            .OrderByDescending(x => x.AmountInBase)
            .ThenByDescending(x => x.Date)
            .Take(take)
            .ToList();
        return new TopExpensesResponse(period.From, period.To, currency.Code, items);
    }

    public async Task<AveragesResponse> AveragesAsync(DateOnly? from, DateOnly? to, CancellationToken ct)
    {
        var (user, period) = await PeriodAsync(from, to, ct);
        var currency = Currency.FromCode(user.BaseCurrency);
        var totals = await TotalsAsync(period, currency, ct);
        var averages = AnalyticsMath.Averages(new Money(totals.Expense, currency), period, user.LocalToday(clock.GetUtcNow()));
        return new AveragesResponse(period.From, period.To, currency.Code, averages.Total, averages.Days,
            averages.PerDay, averages.PerWeek, averages.PerMonth);
    }

    private async Task<(User User, Period Period)> PeriodAsync(DateOnly? from, DateOnly? to, CancellationToken ct)
    {
        var user = await me.GetUserAsync(ct);
        var month = FinancialMonth.Containing(user.LocalToday(clock.GetUtcNow()), user.FirstDayOfMonth);
        var period = new Period(from ?? month.Start(user.FirstDayOfMonth), to ?? month.End(user.FirstDayOfMonth));
        await rangeValidator.ValidateAndThrowAsync(new DateRange(period.From, period.To), ct);
        return (user, period);
    }

    private async Task<Dictionary<Guid, long>> ByCategoryAsync(Period period, TransactionType type, Currency currency, CancellationToken ct)
    {
        var flows = (await spending.FlowsAsync(period.From, period.To, ct)).Where(f => f.Type == type);
        return SpendingQueries.Sum(flows, f => f.CategoryId, f => f.Money, f => f.Date, currency, await spending.RatesAsync(ct));
    }

    private async Task<PeriodTotals> TotalsAsync(Period period, Currency currency, CancellationToken ct)
    {
        var flows = await spending.FlowsAsync(period.From, period.To, ct);
        var sums = SpendingQueries.Sum(flows, f => f.Type, f => f.Money, f => f.Date, currency, await spending.RatesAsync(ct));
        var income = sums.GetValueOrDefault(TransactionType.Income);
        var expense = sums.GetValueOrDefault(TransactionType.Expense);
        return new PeriodTotals(period.From, period.To, income, expense, income - expense);
    }

    private static int EnsureMonths(int months) =>
        months is >= 1 and <= MaxMonths
            ? months
            : throw new ValidationException([new ValidationFailure("months", $"Use 1 to {MaxMonths} months.")]);
}
