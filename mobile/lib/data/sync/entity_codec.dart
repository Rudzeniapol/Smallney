import 'package:drift/drift.dart';

import '../../core/ids/uuid_v7.dart';
import '../../core/time/dates.dart';
import '../db/app_database.dart';
import '../model/enums.dart';
import '../repositories/transactions_repository.dart';

/// Converts local rows to push payloads and pulled data to rows. Field names and enum values follow the
/// server's sync contract (docs/sync.md); local enums are stored by their Dart names.
abstract final class EntityCodec {
  static String? _date(DateTime? d) => d == null ? null : Dates.iso(d);

  static DateTime? _parseDate(Object? v) => v == null ? null : Dates.parse(v as String);

  static T _enum<T extends WireEnum>(List<T> values, Object? v) => parseWire(values, v as String);

  static T? _enumOrNull<T extends WireEnum>(List<T> values, Object? v) => v == null ? null : parseWire(values, v as String);

  static List<String> _tags(Object? v) => v == null ? const [] : (v as List).map((e) => '$e').toList();

  static num? _decimal(String? text) => text == null ? null : num.parse(text);

  // ---- push payloads ----

  static Map<String, dynamic> account(AccountRow a) => {
        'name': a.name,
        'type': a.type.wire,
        'currency': a.currency,
        'initialBalance': a.initialBalance,
        'includeInTotals': a.includeInTotals,
        'isArchived': a.isArchived,
        'sortOrder': a.sortOrder,
        'color': a.color,
        'icon': a.icon,
        'creditLimit': a.creditLimit,
        'interestRatePercent': _decimal(a.interestRatePercent),
        'capitalizationPeriod': a.capitalizationPeriod?.wire,
        'openDate': _date(a.openDate),
        'maturityDate': _date(a.maturityDate),
      };

  static Map<String, dynamic> category(CategoryRow c) => {
        'name': c.name,
        'kind': c.kind.wire,
        'parentId': c.parentId,
        'icon': c.icon,
        'color': c.color,
        'isArchived': c.isArchived,
      };

  static Map<String, dynamic> transaction(TransactionRow t) => {
        'accountId': t.accountId,
        'type': t.type.wire,
        'amount': t.amount,
        'categoryId': t.categoryId,
        'date': Dates.iso(t.date),
        'note': t.note,
        'tags': t.tags,
        'status': t.status.wire,
        'toAccountId': t.toAccountId,
        'toAmount': t.toAmount,
        'savingsGoalId': t.savingsGoalId,
        'recurringRuleId': t.recurringRuleId,
        'recurrenceDate': _date(t.recurrenceDate),
      };

  static Map<String, dynamic> settings(SettingsRow s) => {
        'baseCurrency': s.baseCurrency,
        'timezone': s.timezone,
        'firstDayOfMonth': s.firstDayOfMonth,
        'defaultSpendingAccountId': s.defaultSpendingAccountId,
        'lowBalanceThreshold': s.lowBalanceThreshold,
      };

  // ---- pulled data ----

