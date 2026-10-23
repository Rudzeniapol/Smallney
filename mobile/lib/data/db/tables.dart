import 'package:drift/drift.dart';

import '../model/enums.dart';
import 'converters.dart';

/// Server bookkeeping of synced rows. [version] is null until the server has accepted the row.
mixin Synced on Table {
  IntColumn get version => integer().nullable()();
}

@DataClassName('AccountRow')
class Accounts extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<AccountType>()();
  TextColumn get currency => text()();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  BoolColumn get includeInTotals => boolean().withDefault(const Constant(true))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get creditLimit => integer().nullable()();

  /// Decimal as text (a rate is not money, but floats are still avoided).
  TextColumn get interestRatePercent => text().nullable()();
  TextColumn get capitalizationPeriod => textEnum<CapitalizationPeriod>().nullable()();
  TextColumn get openDate => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get maturityDate => text().map(const DateOnlyConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryRow')
class Categories extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<CategoryKind>()();
  TextColumn get parentId => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get systemCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionRow')
@TableIndex(name: 'ix_transactions_date', columns: {#date})
@TableIndex(name: 'ix_transactions_account', columns: {#accountId})
class Transactions extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get type => textEnum<TransactionType>()();
  IntColumn get amount => integer()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get date => text().map(const DateOnlyConverter())();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get status => textEnum<TransactionStatus>()();
  TextColumn get toAccountId => text().nullable()();
  IntColumn get toAmount => integer().nullable()();
  TextColumn get savingsGoalId => text().nullable()();
  TextColumn get recurringRuleId => text().nullable()();
  TextColumn get recurrenceDate => text().map(const DateOnlyConverter()).nullable()();

  /// Local creation order, used to sort operations of the same day.
  IntColumn get createdAtUs => integer()();

  /// Note and tags lowercased in Dart: SQLite's LOWER() only folds ASCII, so Cyrillic search needs this.
  TextColumn get searchText => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RecurringRuleRow')
class RecurringRules extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get accountId => text()();
  TextColumn get type => textEnum<TransactionType>()();
  IntColumn get amount => integer()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get toAccountId => text().nullable()();
  IntColumn get toAmount => integer().nullable()();
  TextColumn get savingsGoalId => text().nullable()();
  TextColumn get frequency => textEnum<Frequency>()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  IntColumn get dayOfMonth => integer().nullable()();

  /// Server name of the weekday ("Monday").
  TextColumn get dayOfWeek => text().nullable()();
  TextColumn get startDate => text().map(const DateOnlyConverter())();
  TextColumn get endDate => text().map(const DateOnlyConverter()).nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetRow')
class Budgets extends Table with Synced {
  TextColumn get id => text()();

  /// yyyy-MM of the financial month.
  TextColumn get month => text()();
  TextColumn get currency => text()();
  IntColumn get expectedIncome => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetLineRow')
class BudgetLines extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get budgetId => text()();
  TextColumn get categoryId => text()();
  IntColumn get plannedAmount => integer().withDefault(const Constant(0))();
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetAllocationRow')
class BudgetGoalAllocations extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get budgetId => text()();
  TextColumn get savingsGoalId => text()();
  IntColumn get plannedAmount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SavingsGoalRow')
class SavingsGoals extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmount => integer()();
  TextColumn get currency => text()();
  TextColumn get targetDate => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get linkedAccountId => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get completedOn => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The single row of the signed-in user's settings (id = user id).
@DataClassName('SettingsRow')
class UserSettings extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get baseCurrency => text().withDefault(const Constant('BYN'))();
  TextColumn get timezone => text().withDefault(const Constant('Europe/Minsk'))();
  IntColumn get firstDayOfMonth => integer().withDefault(const Constant(1))();
  TextColumn get defaultSpendingAccountId => text().nullable()();
  IntColumn get lowBalanceThreshold => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Latest official rates, BYN per one unit, cached for offline totals.
@DataClassName('RateRow')
class Rates extends Table {
  TextColumn get currency => text()();

  /// Decimal as text.
  TextColumn get rate => text()();
  TextColumn get date => text().map(const DateOnlyConverter())();

  @override
  Set<Column> get primaryKey => {currency};
}

/// Local changes waiting to be pushed. Several entries per entity are possible; the latest one is sent.
@DataClassName('OutboxRow')
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();

  /// JSON payload in the push shape (null for deletes).
  TextColumn get payload => text().nullable()();

  /// UTC microseconds. Exact, because a retry must send the very same value (server idempotency).
  IntColumn get clientUpdatedAtUs => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
}

@DataClassName('KeyValueRow')
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
