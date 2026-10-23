/// Enums use the server's wire names ("DebitCard"), so they round-trip through sync unchanged.
abstract interface class WireEnum {
  String get wire;
}

T parseWire<T extends WireEnum>(List<T> values, String wire) =>
    values.firstWhere((v) => v.wire.toLowerCase() == wire.toLowerCase(),
        orElse: () => throw FormatException('Unknown value "$wire"'));

enum AccountType implements WireEnum {
  cash('Cash'),
  debitCard('DebitCard'),
  creditCard('CreditCard'),
  savings('Savings'),
  deposit('Deposit'),
  investment('Investment');

  const AccountType(this.wire);

  @override
  final String wire;

  bool get supportsInterest => this == savings || this == deposit;
}

enum CapitalizationPeriod implements WireEnum {
  none('None'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  atEnd('AtEnd');

  const CapitalizationPeriod(this.wire);

  @override
  final String wire;
}

enum CategoryKind implements WireEnum {
  income('Income'),
  expense('Expense');

  const CategoryKind(this.wire);

  @override
  final String wire;
}

enum TransactionType implements WireEnum {
  income('Income'),
  expense('Expense'),
  transfer('Transfer');

  const TransactionType(this.wire);

  @override
  final String wire;

  CategoryKind? get categoryKind => switch (this) {
        income => CategoryKind.income,
        expense => CategoryKind.expense,
        transfer => null,
      };
}

enum TransactionStatus implements WireEnum {
  cleared('Cleared'),
  planned('Planned'),
  skipped('Skipped');

  const TransactionStatus(this.wire);

  @override
  final String wire;
}

enum Frequency implements WireEnum {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const Frequency(this.wire);

  @override
  final String wire;
}

/// Entity types of the sync protocol (docs/sync.md).
enum SyncEntity implements WireEnum {
  settings('settings'),
  account('account'),
  category('category'),
  savingsGoal('savingsGoal'),
  recurringRule('recurringRule'),
  budget('budget'),
  budgetLine('budgetLine'),
  budgetGoalAllocation('budgetGoalAllocation'),
  transaction('transaction');

  const SyncEntity(this.wire);

  @override
  final String wire;
}

enum SyncOperation implements WireEnum {
  upsert('Upsert'),
  delete('Delete');

  const SyncOperation(this.wire);

  @override
  final String wire;
}
