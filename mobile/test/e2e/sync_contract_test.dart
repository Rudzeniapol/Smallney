// End-to-end check of the client against a running backend (real HTTP, real sync protocol).
// Run: SMALLNEY_E2E_URL=http://localhost:5080 flutter test test/e2e
@Tags(['e2e'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:smallney/core/ids/uuid_v7.dart';
import 'package:smallney/core/time/clock.dart';
import 'package:smallney/core/time/dates.dart';
import 'package:smallney/data/api/api_client.dart';
import 'package:smallney/data/auth/token_manager.dart';
import 'package:smallney/data/auth/token_store.dart';
import 'package:smallney/data/db/app_database.dart';
import 'package:smallney/data/model/enums.dart';
import 'package:smallney/data/repositories/accounts_repository.dart';
import 'package:smallney/data/repositories/settings_repository.dart';
import 'package:smallney/data/repositories/transactions_repository.dart';
import 'package:smallney/data/sync/sync_engine.dart';

import '../helpers.dart';

final _baseUrl = Platform.environment['SMALLNEY_E2E_URL'];

/// One "device": its own database, tokens and API client.
class _Device {
  _Device(String baseUrl) {
    final options = BaseOptions(baseUrl: baseUrl, contentType: Headers.jsonContentType);
    tokens = TokenManager(MemoryTokenStore(), Dio(options));
    final dio = Dio(options);
    dio.interceptors.add(AuthInterceptor(tokens, dio));
    api = ApiClient(dio);
    engine = SyncEngine(db, api, clock: clock);
    accounts = AccountsRepository(db, clock);
    transactions = TransactionsRepository(db, clock);
    settings = SettingsRepository(db, clock);
  }

  final db = memoryDb();
  final clock = const Clock();
  late final TokenManager tokens;
  late final ApiClient api;
  late final SyncEngine engine;
  late final AccountsRepository accounts;
  late final TransactionsRepository transactions;
  late final SettingsRepository settings;
}

void main() {
  final skip = _baseUrl == null ? 'set SMALLNEY_E2E_URL to run against a backend' : null;

  test('two devices of one user converge through the server', () async {
    final email = 'e2e-${Ids.newId()}@test.by';
    final phone = _Device(_baseUrl!);
    final tablet = _Device(_baseUrl!);

    // Register on the phone, sign in on the tablet.
    await phone.tokens.save(await phone.api.register(email: email, password: 'password123'));
    await phone.settings.saveFromServer(await phone.api.me());
    await tablet.tokens.save(await tablet.api.login(email, 'password123'));

    // Offline work on the phone: an account, a categorised expense, settings.
    await phone.engine.run(); // pulls the default categories
    final food = (await phone.db.select(phone.db.categories).get()).firstWhere((c) => c.name == 'Продукты');
    final card = await phone.accounts.create(const AccountDraft(name: 'Карта', type: AccountType.debitCard, currency: 'BYN', initialBalance: 100000));
    final usd = await phone.accounts.create(const AccountDraft(name: 'Доллары', type: AccountType.cash, currency: 'USD'));
    final expense = await phone.transactions.create(TransactionDraft(
      type: TransactionType.expense,
      accountId: card,
      amount: 2450,
      date: Dates.of(2026, 10, 22),
      categoryId: food.id,
      note: 'Евроопт',
      tags: const ['еда'],
    ));
    await phone.transactions.create(TransactionDraft(
      type: TransactionType.transfer,
      accountId: card,
      toAccountId: usd,
      amount: 30000,
      toAmount: 10000,
      date: Dates.of(2026, 10, 22),
    ));
    await phone.settings.update(firstDayOfMonth: 5, defaultSpendingAccountId: Value(card));

    final report = await phone.engine.run();
    expect(report.rejected, 0);
    expect(await phone.db.select(phone.db.outbox).get(), isEmpty);

    // The tablet gets everything.
    await tablet.engine.run();
    final balances = {for (final a in await tablet.accounts.watchAll().first) a.account.name: a.balance};
    expect(balances, {'Карта': 100000 - 2450 - 30000, 'Доллары': 10000});
    final pulled = (await tablet.transactions.watchOne(expense).first)!;
    expect(pulled.note, 'Евроопт');
    expect(pulled.tags, ['еда']);
    expect((await tablet.settings.get())!.firstDayOfMonth, 5);
    expect((await tablet.db.select(tablet.db.rates).get()), isNotEmpty);

    // The server computes the same balance.
    final server = await Dio(BaseOptions(baseUrl: _baseUrl!, headers: {'Authorization': 'Bearer ${(await phone.tokens.current())!.accessToken}'}))
        .get<List<dynamic>>('/api/v1/accounts');
    expect(server.data!.firstWhere((a) => a['name'] == 'Карта')['balance'], 100000 - 2450 - 30000);

    // The tablet deletes the expense; the phone sees the deletion.
    await tablet.transactions.delete(expense);
    await tablet.engine.run();
    await phone.engine.run();
    expect(await phone.transactions.watchOne(expense).first, isNull);
    expect((await phone.accounts.watchOne(card).first)!.balance, 100000 - 30000);

    // Deletion wins: an offline edit of the deleted expense is rejected and dropped locally.
    await phone.db.into(phone.db.transactions).insert(TransactionsCompanion.insert(
          id: expense,
          accountId: card,
          type: TransactionType.expense,
          amount: 1,
          date: Dates.of(2026, 10, 22),
          categoryId: Value(food.id),
          status: TransactionStatus.cleared,
          createdAtUs: 0,
        ));
    final row = (await phone.transactions.watchOne(expense).first)!;
    await phone.transactions.update(expense, TransactionDraft.of(row));
    await phone.engine.run();
    expect(await phone.transactions.watchOne(expense).first, isNull);
    expect(await phone.db.select(phone.db.outbox).get(), isEmpty);
  }, skip: skip, timeout: const Timeout(Duration(minutes: 2)));
}
