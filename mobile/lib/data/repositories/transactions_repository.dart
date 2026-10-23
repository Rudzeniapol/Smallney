import 'package:drift/drift.dart';

import '../../core/ids/uuid_v7.dart';
import '../../core/time/clock.dart';
import '../db/app_database.dart';
import '../model/enums.dart';
import '../sync/entity_codec.dart';
import '../sync/outbox.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.accountId,
    required this.amount,
    required this.date,
    this.categoryId,
    this.note,
    this.tags = const [],
    this.status = TransactionStatus.cleared,
    this.toAccountId,
    this.toAmount,
    this.savingsGoalId,
    this.recurringRuleId,
    this.recurrenceDate,
  });

  factory TransactionDraft.of(TransactionRow t) => TransactionDraft(
        type: t.type,
        accountId: t.accountId,
        amount: t.amount,
        date: t.date,
        categoryId: t.categoryId,
        note: t.note,
        tags: t.tags,
        status: t.status,
        toAccountId: t.toAccountId,
        toAmount: t.toAmount,
        savingsGoalId: t.savingsGoalId,
        recurringRuleId: t.recurringRuleId,
        recurrenceDate: t.recurrenceDate,
      );

  /// The same operation, detached from its recurring rule occurrence (one transaction per occurrence on the server).
  TransactionDraft withoutRecurrence() => TransactionDraft(
        type: type,
        accountId: accountId,
        amount: amount,
        date: date,
        categoryId: categoryId,
        note: note,
        tags: tags,
        status: status,
        toAccountId: toAccountId,
        toAmount: toAmount,
        savingsGoalId: savingsGoalId,
      );

  final TransactionType type;
  final String accountId;

  /// Positive, minor units of the account currency.
  final int amount;
  final DateTime date;
  final String? categoryId;
  final String? note;
  final List<String> tags;
  final TransactionStatus status;
  final String? toAccountId;
  final int? toAmount;
  final String? savingsGoalId;
  final String? recurringRuleId;
  final DateTime? recurrenceDate;
}

class TransactionQuery {
  const TransactionQuery({this.from, this.to, this.accountId, this.types = const {}, this.search, this.limit});

  final DateTime? from;
  final DateTime? to;
  final String? accountId;
  final Set<TransactionType> types;

  /// Substring of the note or a tag, case-insensitive.
  final String? search;
  final int? limit;

  // Value equality: queries are provider family keys.
  @override
  bool operator ==(Object other) =>
      other is TransactionQuery &&
      other.from == from &&
      other.to == to &&
      other.accountId == accountId &&
      other.types.length == types.length &&
      other.types.containsAll(types) &&
      other.search == search &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(from, to, accountId, Object.hashAllUnordered(types), search, limit);
}

/// Income and expense of a period, per currency (converted to the base currency by the caller).
class CurrencyTotals {
  const CurrencyTotals(this.income, this.expense);

  final Map<String, int> income;
  final Map<String, int> expense;
}

class TransactionsRepository {
  TransactionsRepository(this._db, this._clock, {this.onChange});

  final AppDatabase _db;
  final Clock _clock;
  final void Function()? onChange;

  late final _outbox = OutboxWriter(_db, _clock);

