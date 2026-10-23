import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smallney/core/time/dates.dart';
import 'package:smallney/data/db/app_database.dart';
import 'package:smallney/data/model/enums.dart';
import 'package:smallney/data/repositories/accounts_repository.dart';
import 'package:smallney/data/repositories/categories_repository.dart';
import 'package:smallney/data/repositories/settings_repository.dart';
import 'package:smallney/data/repositories/transactions_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late AccountsRepository accounts;
  late TransactionsRepository transactions;
  late int changes;

  setUp(() async {
    db = memoryDb();
    clock = FixedClock(DateTime(2026, 10, 22, 12));
    changes = 0;
    accounts = AccountsRepository(db, clock, onChange: () => changes++);
    transactions = TransactionsRepository(db, clock, onChange: () => changes++);
    await seedSettings(db);
  });

  tearDown(() => db.close());

  Future<List<OutboxRow>> outbox() => db.select(db.outbox).get();

  TransactionDraft expense(String account, int amount, {String? category, TransactionStatus status = TransactionStatus.cleared}) =>
      TransactionDraft(type: TransactionType.expense, accountId: account, amount: amount, date: Dates.of(2026, 10, 22), categoryId: category, status: status);

  group('accounts', () {
    test('create writes the row and an outbox upsert in the push shape', () async {
      final id = await accounts.create(const AccountDraft(name: '  Карта ', type: AccountType.debitCard, currency: 'BYN', initialBalance: 10000));

      final account = (await accounts.watchOne(id).first)!;
      expect(account.account.name, 'Карта');
      expect(account.balance, 10000);
      expect(changes, 1);

      final entry = (await outbox()).single;
      expect(entry.entityType, 'account');
      expect(entry.entityId, id);
      expect(entry.operation, 'Upsert');
      final payload = jsonDecode(entry.payload!) as Map<String, dynamic>;
      expect(payload['type'], 'DebitCard');
      expect(payload['initialBalance'], 10000);
      expect(payload['creditLimit'], isNull);
    });

    test('balance = initial + cleared income − expenses − transfers out + transfers in', () async {
      final card = await accounts.create(const AccountDraft(name: 'Карта', type: AccountType.debitCard, currency: 'BYN', initialBalance: 100000));
      final cash = await accounts.create(const AccountDraft(name: 'Наличные', type: AccountType.cash, currency: 'BYN', initialBalance: 5000));
      final food = await seedCategory(db, 'Продукты');
      final salary = await seedCategory(db, 'Зарплата', kind: CategoryKind.income);

      await transactions.create(TransactionDraft(type: TransactionType.income, accountId: card, amount: 250000, date: Dates.of(2026, 10, 1), categoryId: salary));
      await transactions.create(expense(card, 2450, category: food));
      await transactions.create(expense(card, 30000, category: food, status: TransactionStatus.planned));
      await transactions.create(TransactionDraft(type: TransactionType.transfer, accountId: card, toAccountId: cash, amount: 20000, date: Dates.of(2026, 10, 2)));

      final balances = {for (final a in await accounts.watchAll().first) a.account.id: a.balance};
      expect(balances[card], 100000 + 250000 - 2450 - 20000);
      expect(balances[cash], 5000 + 20000);
    });

    test('archived accounts are hidden unless asked for', () async {
      final id = await accounts.create(const AccountDraft(name: 'Старая', type: AccountType.cash, currency: 'BYN'));
      await accounts.setArchived(id, true);

      expect(await accounts.watchAll().first, isEmpty);
      expect((await accounts.watchAll(includeArchived: true).first).single.account.isArchived, isTrue);
    });

    test('an account with transactions cannot be deleted', () async {
      final id = await accounts.create(const AccountDraft(name: 'Карта', type: AccountType.debitCard, currency: 'BYN'));
      await transactions.create(expense(id, 100, category: await seedCategory(db, 'Кафе')));

      expect(() => accounts.delete(id), throwsA(isA<AccountHasTransactionsException>()));
    });

    test('delete without transactions removes it and queues a delete', () async {
      final id = await accounts.create(const AccountDraft(name: 'Лишний', type: AccountType.cash, currency: 'BYN'));
      await accounts.delete(id);

      expect(await accounts.watchAll(includeArchived: true).first, isEmpty);
      expect((await outbox()).last.operation, 'Delete');
    });

    test('type specific fields are cleared for other types', () async {
      final id = await accounts.create(const AccountDraft(
        name: 'Карта',
        type: AccountType.debitCard,
        currency: 'BYN',
        creditLimit: 100,
        interestRatePercent: '12.5',
        capitalizationPeriod: CapitalizationPeriod.monthly,
      ));
      final row = (await accounts.watchOne(id).first)!.account;
      expect(row.creditLimit, isNull);
      expect(row.interestRatePercent, isNull);
      expect(row.capitalizationPeriod, isNull);
    });
  });

  group('transactions', () {
    late String card;
    late String food;

    setUp(() async {
      card = await accounts.create(const AccountDraft(name: 'Карта', type: AccountType.debitCard, currency: 'BYN'));
      food = await seedCategory(db, 'Продукты');
      await (db.delete(db.outbox)).go();
    });

    test('create, update and delete queue the latest state', () async {
      final id = await transactions.create(TransactionDraft(
        type: TransactionType.expense,
        accountId: card,
        amount: 2450,
        date: Dates.of(2026, 10, 22),
        categoryId: food,
        note: '  Евроопт ',
        tags: const ['еда', 'Еда', ' дом '],
      ));
      final row = (await transactions.watchOne(id).first)!;
      expect(row.note, 'Евроопт');
      expect(row.tags, ['еда', 'дом']);

      await transactions.update(id, TransactionDraft.of(row).withoutRecurrence());
      await transactions.delete(id);

      final entries = await outbox();
      expect(entries.map((e) => e.operation), ['Upsert', 'Upsert', 'Delete']);
      expect(entries.map((e) => e.clientUpdatedAtUs).toSet(), hasLength(3), reason: 'strictly increasing timestamps');
      final payload = jsonDecode(entries.first.payload!) as Map<String, dynamic>;
      expect(payload, containsPair('type', 'Expense'));
      expect(payload, containsPair('date', '2026-10-22'));
      expect(payload, containsPair('status', 'Cleared'));
    });

    test('transfers drop the category and default the credited amount', () async {
      final cash = await accounts.create(const AccountDraft(name: 'Наличные', type: AccountType.cash, currency: 'BYN'));
      final id = await transactions.create(TransactionDraft(
        type: TransactionType.transfer,
        accountId: card,
        toAccountId: cash,
        amount: 500,
        date: Dates.of(2026, 10, 22),
        categoryId: food,
      ));
      final row = (await transactions.watchOne(id).first)!;
      expect(row.categoryId, isNull);
      expect(row.toAmount, 500);
    });

    test('duplicate copies the operation to today', () async {
      clock.value = DateTime(2026, 10, 25, 9);
      final id = await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 700, date: Dates.of(2026, 10, 1), categoryId: food));

      final copyId = await transactions.duplicate(id);

      final copy = (await transactions.watchOne(copyId).first)!;
      expect(copy.id, isNot(id));
      expect(copy.amount, 700);
      expect(copy.date, Dates.of(2026, 10, 25));
    });

    test('list filters by period, account, type and text; skipped are hidden', () async {
      final cash = await accounts.create(const AccountDraft(name: 'Наличные', type: AccountType.cash, currency: 'BYN'));
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 1, date: Dates.of(2026, 9, 30), categoryId: food, note: 'Гиппо'));
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: cash, amount: 2, date: Dates.of(2026, 10, 2), categoryId: food, tags: const ['отпуск']));
      await transactions.create(TransactionDraft(type: TransactionType.transfer, accountId: card, toAccountId: cash, amount: 3, date: Dates.of(2026, 10, 3)));
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 4, date: Dates.of(2026, 10, 4), categoryId: food, status: TransactionStatus.skipped));

      Future<List<int>> amounts(TransactionQuery q) async => (await transactions.watch(q).first).map((t) => t.amount).toList();

      expect(await amounts(const TransactionQuery()), [3, 2, 1]);
      expect(await amounts(TransactionQuery(from: Dates.of(2026, 10, 1), to: Dates.of(2026, 10, 31))), [3, 2]);
      expect(await amounts(TransactionQuery(accountId: cash)), [3, 2], reason: 'incoming transfers belong to the account');
      expect(await amounts(const TransactionQuery(types: {TransactionType.transfer})), [3]);
      expect(await amounts(const TransactionQuery(search: 'гиппо')), [1]);
      expect(await amounts(const TransactionQuery(search: 'ОТПУСК')), [2]);
    });

    test('totals are grouped by account currency', () async {
      final usd = await accounts.create(const AccountDraft(name: 'USD', type: AccountType.cash, currency: 'USD'));
      final salary = await seedCategory(db, 'Зарплата', kind: CategoryKind.income);
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 1000, date: Dates.of(2026, 10, 5), categoryId: food));
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: usd, amount: 50, date: Dates.of(2026, 10, 6), categoryId: food));
      await transactions.create(TransactionDraft(type: TransactionType.income, accountId: card, amount: 9000, date: Dates.of(2026, 10, 7), categoryId: salary));
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 77, date: Dates.of(2026, 9, 1), categoryId: food));

      final totals = await transactions.watchTotals(Dates.of(2026, 10, 1), Dates.of(2026, 10, 31)).first;

      expect(totals.expense, {'BYN': 1000, 'USD': 50});
      expect(totals.income, {'BYN': 9000});
    });
  });

  group('categories', () {
    test('quick picks: recently used first, parents with children left out', () async {
      final repo = CategoriesRepository(db);
      final card = await accounts.create(const AccountDraft(name: 'Карта', type: AccountType.debitCard, currency: 'BYN'));
      final transport = await seedCategory(db, 'Транспорт');
      final taxi = await seedCategory(db, 'Такси', parentId: transport);
      final cafe = await seedCategory(db, 'Кафе');
      final apteka = await seedCategory(db, 'Аптека');
      await seedCategory(db, 'Зарплата', kind: CategoryKind.income);

      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 1, date: Dates.of(2026, 10, 1), categoryId: cafe));
      clock.advance(const Duration(minutes: 1));
      await transactions.create(TransactionDraft(type: TransactionType.expense, accountId: card, amount: 1, date: Dates.of(2026, 10, 1), categoryId: taxi));

      final picks = await repo.watchQuickPicks(CategoryKind.expense).first;
      expect(picks.map((c) => c.id), [taxi, cafe, apteka]);
    });
  });

  test('settings changes are queued as the settings entity', () async {
    final repo = SettingsRepository(db, clock, onChange: () => changes++);

    await repo.update(baseCurrency: 'USD', firstDayOfMonth: 5);

    final settings = (await repo.get())!;
    expect(settings.baseCurrency, 'USD');
    expect(settings.firstDayOfMonth, 5);
    final entry = (await outbox()).single;
    expect(entry.entityType, 'settings');
    expect(entry.entityId, 'user-1');
    expect(jsonDecode(entry.payload!), containsPair('firstDayOfMonth', 5));
  });
}
