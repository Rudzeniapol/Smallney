import 'package:drift/drift.dart' show Value;
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smallney/core/time/dates.dart';
import 'package:smallney/data/api/dto.dart';
import 'package:smallney/data/db/app_database.dart';
import 'package:smallney/data/model/enums.dart';
import 'package:smallney/data/repositories/accounts_repository.dart';
import 'package:smallney/data/repositories/transactions_repository.dart';
import 'package:smallney/data/sync/sync_engine.dart';
import 'package:smallney/data/sync/sync_scheduler.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late FakeSyncApi api;
  late SyncEngine engine;
  late AccountsRepository accounts;
  late TransactionsRepository transactions;

  setUp(() async {
    db = memoryDb();
    clock = FixedClock(DateTime(2026, 10, 22, 12));
    api = FakeSyncApi();
    engine = SyncEngine(db, api, clock: clock);
    accounts = AccountsRepository(db, clock);
    transactions = TransactionsRepository(db, clock);
    await seedSettings(db);
  });

  tearDown(() => db.close());

  Future<List<OutboxRow>> outbox() => db.select(db.outbox).get();

  PulledChangeDto pulled(String type, String id, int version, Map<String, dynamic>? data, {bool deleted = false}) =>
      PulledChangeDto(entityType: type, id: id, version: version, deleted: deleted, updatedAt: DateTime.utc(2026, 10, 22), data: data);

  Map<String, dynamic> accountData(String name) => {'name': name, 'type': 'Cash', 'currency': 'BYN', 'initialBalance': 100};

  group('push', () {
    test('sends only the latest change per entity with its stored timestamp', () async {
      final id = await accounts.create(const AccountDraft(name: 'Первое', type: AccountType.cash, currency: 'BYN'));
      clock.advance(const Duration(seconds: 1));
      final row = (await accounts.watchOne(id).first)!.account;
      await accounts.update(id, AccountDraft.of(row).copyWithName('Второе'));
      final latest = (await outbox()).last;

      await engine.run();

      final sent = api.pushes.single.single;
      expect(sent.id, id);
      expect(sent.payload!['name'], 'Второе');
      expect(sent.clientUpdatedAt, DateTime.fromMicrosecondsSinceEpoch(latest.clientUpdatedAtUs, isUtc: true));
      expect(await outbox(), isEmpty);
      expect((await accounts.watchOne(id).first)!.account.version, isNotNull, reason: 'the accepted version is stored');
    });

    test('a change made while the push is in flight stays queued', () async {
      final id = await accounts.create(const AccountDraft(name: 'Карта', type: AccountType.cash, currency: 'BYN'));
      api.onPush = (changes) {
        // The user edits the account while the request is on the wire.
        db.into(db.outbox).insert(OutboxCompanion.insert(
              entityType: 'account',
              entityId: id,
              operation: 'Upsert',
              payload: Value(jsonEncode(accountData('Позже'))),
              clientUpdatedAtUs: DateTime(2030).microsecondsSinceEpoch,
            ));
        return PushResponseDto(accepted: [
          for (final c in changes) AcceptedChangeDto(entityType: c.entityType, id: c.id, operation: c.operation, version: 5, status: 'Applied'),
        ]);
      };

      await engine.run();

      final remaining = await outbox();
      expect(remaining, hasLength(1));
      expect(jsonDecode(remaining.single.payload!), containsPair('name', 'Позже'));
    });

    test('rejections are recorded and retried; entity_deleted removes the local copy', () async {
      final kept = await accounts.create(const AccountDraft(name: 'Отклонён', type: AccountType.cash, currency: 'BYN'));
      final gone = await accounts.create(const AccountDraft(name: 'Удалён на сервере', type: AccountType.cash, currency: 'BYN'));
      api.onPush = (changes) => PushResponseDto(rejected: [
            RejectedChangeDto(entityType: 'account', id: kept, operation: 'Upsert', code: 'validation_failed', message: 'name'),
            RejectedChangeDto(entityType: 'account', id: gone, operation: 'Upsert', code: 'entity_deleted', message: 'deleted'),
          ]);

      final report = await engine.run();

      expect(report.rejected, 1);
      final failed = (await outbox()).single;
      expect(failed.entityId, kept);
      expect(failed.errorCode, 'validation_failed');
      expect(failed.attempts, 1);
      expect(await accounts.watchOne(gone).first, isNull);

      api.onPush = null;
      await engine.run();
      expect(api.pushes.last.single.id, kept, reason: 'rejected changes are sent again');
      expect(await outbox(), isEmpty);
    });

    test('nothing to push means no push request', () async {
      await engine.run();
      expect(api.pushes, isEmpty);
    });
  });

  group('pull', () {
    test('applies pages until hasMore is false and stores the cursor', () async {
      api.pullPages.addAll([
        PullResponseDto(changes: [pulled('account', 'a1', 3, accountData('Наличные'))], nextCursor: 3, hasMore: true),
        PullResponseDto(changes: [
          pulled('category', 'c1', 4, {'name': 'Кафе', 'kind': 'Expense', 'icon': 'cafe', 'systemCode': null}),
          pulled('settings', 'user-1', 5, {'email': 'me@test.by', 'baseCurrency': 'USD', 'timezone': 'Europe/Minsk', 'firstDayOfMonth': 5, 'lowBalanceThreshold': 0}),
        ], nextCursor: 5, hasMore: false),
      ]);

      final report = await engine.run();

      expect(report.pulled, 3);
      expect(api.pullCalls, [0, 3]);
      expect(await db.getValue(SyncEngine.cursorKey), '5');
      final account = (await accounts.watchOne('a1').first)!;
      expect(account.account.type, AccountType.cash);
      expect(account.account.version, 3);
      expect((await db.select(db.categories).getSingle()).kind, CategoryKind.expense);
      expect((await db.select(db.userSettings).getSingle()).firstDayOfMonth, 5);

      await engine.run();
      expect(api.pullCalls.last, 5, reason: 'the next sync continues from the cursor');
    });

    test('transactions from the server are stored with their fields', () async {
      api.pullPages.add(PullResponseDto(changes: [
        pulled('transaction', '0190a5d2-ac96-774b-bcce-b302099a8057', 7, {
          'accountId': 'a1',
          'type': 'Expense',
          'amount': 2450,
          'categoryId': 'c1',
          'date': '2026-10-22',
          'note': 'Кофе',
          'tags': ['утро'],
          'status': 'Planned',
          'recurringRuleId': 'r1',
          'recurrenceDate': '2026-10-22',
        }),
      ], nextCursor: 7, hasMore: false));

      await engine.run();

      final t = await db.select(db.transactions).getSingle();
      expect(t.amount, 2450);
      expect(t.status, TransactionStatus.planned);
      expect(t.tags, ['утро']);
      expect(t.recurrenceDate, Dates.of(2026, 10, 22));
      expect(t.searchText, contains('кофе'));
    });

    test('deletions remove local rows', () async {
      api.pullPages.addAll([
        PullResponseDto(changes: [pulled('account', 'a1', 3, accountData('Наличные'))], nextCursor: 3, hasMore: false),
        PullResponseDto(changes: [pulled('account', 'a1', 9, null, deleted: true)], nextCursor: 9, hasMore: false),
      ]);

      await engine.run();
      await engine.run();

      expect(await accounts.watchAll(includeArchived: true).first, isEmpty);
    });

    test('a pulled change never overwrites an unsent local edit', () async {
      final id = await accounts.create(const AccountDraft(name: 'Локальное', type: AccountType.cash, currency: 'BYN'));
      api.onPush = (_) => const PushResponseDto(rejected: []); // the server does not answer for it (e.g. timeout semantics)
      api.pullPages.add(PullResponseDto(changes: [pulled('account', id, 50, accountData('С сервера'))], nextCursor: 50, hasMore: false));

      await engine.run();

      expect((await accounts.watchOne(id).first)!.account.name, 'Локальное');
    });

    test('unknown entity types from a newer server are ignored', () async {
      api.pullPages.add(PullResponseDto(changes: [pulled('categorizationRule', 'x', 2, {'pattern': 'кофе'})], nextCursor: 2, hasMore: false));
      await engine.run();
      expect(await db.getValue(SyncEngine.cursorKey), '2');
    });
  });

  group('rates and runs', () {
    test('rates are cached and refreshed only when stale', () async {
      await engine.run();
      await engine.run();
      expect(api.ratesCalls, 1);
      expect((await db.select(db.rates).getSingle()).rate, '3.0');

      clock.advance(const Duration(hours: 7));
      await engine.run();
      expect(api.ratesCalls, 2);
    });

    test('concurrent runs share one round', () async {
      await Future.wait([engine.run(), engine.run(), engine.run()]);
      expect(api.pullCalls, hasLength(1));
    });

    test('discarding a rejected local-only create deletes it and resyncs from zero', () async {
      final id = await accounts.create(const AccountDraft(name: 'Новый', type: AccountType.cash, currency: 'BYN'));
      api.onPush = (_) => PushResponseDto(rejected: [RejectedChangeDto(entityType: 'account', id: id, code: 'invalid', message: 'x')]);
      await engine.run();
      await db.setValue(SyncEngine.cursorKey, '40');

      await engine.discardRejected((await outbox()).single);

      expect(await outbox(), isEmpty);
      expect(await accounts.watchOne(id).first, isNull);
      expect(await db.getValue(SyncEngine.cursorKey), '0');
    });

    test('the last successful sync time is recorded', () async {
      await engine.run();
      expect(await db.getValue(SyncEngine.lastSyncKey), clock.value.toUtc().toIso8601String());
    });
  });

  test('backoff doubles up to five minutes', () {
    expect(backoffDelay(1), const Duration(seconds: 2));
    expect(backoffDelay(2), const Duration(seconds: 4));
    expect(backoffDelay(5), const Duration(seconds: 32));
    expect(backoffDelay(20), const Duration(minutes: 5));
  });

  test('transactions pushed through the repository keep server field names', () async {
    final card = await accounts.create(const AccountDraft(name: 'Карта', type: AccountType.debitCard, currency: 'BYN'));
    final cash = await accounts.create(const AccountDraft(name: 'Наличные', type: AccountType.cash, currency: 'BYN'));
    await transactions.create(TransactionDraft(type: TransactionType.transfer, accountId: card, toAccountId: cash, amount: 500, date: Dates.of(2026, 10, 22)));

    await engine.run();

    final transfer = api.pushes.single.firstWhere((c) => c.entityType == 'transaction');
    expect(transfer.payload, containsPair('type', 'Transfer'));
    expect(transfer.payload, containsPair('toAccountId', cash));
    expect(transfer.payload, containsPair('toAmount', 500));
    expect(transfer.payload, containsPair('categoryId', null));
  });
}
