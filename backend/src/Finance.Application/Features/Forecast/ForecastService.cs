using Finance.Application.Abstractions;
using Finance.Application.Common;
using Finance.Application.Features.Accounts;
using Finance.Application.Features.Budgets;
using Finance.Application.Features.Goals;
using Finance.Application.Features.Me;
using Finance.Domain.Accounts;
using Finance.Domain.Budgets;
using Finance.Domain.Common;
using Finance.Domain.ExchangeRates;
using Finance.Domain.Forecasting;
using Finance.Domain.Monetary;
using Finance.Domain.Transactions;
using Finance.Domain.Users;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;

namespace Finance.Application.Features.Forecast;

/// <summary>Collects the user's data into a <see cref="ForecastInput"/> and runs the pure <see cref="ForecastEngine"/>.</summary>
public sealed class ForecastService(
    IAppDbContext db,
    MeService me,
    BalanceQueries balances,
    SpendingQueries spending,
    BudgetSummaryService budgetSummaries,
    GoalQueries goals,
    TimeProvider clock,
    IValidator<ForecastRequest> validator)
{
    public const int HistoryMonths = 3;

    public async Task<ForecastResponse> GetAsync(ForecastRequest request, CancellationToken ct)
    {
        await validator.ValidateAndThrowAsync(request, ct);
        var user = await me.GetUserAsync(ct);
        var now = clock.GetUtcNow();
        var today = user.LocalToday(now);
        var from = request.From is { } f && f > today ? f : today;
        var to = request.To ?? today.AddMonths(3);
        var oneOffs = request.ExtraOneOffs ?? [];
        Validate(today, from, to, oneOffs);

        var baseCurrency = Currency.FromCode(user.BaseCurrency);
        var table = await spending.RatesAsync(ct);
        var openGoals = await db.SavingsGoals.AsNoTracking().Where(g => !g.IsCompleted).ToListAsync(ct);

        // Accounts in totals, plus those a goal or a "what if" operation needs.
        var allAccounts = await db.Accounts.AsNoTracking().OrderBy(a => a.SortOrder).ThenBy(a => a.Name).ToListAsync(ct);
        var needed = openGoals.Select(g => g.LinkedAccountId).OfType<Guid>().Concat(oneOffs.Select(o => o.AccountId!.Value)).ToHashSet();
        var missing = oneOffs.Select(o => o.AccountId!.Value).FirstOrDefault(id => allAccounts.All(a => a.Id != id));
        if (missing != Guid.Empty)
        {
            throw new DomainException("account_not_found", $"Account '{missing}' was not found.");
        }

        var simulated = allAccounts.Where(a => a.IncludeInTotals || needed.Contains(a.Id)).ToList();
        var start = await balances.GetBalancesAsync(simulated.Select(a => a.Id).ToList(), asOf: today, ct);
        var accounts = simulated.Select(a => new ForecastAccount(
            a.Id, a.Currency, start.GetValueOrDefault(a.Id, a.InitialBalance), a.IncludeInTotals, a.Type, a.CreditLimit,
            a.InterestRatePercent, a.CapitalizationPeriod, a.OpenDate, a.MaturityDate)).ToList();

        var forecastGoals = await ForecastGoalsAsync(openGoals, user, today, ct);
        var draft = new ForecastInput(today, from, to, request.Granularity ?? ForecastGranularity.Day, baseCurrency, user.FirstDayOfMonth,
            user.LowBalanceThreshold, SpendingAccount(user, allAccounts, simulated), accounts, [], [], forecastGoals, table);
        var end = ForecastEngine.SimulationEnd(draft);

        var currencies = allAccounts.ToDictionary(a => a.Id, a => a.Currency);
        var (flows, scheduledExpenses) = await ScheduledFlowsAsync(today, end, currencies, baseCurrency, table, ct);
        var variable = await VariableSpendingAsync(user, today, end, scheduledExpenses, baseCurrency, table, ct);
        var input = draft with { Flows = flows, VariableSpending = variable };
        var baseline = ForecastEngine.Run(input);

        ForecastScenarioResponse? scenario = null;
        if (oneOffs.Count > 0)
        {
            var whatIf = oneOffs.Select(o => new ForecastFlow(o.Date!.Value, o.AccountId!.Value, o.Amount, FlowKind.WhatIf, Label: o.Label));
            var result = ForecastEngine.Run(input with { Flows = [.. flows, .. whatIf] });
            scenario = new ForecastScenarioResponse(oneOffs, result.Total, result.Alarms, result.Goals,
                (result.Total.LastOrDefault()?.Balance ?? 0) - (baseline.Total.LastOrDefault()?.Balance ?? 0));
        }

        return new ForecastResponse(
            today, from, to, input.Granularity, baseCurrency.Code, now.UtcDateTime, input.SpendingAccountId, user.LowBalanceThreshold,
            baseline.Accounts, baseline.Total, baseline.Alarms, baseline.Goals,
            variable.Where(m => m.Start <= to)
                .Select(m => new VariableSpendingResponse(m.Month.ToString(), m.Start, m.End, m.Total, m.Source))
                .ToList(),
            scenario);
    }

    /// <summary>The default spending account, else the first open debit card or cash account in totals.</summary>
    private static Guid? SpendingAccount(User user, IReadOnlyList<Account> all, IReadOnlyList<Account> simulated)
    {
        if (user.DefaultSpendingAccountId is { } id && simulated.Any(a => a.Id == id))
        {
            return id;
        }

        return all.FirstOrDefault(a => a is { IncludeInTotals: true, IsArchived: false, Type: AccountType.DebitCard or AccountType.Cash })?.Id;
    }

    private async Task<List<ForecastGoal>> ForecastGoalsAsync(
        IReadOnlyList<Domain.Goals.SavingsGoal> openGoals, User user, DateOnly today, CancellationToken ct)
    {
        var progress = await goals.ProgressAsync(openGoals, today, FinancialMonth.Containing(today, user.FirstDayOfMonth), user.FirstDayOfMonth, ct);
        return openGoals
            .Select(g => new ForecastGoal(g.Id, g.TargetAmount, g.Currency, g.TargetDate, g.LinkedAccountId, progress[g.Id].Current))
            .ToList();
    }

    /// <summary>
    /// Cleared transactions dated after today, Planned transactions, and occurrences of active rules that are not
    /// materialized yet (an occurrence with a transaction in any status — even deleted — is already accounted for).
    /// </summary>
    private async Task<(List<ForecastFlow> Flows, List<ScheduledExpense> Expenses)> ScheduledFlowsAsync(
        DateOnly today, DateOnly end, Dictionary<Guid, string> currencies, Currency baseCurrency, ExchangeRateTable table, CancellationToken ct)
    {
        var future = await db.Transactions.AsNoTracking()
            .Where(t => t.Status == TransactionStatus.Cleared && t.Date > today && t.Date <= end)
            .ToListAsync(ct);
        var planned = await db.Transactions.AsNoTracking()
            .Where(t => t.Status == TransactionStatus.Planned && t.Date <= end)
            .ToListAsync(ct);

        var rules = await db.RecurringRules.AsNoTracking().Where(r => r.IsActive).ToListAsync(ct);
        var ruleIds = rules.Select(r => r.Id).ToList();
        var materialized = (await db.Transactions
                .IgnoreQueryFilters([QueryFilters.SoftDelete])
                .Where(t => t.RecurringRuleId != null && ruleIds.Contains(t.RecurringRuleId.Value) && t.RecurrenceDate >= today)
                .Select(t => new { Rule = t.RecurringRuleId!.Value, Date = t.RecurrenceDate!.Value })
                .ToListAsync(ct))
            .Select(x => (x.Rule, x.Date))
            .ToHashSet();
        var occurrences = rules
            .SelectMany(r => r.Schedule.Occurrences(today, end).Where(d => !materialized.Contains((r.Id, d))).Select(r.Materialize))
            .ToList();

        var all = future.Select(t => (t, FlowKind.Scheduled))
            .Concat(planned.Select(t => (t, FlowKind.Planned)))
            .Concat(occurrences.Select(t => (t, FlowKind.Recurring)))
            .ToList();

        var flows = all.SelectMany(x => ToFlows(x.t, x.Item2)).ToList();
        var expenses = all
            .Where(x => x.t is { Type: TransactionType.Expense, CategoryId: not null })
            .Select(x =>
            {
                var date = x.t.Date < today ? today : x.t.Date;
                var amount = table.Convert(new Money(x.t.Amount, Currency.FromCode(currencies[x.t.AccountId])), baseCurrency, today).Amount;
                return new ScheduledExpense(date, x.t.CategoryId!.Value, amount);
            })
            .ToList();
        return (flows, expenses);
    }

    private static IEnumerable<ForecastFlow> ToFlows(Transaction t, FlowKind kind)
    {
        switch (t.Type)
        {
            case TransactionType.Income:
                yield return new ForecastFlow(t.Date, t.AccountId, t.Amount, kind, Label: t.Note);
                break;
            case TransactionType.Expense:
                yield return new ForecastFlow(t.Date, t.AccountId, -t.Amount, kind, Label: t.Note);
                break;
            default:
                yield return new ForecastFlow(t.Date, t.AccountId, -t.Amount, kind, Label: t.Note);
                yield return new ForecastFlow(t.Date, t.ToAccountId!.Value, t.ToAmount ?? t.Amount, kind, t.SavingsGoalId, t.Note);
                break;
        }
    }

    private async Task<IReadOnlyList<VariableSpendingMonth>> VariableSpendingAsync(
        User user, DateOnly today, DateOnly end, IReadOnlyList<ScheduledExpense> scheduled, Currency baseCurrency,
        ExchangeRateTable table, CancellationToken ct)
    {
        var firstDay = user.FirstDayOfMonth;
        var current = FinancialMonth.Containing(today, firstDay);
        var last = FinancialMonth.Containing(end, firstDay);

        var (fromDay, toDay) = (current.FirstCalendarDay, last.FirstCalendarDay);
        var budgets = await db.Budgets.AsNoTracking().Where(b => b.Month >= fromDay && b.Month <= toDay).ToListAsync(ct);
        long ToBase(long amount, string currency) =>
            table.Convert(new Money(amount, Currency.FromCode(currency)), baseCurrency, today).Amount;

        IReadOnlyList<PlannerLine>? currentLines = null;
        if (budgets.FirstOrDefault(b => b.Period == current) is { } currentBudget)
        {
            var summary = await budgetSummaries.GetAsync(current, ct);
            currentLines = summary.Lines.Select(l => new PlannerLine(l.CategoryId, ToBase(l.Remaining, currentBudget.Currency))).ToList();
        }

        var futureIds = budgets.Where(b => b.Period > current).Select(b => b.Id).ToList();
        var futureLines = (await db.BudgetLines.AsNoTracking().Where(l => futureIds.Contains(l.BudgetId)).ToListAsync(ct)).ToLookup(l => l.BudgetId);
        var future = budgets
            .Where(b => b.Period > current)
            .ToDictionary(
                b => b.Period,
                b => (IReadOnlyList<PlannerLine>)futureLines[b.Id].Select(l => new PlannerLine(l.CategoryId, ToBase(l.PlannedAmount, b.Currency))).ToList());

        // Full months of history, only after the user's first transaction (a half-used month would drag the median down).
        var firstActivity = await spending.FirstActivityAsync(ct);
        var historyMonths = Enumerable.Range(1, HistoryMonths)
            .Select(i => current.AddMonths(-i))
            .Where(m => firstActivity is { } first && m.Start(firstDay) >= first)
            .ToList();
        var historyStart = historyMonths.Count > 0 ? historyMonths.Min().Start(firstDay) : current.Start(firstDay);
        var flows = (await spending.FlowsAsync(historyStart, today, ct, excludeRecurring: true))
            .Where(f => f.Type == TransactionType.Expense)
            .ToList();
        var byMonth = flows.ToLookup(f => FinancialMonth.Containing(f.Date, firstDay));
        var history = historyMonths
            .Select(m => (IReadOnlyDictionary<Guid, long>)SpendingQueries.Sum(byMonth[m], f => f.CategoryId, f => f.Money, f => f.Date, baseCurrency, table))
            .ToList();
        var spentThisMonth = SpendingQueries.Sum(byMonth[current], f => f.CategoryId, f => f.Money, f => f.Date, baseCurrency, table);

        var parents = await db.Categories.AsNoTracking().IgnoreQueryFilters([QueryFilters.SoftDelete]).ToDictionaryAsync(c => c.Id, c => c.ParentId, ct);
        return VariableSpendingPlanner.Plan(new SpendingPlannerInput(
            today, end, firstDay, currentLines, future, history, spentThisMonth, scheduled, parents));
    }

    private static void Validate(DateOnly today, DateOnly from, DateOnly to, IReadOnlyList<ForecastOneOff> oneOffs)
    {
        var failures = new List<ValidationFailure>();
        if (to < from)
        {
            failures.Add(new ValidationFailure("to", "The forecast cannot end before it starts (it starts today at the earliest)."));
        }

        if (to > ForecastEngine.MaxEnd(today))
        {
            failures.Add(new ValidationFailure("to", $"The horizon is at most {ForecastEngine.MaxHorizonMonths} months.") { ErrorCode = "horizon_too_long" });
        }

        for (var i = 0; i < oneOffs.Count; i++)
        {
            if (oneOffs[i].Date is { } date && (date < today || date > to))
            {
                failures.Add(new ValidationFailure($"extraOneOffs[{i}].date", "The operation must fall inside the forecast."));
            }
        }

        if (failures.Count > 0)
        {
            throw new ValidationException(failures);
        }
    }
}
