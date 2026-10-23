import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/currency.dart';
import '../../core/money/exchange.dart';
import '../../core/money/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/time/clock.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/db/app_database.dart';
import '../../data/model/enums.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../common/data.dart';
import '../common/transaction_tile.dart';
import '../quick_add/pickers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();
  bool _thisMonth = true;
  String? _accountId;
  final Set<TransactionType> _types = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  TransactionQuery _query(MonthWindow month) => TransactionQuery(
        from: _thisMonth ? month.start : null,
        to: _thisMonth ? month.end : null,
        accountId: _accountId,
        types: {..._types},
        search: _search.text,
      );

  void _toggle(TransactionType type) => setState(() => _types.contains(type) ? _types.remove(type) : _types.add(type));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final month = ref.watch(currentMonthProvider);
    final today = ref.watch(clockProvider).today();
    final accountsList = ref.watch(accountsProvider(includeArchived: true)).value ?? const <AccountWithBalance>[];
    final accounts = {for (final a in accountsList) a.account.id: a.account};
    final categories = ref.watch(categoriesByIdProvider).value ?? const <String, CategoryRow>{};
    final query = _query(month);
    final items = ref.watch(_transactionsProvider(query)).value;
    final monthName = DateText.monthName(context, month.start);

    final groups = <DateTime, List<TransactionRow>>{};
    for (final t in items ?? const <TransactionRow>[]) {
      groups.putIfAbsent(t.date, () => []).add(t);
    }

    return GlowBackground(
      child: RefreshIndicator(
        onRefresh: () => ref.read(syncSchedulerProvider).syncNow(),
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 16, 20, 0),
            sliver: SliverList.list(children: [
              Text(l10n.tabTransactions, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: Padding(padding: const EdgeInsets.all(13), child: AppIcon('search', size: 20, color: c.textSecondary)),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(children: [
                  ChoiceButton(
                    label: _thisMonth ? monthName : l10n.allTime,
                    selected: _thisMonth,
                    onTap: () => setState(() => _thisMonth = !_thisMonth),
                  ),
                  const SizedBox(width: 8),
                  ChoiceButton(
                    label: accounts[_accountId]?.name ?? l10n.allAccounts,
                    selected: _accountId != null,
                    onTap: () async {
                      if (_accountId != null) return setState(() => _accountId = null);
                      final id = await pickAccount(context, accountsList.where((a) => !a.account.isArchived).toList());
                      if (id != null) setState(() => _accountId = id);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceButton(label: l10n.expenses, selected: _types.contains(TransactionType.expense), onTap: () => _toggle(TransactionType.expense)),
                  const SizedBox(width: 8),
                  ChoiceButton(label: l10n.incomes, selected: _types.contains(TransactionType.income), onTap: () => _toggle(TransactionType.income)),
                  const SizedBox(width: 8),
                  ChoiceButton(label: l10n.transfers, selected: _types.contains(TransactionType.transfer), onTap: () => _toggle(TransactionType.transfer)),
                ]),
              ),
              if (_thisMonth) ...[
                const SizedBox(height: 16),
                _Totals(month: month, accountId: _accountId, periodLabel: monthName.toLowerCase()),
              ],
              const SizedBox(height: 8),
            ]),
          ),
          if (items != null && items.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: 'list',
                title: _search.text.isEmpty && _types.isEmpty && _accountId == null ? l10n.noTransactionsYet : l10n.nothingFound,
                message: _search.text.isEmpty ? l10n.noTransactionsHint : null,
              ),
            ),
          for (final entry in groups.entries)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList.list(children: [
                _DayHeader(date: entry.key, today: today, items: entry.value, accounts: accounts),
                const SizedBox(height: 8),
                for (final t in entry.value) ...[
                  _SwipeActions(
                    transaction: t,
                    child: TransactionTile(
                      transaction: t,
                      accounts: accounts,
                      categories: categories,
                      onTap: () => context.push('/transactions/${t.id}'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ]),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ]),
      ),
    );
  }
}

