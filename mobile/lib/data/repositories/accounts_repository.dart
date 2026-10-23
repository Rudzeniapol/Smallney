import 'package:drift/drift.dart';

import '../../core/ids/uuid_v7.dart';
import '../../core/money/money.dart';
import '../../core/time/clock.dart';
import '../db/app_database.dart';
import '../model/enums.dart';
import '../sync/entity_codec.dart';
import '../sync/outbox.dart';

class AccountWithBalance {
  const AccountWithBalance(this.account, this.balance);

  final AccountRow account;

  /// InitialBalance + Σ cleared transactions, minor units of the account currency.
  final int balance;

  Money get money => Money.of(balance, account.currency);
}

/// Everything the account form edits.
class AccountDraft {
  const AccountDraft({
    required this.name,
    required this.type,
    required this.currency,
    this.initialBalance = 0,
    this.includeInTotals = true,
    this.isArchived = false,
    this.sortOrder = 0,
    this.color,
    this.icon,
    this.creditLimit,
    this.interestRatePercent,
    this.capitalizationPeriod,
    this.openDate,
    this.maturityDate,
  });

  factory AccountDraft.of(AccountRow a) => AccountDraft(
        name: a.name,
        type: a.type,
        currency: a.currency,
        initialBalance: a.initialBalance,
        includeInTotals: a.includeInTotals,
        isArchived: a.isArchived,
        sortOrder: a.sortOrder,
        color: a.color,
        icon: a.icon,
        creditLimit: a.creditLimit,
        interestRatePercent: a.interestRatePercent,
        capitalizationPeriod: a.capitalizationPeriod,
        openDate: a.openDate,
        maturityDate: a.maturityDate,
      );

  AccountDraft copyWithName(String name) => AccountDraft(
        name: name,
        type: type,
        currency: currency,
        initialBalance: initialBalance,
        includeInTotals: includeInTotals,
        isArchived: isArchived,
        sortOrder: sortOrder,
        color: color,
        icon: icon,
        creditLimit: creditLimit,
        interestRatePercent: interestRatePercent,
        capitalizationPeriod: capitalizationPeriod,
        openDate: openDate,
        maturityDate: maturityDate,
      );

  final String name;
  final AccountType type;
  final String currency;
  final int initialBalance;
  final bool includeInTotals;
  final bool isArchived;
  final int sortOrder;
  final String? color;
  final String? icon;
  final int? creditLimit;
  final String? interestRatePercent;
  final CapitalizationPeriod? capitalizationPeriod;
  final DateTime? openDate;
  final DateTime? maturityDate;
}

class AccountHasTransactionsException implements Exception {
  const AccountHasTransactionsException();
}

/// Accounts with balances computed from the local database (works offline).
class AccountsRepository {
  AccountsRepository(this._db, this._clock, {this.onChange});

  final AppDatabase _db;
  final Clock _clock;
  final void Function()? onChange;

  late final _outbox = OutboxWriter(_db, _clock);

  static const _balanceSql = '''
    SELECT a.*,
      a.initial_balance
      + COALESCE((SELECT SUM(CASE t.type WHEN 'income' THEN t.amount ELSE -t.amount END)
                  FROM transactions t WHERE t.account_id = a.id AND t.status = 'cleared'), 0)
      + COALESCE((SELECT SUM(t.to_amount)
                  FROM transactions t WHERE t.to_account_id = a.id AND t.status = 'cleared'), 0) AS balance
    FROM accounts a''';

  Stream<List<AccountWithBalance>> watchAll({bool includeArchived = false}) => _db
      .customSelect(
        '$_balanceSql ${includeArchived ? '' : 'WHERE a.is_archived = 0'} ORDER BY a.sort_order, a.name COLLATE NOCASE',
        readsFrom: {_db.accounts, _db.transactions},
      )
      .watch()
      .map((rows) => rows.map(_map).toList());

  Stream<AccountWithBalance?> watchOne(String id) => _db
      .customSelect('$_balanceSql WHERE a.id = ?', variables: [Variable.withString(id)], readsFrom: {_db.accounts, _db.transactions})
      .watchSingleOrNull()
      .map((row) => row == null ? null : _map(row));

  AccountWithBalance _map(QueryRow row) => AccountWithBalance(_db.accounts.map(row.data), row.read<int>('balance'));

  Future<String> create(AccountDraft draft) async {
    final id = Ids.newId();
    await _db.transaction(() async {
      final order = await _nextSortOrder();
      await _db.into(_db.accounts).insert(_companion(id, draft, sortOrder: draft.sortOrder == 0 ? order : draft.sortOrder));
      await _enqueue(id);
    });
    onChange?.call();
    return id;
  }

  Future<void> update(String id, AccountDraft draft) async {
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(_companion(id, draft, sortOrder: draft.sortOrder));
      await _enqueue(id);
    });
    onChange?.call();
  }

  Future<void> setArchived(String id, bool archived) async {
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(AccountsCompanion(isArchived: Value(archived)));
      await _enqueue(id);
    });
    onChange?.call();
  }

  Future<bool> hasTransactions(String id) async {
    final row = await _db
        .customSelect('SELECT 1 FROM transactions WHERE account_id = ?1 OR to_account_id = ?1 LIMIT 1', variables: [Variable.withString(id)])
        .getSingleOrNull();
    return row != null;
  }

  /// Same rule as the server: an account with transactions can only be archived.
  Future<void> delete(String id) async {
    if (await hasTransactions(id)) throw const AccountHasTransactionsException();
    await _db.transaction(() async {
      await (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
      await _outbox.delete(SyncEntity.account, id);
    });
    onChange?.call();
  }

  Future<int> _nextSortOrder() async {
    final max = await (_db.selectOnly(_db.accounts)..addColumns([_db.accounts.sortOrder.max()]))
        .map((r) => r.read(_db.accounts.sortOrder.max()))
        .getSingleOrNull();
    return (max ?? 0) + 1;
  }

  Future<void> _enqueue(String id) async {
    final row = await (_db.select(_db.accounts)..where((a) => a.id.equals(id))).getSingle();
    await _outbox.upsert(SyncEntity.account, id, EntityCodec.account(row));
  }

  AccountsCompanion _companion(String id, AccountDraft d, {required int sortOrder}) => AccountsCompanion(
        id: Value(id),
        name: Value(d.name.trim()),
        type: Value(d.type),
        currency: Value(d.currency),
        initialBalance: Value(d.initialBalance),
        includeInTotals: Value(d.includeInTotals),
        isArchived: Value(d.isArchived),
        sortOrder: Value(sortOrder),
        color: Value(d.color),
        icon: Value(d.icon),
        creditLimit: Value(d.type == AccountType.creditCard ? d.creditLimit : null),
        interestRatePercent: Value(d.type.supportsInterest ? d.interestRatePercent : null),
        capitalizationPeriod: Value(d.type.supportsInterest && d.interestRatePercent != null ? d.capitalizationPeriod : null),
        openDate: Value(d.type.supportsInterest ? d.openDate : null),
        maturityDate: Value(d.type.supportsInterest ? d.maturityDate : null),
      );
}