  /// Writes a pulled entity. Unknown entity types (from a newer server) are ignored.
  static Future<void> applyUpsert(AppDatabase db, String entityType, String id, int version, Map<String, dynamic> d) async {
    switch (entityType) {
      case 'account':
        await db.into(db.accounts).insertOnConflictUpdate(AccountsCompanion.insert(
              id: id,
              name: d['name'] as String,
              type: _enum(AccountType.values, d['type']),
              currency: d['currency'] as String,
              initialBalance: Value((d['initialBalance'] as num?)?.toInt() ?? 0),
              includeInTotals: Value(d['includeInTotals'] as bool? ?? true),
              isArchived: Value(d['isArchived'] as bool? ?? false),
              sortOrder: Value((d['sortOrder'] as num?)?.toInt() ?? 0),
              color: Value(d['color'] as String?),
              icon: Value(d['icon'] as String?),
              creditLimit: Value((d['creditLimit'] as num?)?.toInt()),
              interestRatePercent: Value(d['interestRatePercent']?.toString()),
              capitalizationPeriod: Value(_enumOrNull(CapitalizationPeriod.values, d['capitalizationPeriod'])),
              openDate: Value(_parseDate(d['openDate'])),
              maturityDate: Value(_parseDate(d['maturityDate'])),
              version: Value(version),
            ));
      case 'category':
        await db.into(db.categories).insertOnConflictUpdate(CategoriesCompanion.insert(
              id: id,
              name: d['name'] as String,
              kind: _enum(CategoryKind.values, d['kind']),
              parentId: Value(d['parentId'] as String?),
              icon: Value(d['icon'] as String?),
              color: Value(d['color'] as String?),
              isArchived: Value(d['isArchived'] as bool? ?? false),
              systemCode: Value(d['systemCode'] as String?),
              version: Value(version),
            ));
      case 'transaction':
        await db.into(db.transactions).insertOnConflictUpdate(TransactionsCompanion.insert(
              id: id,
              accountId: d['accountId'] as String,
              type: _enum(TransactionType.values, d['type']),
              amount: (d['amount'] as num).toInt(),
              categoryId: Value(d['categoryId'] as String?),
              date: Dates.parse(d['date'] as String),
              note: Value(d['note'] as String?),
              tags: Value(_tags(d['tags'])),
              status: _enum(TransactionStatus.values, d['status']),
              toAccountId: Value(d['toAccountId'] as String?),
              toAmount: Value((d['toAmount'] as num?)?.toInt()),
              savingsGoalId: Value(d['savingsGoalId'] as String?),
              recurringRuleId: Value(d['recurringRuleId'] as String?),
              recurrenceDate: Value(_parseDate(d['recurrenceDate'])),
              createdAtUs: Ids.timestampMs(id) * 1000,
              searchText: Value(TransactionsRepository.searchTextOf(d['note'] as String?, _tags(d['tags']))),
              version: Value(version),
            ));
      case 'recurringRule':
        await db.into(db.recurringRules).insertOnConflictUpdate(RecurringRulesCompanion.insert(
              id: id,
              name: d['name'] as String,
              accountId: d['accountId'] as String,
              type: _enum(TransactionType.values, d['type']),
              amount: (d['amount'] as num).toInt(),
              categoryId: Value(d['categoryId'] as String?),
              note: Value(d['note'] as String?),
              tags: Value(_tags(d['tags'])),
              toAccountId: Value(d['toAccountId'] as String?),
              toAmount: Value((d['toAmount'] as num?)?.toInt()),
              savingsGoalId: Value(d['savingsGoalId'] as String?),
              frequency: _enum(Frequency.values, d['frequency']),
              interval: Value((d['interval'] as num?)?.toInt() ?? 1),
              dayOfMonth: Value((d['dayOfMonth'] as num?)?.toInt()),
              dayOfWeek: Value(d['dayOfWeek'] as String?),
              startDate: Dates.parse(d['startDate'] as String),
              endDate: Value(_parseDate(d['endDate'])),
              isActive: Value(d['isActive'] as bool? ?? true),
              version: Value(version),
            ));
      case 'budget':
        await db.into(db.budgets).insertOnConflictUpdate(BudgetsCompanion.insert(
              id: id,
              month: d['month'] as String,
              currency: d['currency'] as String,
              expectedIncome: Value((d['expectedIncome'] as num?)?.toInt() ?? 0),
              version: Value(version),
            ));
      case 'budgetLine':
        await db.into(db.budgetLines).insertOnConflictUpdate(BudgetLinesCompanion.insert(
              id: id,
              budgetId: d['budgetId'] as String,
              categoryId: d['categoryId'] as String,
              plannedAmount: Value((d['plannedAmount'] as num?)?.toInt() ?? 0),
              rollover: Value(d['rollover'] as bool? ?? false),
              version: Value(version),
            ));
      case 'budgetGoalAllocation':
        await db.into(db.budgetGoalAllocations).insertOnConflictUpdate(BudgetGoalAllocationsCompanion.insert(
              id: id,
              budgetId: d['budgetId'] as String,
              savingsGoalId: d['savingsGoalId'] as String,
              plannedAmount: Value((d['plannedAmount'] as num?)?.toInt() ?? 0),
              version: Value(version),
            ));
      case 'savingsGoal':
        await db.into(db.savingsGoals).insertOnConflictUpdate(SavingsGoalsCompanion.insert(
              id: id,
              name: d['name'] as String,
              targetAmount: (d['targetAmount'] as num).toInt(),
              currency: d['currency'] as String,
              targetDate: Value(_parseDate(d['targetDate'])),
              linkedAccountId: Value(d['linkedAccountId'] as String?),
              priority: Value((d['priority'] as num?)?.toInt() ?? 0),
              isCompleted: Value(d['isCompleted'] as bool? ?? false),
              completedOn: Value(_parseDate(d['completedOn'])),
              color: Value(d['color'] as String?),
              icon: Value(d['icon'] as String?),
              version: Value(version),
            ));
      case 'settings':
        await db.into(db.userSettings).insertOnConflictUpdate(UserSettingsCompanion.insert(
              id: id,
              email: Value(d['email'] as String? ?? ''),
              baseCurrency: Value(d['baseCurrency'] as String? ?? 'BYN'),
              timezone: Value(d['timezone'] as String? ?? 'Europe/Minsk'),
              firstDayOfMonth: Value((d['firstDayOfMonth'] as num?)?.toInt() ?? 1),
              defaultSpendingAccountId: Value(d['defaultSpendingAccountId'] as String?),
              lowBalanceThreshold: Value((d['lowBalanceThreshold'] as num?)?.toInt() ?? 0),
              version: Value(version),
            ));
    }
  }

  /// Deletions are applied as hard deletes locally: the server keeps the tombstone.
  static Future<void> applyDelete(AppDatabase db, String entityType, String id) async {
    final table = _table(db, entityType);
    if (table == null) return;
    await db.customStatement('DELETE FROM ${table.actualTableName} WHERE id = ?', [id]);
  }

  static Future<void> setVersion(AppDatabase db, String entityType, String id, int version) async {
    final table = _table(db, entityType);
    if (table == null) return;
    await db.customStatement('UPDATE ${table.actualTableName} SET version = ? WHERE id = ?', [version, id]);
  }

  static TableInfo<Table, dynamic>? _table(AppDatabase db, String entityType) => switch (entityType) {
        'account' => db.accounts,
        'category' => db.categories,
        'transaction' => db.transactions,
        'recurringRule' => db.recurringRules,
        'budget' => db.budgets,
        'budgetLine' => db.budgetLines,
        'budgetGoalAllocation' => db.budgetGoalAllocations,
        'savingsGoal' => db.savingsGoals,
        'settings' => db.userSettings,
        _ => null,
      };
}
