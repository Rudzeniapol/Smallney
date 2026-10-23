import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/money/currency.dart';
import '../../core/money/exchange.dart';
import '../../core/money/money.dart';
import '../../core/time/clock.dart';
import '../../core/time/dates.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';

part 'data.g.dart';

@riverpod
Stream<SettingsRow?> settings(Ref ref) => ref.watch(settingsRepositoryProvider).watch();

@riverpod
Stream<List<AccountWithBalance>> accounts(Ref ref, {bool includeArchived = false}) =>
    ref.watch(accountsRepositoryProvider).watchAll(includeArchived: includeArchived);

@riverpod
Stream<Map<String, CategoryRow>> categoriesById(Ref ref) => ref.watch(categoriesRepositoryProvider).watchById();

@riverpod
Stream<String?> lastSyncAt(Ref ref) => ref.watch(databaseProvider).watchValue('sync.lastSuccessAt');

@riverpod
Stream<List<OutboxRow>> outbox(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.outbox).watch();
}

/// Total of the accounts included in totals, in the base currency at the latest cached rates.
class Capital {
  const Capital(this.total, this.missingRates);

  final Money total;

  /// Currencies without a cached rate (their accounts are left out of the total).
  final Set<String> missingRates;
}

@riverpod
Capital? capital(Ref ref) {
  final settings = ref.watch(settingsProvider).value;
  final accounts = ref.watch(accountsProvider()).value;
  final rates = ref.watch(exchangeRatesProvider).value ?? ExchangeRates.empty;
  if (settings == null || accounts == null) return null;
  final base = settings.baseCurrency;
  var total = Money.zero(base);
  final missing = <String>{};
  for (final a in accounts.where((a) => a.account.includeInTotals)) {
    final converted = rates.convert(a.money, base);
    if (converted == null) {
      missing.add(a.account.currency);
    } else {
      total += converted;
    }
  }
  return Capital(total, missing);
}

/// The current financial month and its bounds.
class MonthWindow {
  const MonthWindow(this.month, this.start, this.end);

  final FinancialMonth month;
  final DateTime start;
  final DateTime end;
}

@riverpod
MonthWindow currentMonth(Ref ref) {
  final firstDay = ref.watch(settingsProvider).value?.firstDayOfMonth ?? 1;
  final today = ref.watch(clockProvider).today();
  final month = FinancialMonth.containing(today, firstDay);
  return MonthWindow(month, month.start(firstDay), month.end(firstDay));
}

String baseCurrencyOf(Ref ref) => ref.watch(settingsProvider).value?.baseCurrency ?? Currency.baseCode;