  Stream<List<TransactionRow>> watch(TransactionQuery q) {
    final query = _db.select(_db.transactions)
      ..where((t) {
        Expression<bool> e = t.status.equalsValue(TransactionStatus.skipped).not();
        if (q.from != null) e = e & t.date.isBiggerOrEqualValue(_iso(q.from!));
        if (q.to != null) e = e & t.date.isSmallerOrEqualValue(_iso(q.to!));
        if (q.accountId != null) e = e & (t.accountId.equals(q.accountId!) | t.toAccountId.equals(q.accountId!));
        if (q.types.isNotEmpty) e = e & t.type.isInValues(q.types);
        if (q.search != null && q.search!.trim().isNotEmpty) {
          e = e & t.searchText.like('%${q.search!.trim().toLowerCase()}%');
        }
        return e;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.createdAtUs)]);
    if (q.limit != null) query.limit(q.limit!);
    return query.watch();
  }

  Stream<TransactionRow?> watchOne(String id) => (_db.select(_db.transactions)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Cleared income and expense in [from, to] by account currency.
  Stream<CurrencyTotals> watchTotals(DateTime from, DateTime to, {String? accountId}) => _db
      .customSelect(
        '''
        SELECT t.type AS type, a.currency AS currency, SUM(t.amount) AS total
        FROM transactions t JOIN accounts a ON a.id = t.account_id
        WHERE t.status = 'cleared' AND t.type IN ('income', 'expense') AND t.date >= ?1 AND t.date <= ?2
          ${accountId == null ? '' : 'AND t.account_id = ?3'}
        GROUP BY t.type, a.currency
        ''',
        variables: [Variable.withString(_iso(from)), Variable.withString(_iso(to)), if (accountId != null) Variable.withString(accountId)],
        readsFrom: {_db.transactions, _db.accounts},
      )
      .watch()
      .map((rows) {
        final income = <String, int>{};
        final expense = <String, int>{};
        for (final r in rows) {
          (r.read<String>('type') == 'income' ? income : expense)[r.read<String>('currency')] = r.read<int>('total');
        }
        return CurrencyTotals(income, expense);
      });

  Future<String> create(TransactionDraft draft, {String? id}) async {
    final newId = id ?? Ids.newId();
    await _db.transaction(() async {
      await _db.into(_db.transactions).insert(_companion(newId, draft, createdAtUs: _clock.now().toUtc().microsecondsSinceEpoch));
      await _enqueue(newId);
    });
    onChange?.call();
    return newId;
  }

  Future<void> update(String id, TransactionDraft draft) async {
    await _db.transaction(() async {
      final existing = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingle();
      await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(_companion(id, draft, createdAtUs: existing.createdAtUs));
      await _enqueue(id);
    });
    onChange?.call();
  }

  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
      await _outbox.delete(SyncEntity.transaction, id);
    });
    onChange?.call();
  }

  /// Repeats a transaction today (swipe → "Повторить").
  Future<String> duplicate(String id) async {
    final source = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingle();
    final draft = TransactionDraft.of(source);
    return create(TransactionDraft(
      type: draft.type,
      accountId: draft.accountId,
      amount: draft.amount,
      date: _clock.today(),
      categoryId: draft.categoryId,
      note: draft.note,
      tags: draft.tags,
      toAccountId: draft.toAccountId,
      toAmount: draft.toAmount,
      savingsGoalId: draft.savingsGoalId,
    ));
  }

  Future<void> _enqueue(String id) async {
    final row = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingle();
    await _outbox.upsert(SyncEntity.transaction, id, EntityCodec.transaction(row));
  }

  static String _iso(DateTime d) => const DateOnlyIso().format(d);

  TransactionsCompanion _companion(String id, TransactionDraft d, {required int createdAtUs}) {
    final transfer = d.type == TransactionType.transfer;
    final note = d.note == null || d.note!.trim().isEmpty ? null : d.note!.trim();
    final tags = _normalizeTags(d.tags);
    return TransactionsCompanion(
      id: Value(id),
      accountId: Value(d.accountId),
      type: Value(d.type),
      amount: Value(d.amount),
      categoryId: Value(transfer ? null : d.categoryId),
      date: Value(d.date),
      note: Value(note),
      tags: Value(tags),
      searchText: Value(searchTextOf(note, tags)),
      status: Value(d.status),
      toAccountId: Value(transfer ? d.toAccountId : null),
      toAmount: Value(transfer ? (d.toAmount ?? d.amount) : null),
      savingsGoalId: Value(transfer ? d.savingsGoalId : null),
      recurringRuleId: Value(d.recurringRuleId),
      recurrenceDate: Value(d.recurrenceDate),
      createdAtUs: Value(createdAtUs),
    );
  }

  static String searchTextOf(String? note, List<String> tags) => [note ?? '', ...tags].join(' ').toLowerCase();

  /// Same normalization as the server: trimmed, no empties, case-insensitive duplicates removed.
  static List<String> _normalizeTags(List<String> tags) {
    final seen = <String>{};
    return [
      for (final tag in tags.map((t) => t.trim()).where((t) => t.isNotEmpty))
        if (seen.add(tag.toUpperCase())) tag,
    ];
  }
}

class DateOnlyIso {
  const DateOnlyIso();

  String format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
