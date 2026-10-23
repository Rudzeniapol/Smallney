import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../model/enums.dart';
import 'converters.dart';
import 'tables.dart';

part 'app_database.drift.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    RecurringRules,
    Budgets,
    BudgetLines,
    BudgetGoalAllocations,
    SavingsGoals,
    UserSettings,
    Rates,
    Outbox,
    KeyValues,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The on-device database file.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'smallney'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = OFF'),
      );

  /// Removes everything (logout).
  Future<void> wipe() => transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });

  Future<String?> getValue(String key) async =>
      (await (select(keyValues)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setValue(String key, String? value) async {
    if (value == null) {
      await (delete(keyValues)..where((t) => t.key.equals(key))).go();
    } else {
      await into(keyValues).insertOnConflictUpdate(KeyValuesCompanion.insert(key: key, value: value));
    }
  }

  Stream<String?> watchValue(String key) =>
      (select(keyValues)..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value);
}