final _transactionsProvider = StreamProvider.autoDispose.family<List<TransactionRow>, TransactionQuery>(
  (ref, query) => ref.watch(transactionsRepositoryProvider).watch(query),
);

/// Income and spending of the month in the base currency.
class _Totals extends ConsumerWidget {
  const _Totals({required this.month, required this.accountId, required this.periodLabel});

  final MonthWindow month;
  final String? accountId;
  final String periodLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final base = ref.watch(settingsProvider).value?.baseCurrency ?? Currency.baseCode;
    final rates = ref.watch(exchangeRatesProvider).value ?? ExchangeRates.empty;
    final totals = ref.watch(_totalsProvider((month.start, month.end, accountId))).value;

    Money sum(Map<String, int> byCurrency) => byCurrency.entries.fold(
          Money.zero(base),
          (total, e) => total + (rates.convert(Money.of(e.value, e.key), base) ?? Money.zero(base)),
        );

    Widget card(String label, String amount, Color color) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.25)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.04)],
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color == AppColors.dollar ? c.income : c.expenseAccent)),
              ),
            ]),
          ),
        );

    final income = totals == null ? Money.zero(base) : sum(totals.income);
    final expense = totals == null ? Money.zero(base) : sum(totals.expense);
    return Row(children: [
      card(l10n.incomeTotal(periodLabel), context.money(income, signed: true), AppColors.dollar),
      const SizedBox(width: 10),
      card(l10n.expenseTotal(periodLabel), context.money(-expense), AppColors.coral),
    ]);
  }
}

final _totalsProvider = StreamProvider.autoDispose.family<CurrencyTotals, (DateTime, DateTime, String?)>(
  (ref, args) => ref.watch(transactionsRepositoryProvider).watchTotals(args.$1, args.$2, accountId: args.$3),
);

class _DayHeader extends ConsumerWidget {
  const _DayHeader({required this.date, required this.today, required this.items, required this.accounts});

  final DateTime date;
  final DateTime today;
  final List<TransactionRow> items;
  final Map<String, AccountRow> accounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final base = ref.watch(settingsProvider).value?.baseCurrency ?? Currency.baseCode;
    final rates = ref.watch(exchangeRatesProvider).value ?? ExchangeRates.empty;

    // Day total: cleared income minus expenses, in the base currency.
    var total = Money.zero(base);
    for (final t in items.where((t) => t.status == TransactionStatus.cleared && t.type != TransactionType.transfer)) {
      final money = rates.convert(Money.of(t.amount, accounts[t.accountId]?.currency ?? base), base) ?? Money.zero(base);
      total = t.type == TransactionType.income ? total + money : total - money;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Expanded(child: Text(DateText.dayHeader(context, date, today), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        if (!total.isZero) Text(context.money(total, signed: true), style: TextStyle(fontSize: 13, color: c.textSecondary)),
      ]),
    );
  }
}

/// Swipe left: "Повторить" (copy for today) and "Удалить" (with undo).
class _SwipeActions extends ConsumerWidget {
  const _SwipeActions({required this.transaction, required this.child});

  final TransactionRow transaction;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repository = ref.read(transactionsRepositoryProvider);

    Widget action(String icon, String label, Color color, VoidCallback onTap) => CustomSlidableAction(
          onPressed: (_) => onTap(),
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AppIcon(icon, size: 20, color: Colors.white),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.42,
          children: [
            action('copy', l10n.duplicate, AppColors.ink, () async {
              await repository.duplicate(transaction.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.transactionDuplicated)));
              }
            }),
            action('trash', l10n.delete, const Color(0xFFE2574C), () async {
              final draft = TransactionDraft.of(transaction);
              await repository.delete(transaction.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.transactionDeleted),
                // A new id: the server may already hold the deletion of the old one, and deletion wins.
                action: SnackBarAction(label: l10n.cancel, onPressed: () => repository.create(draft.withoutRecurrence())),
              ));
            }),
          ],
        ),
        child: child,
      ),
    );
  }
}
