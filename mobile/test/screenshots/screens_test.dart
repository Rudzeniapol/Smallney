// Renders the main screens with the real fonts to PNG files (visual check, not a regression gate).
// Run: SMALLNEY_SCREENSHOTS=1 flutter test --tags screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallney/core/theme/app_theme.dart';
import 'package:smallney/core/time/clock.dart';
import 'package:smallney/core/time/dates.dart';
import 'package:smallney/data/db/app_database.dart';
import 'package:smallney/data/model/enums.dart';
import 'package:smallney/data/providers.dart';
import 'package:smallney/data/repositories/accounts_repository.dart';
import 'package:smallney/data/repositories/transactions_repository.dart';
import 'package:smallney/data/sync/sync_engine.dart';
import 'package:smallney/data/sync/sync_scheduler.dart';
import 'package:smallney/features/accounts/account_edit_screen.dart';
import 'package:smallney/features/home/home_screen.dart';
import 'package:smallney/features/onboarding/setup_screen.dart';
import 'package:smallney/features/onboarding/welcome_screen.dart';
import 'package:smallney/features/quick_add/quick_add_screen.dart';
import 'package:smallney/features/settings/settings_screen.dart';
import 'package:smallney/features/shell/app_shell.dart';
import 'package:smallney/features/transactions/transactions_screen.dart';
import 'package:smallney/l10n/generated/app_localizations.dart';

import '../helpers.dart';

Future<void> _loadFonts() async {
  for (final (family, files) in [
    ('Onest', ['Regular', 'Medium', 'SemiBold', 'Bold']),
    ('Unbounded', ['Medium', 'SemiBold', 'Bold']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(rootBundle.load('assets/fonts/$family-$f.ttf'));
    }
    await loader.load();
  }
}

void main() {
  final skip = Platform.environment['SMALLNEY_SCREENSHOTS'] == null ? 'set SMALLNEY_SCREENSHOTS=1' : null;

  setUpAll(() async {
    await _loadFonts();
    await initializeDateFormatting('ru');
  });

  Future<AppDatabase> seed(FixedClock clock) async {
    final db = memoryDb();
    final accounts = AccountsRepository(db, clock);
    final transactions = TransactionsRepository(db, clock);
    final card = await accounts.create(const AccountDraft(name: 'Зарплатная карта', type: AccountType.debitCard, currency: 'BYN', initialBalance: 421540));
    final deposit = await accounts.create(const AccountDraft(
        name: 'Депозит', type: AccountType.deposit, currency: 'USD', initialBalance: 210000, interestRatePercent: '9.5', capitalizationPeriod: CapitalizationPeriod.monthly));
    await accounts.create(const AccountDraft(name: 'Кредитка', type: AccountType.creditCard, currency: 'BYN', initialBalance: -64020, creditLimit: 300000));
    final cash = await accounts.create(const AccountDraft(name: 'Наличные', type: AccountType.cash, currency: 'BYN', initialBalance: 38000));
    await seedSettings(db, defaultAccount: card);
    await db.into(db.rates).insert(RatesCompanion.insert(currency: 'USD', rate: '2.9713', date: Dates.of(2026, 10, 22)));

    final cats = <String, String>{};
    for (final (name, icon, color, kind) in [
      ('Кафе и рестораны', 'cafe', '#FF8A5B', CategoryKind.expense),
      ('Продукты', 'cart', '#85BB65', CategoryKind.expense),
      ('Транспорт', 'transport', '#5CC8FF', CategoryKind.expense),
      ('Подписки', 'subscription', '#F2C14E', CategoryKind.expense),
      ('Дом', 'home', '#9C90FF', CategoryKind.expense),
      ('Досуг', 'fun', '#C58BFF', CategoryKind.expense),
      ('Одежда', 'clothes', '#FF7A9C', CategoryKind.expense),
      ('Связь и интернет', 'phone', '#F2C14E', CategoryKind.expense),
      ('Зарплата', 'salary', '#85BB65', CategoryKind.income),
    ]) {
      final id = await seedCategory(db, name, kind: kind, icon: icon);
      await (db.update(db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(color: Value(color)));
      cats[name] = id;
    }

    Future<void> t(TransactionType type, String account, int amount, int day, {String? cat, String? note, String? to, TransactionStatus status = TransactionStatus.cleared}) async {
      await transactions.create(TransactionDraft(
          type: type, accountId: account, amount: amount, date: Dates.of(2026, 10, day), categoryId: cat == null ? null : cats[cat], note: note, toAccountId: to, status: status));
      clock.advance(const Duration(minutes: 3));
    }

    await t(TransactionType.income, card, 241240, 20, cat: 'Зарплата', note: 'Зарплата');
    await t(TransactionType.expense, card, 13600, 20, cat: 'Одежда', note: 'Куртка');
    await t(TransactionType.transfer, card, 20000, 21, to: cash);
    await t(TransactionType.expense, cash, 7800, 21, cat: 'Кафе и рестораны', note: 'Ужин с друзьями');
    await t(TransactionType.expense, card, 9430, 22, cat: 'Продукты', note: 'Супермаркет');
    await t(TransactionType.expense, card, 420, 22, cat: 'Транспорт');
    await t(TransactionType.expense, card, 1850, 22, cat: 'Связь и интернет', note: 'Мобильная связь', status: TransactionStatus.planned);
    await db.setValue(SyncEngine.lastSyncKey, DateTime.utc(2026, 10, 22, 8, 58).toIso8601String());
    deposit.isEmpty;
    return db;
  }

  Future<void> shoot(WidgetTester tester, String name, Widget screen, {ThemeMode mode = ThemeMode.dark, bool inShell = false, double height = 844}) async {
    tester.view.physicalSize = Size(390 * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final clock = FixedClock(DateTime(2026, 10, 22, 12));
    final db = (await tester.runAsync(() => seed(clock)))!;
    addTearDown(() => db.close());
    SharedPreferences.setMockInitialValues({});
    final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
    final router = GoRouter(initialLocation: '/s', routes: [
      if (inShell)
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/s', builder: (_, _) => screen)]),
            StatefulShellBranch(routes: [GoRoute(path: '/b', builder: (_, _) => const SizedBox())]),
          ],
        )
      else
        GoRoute(path: '/s', builder: (_, _) => screen),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(clock..value = DateTime(2026, 10, 22, 12)),
        syncSchedulerProvider.overrideWithValue(SyncScheduler(SyncEngine(db, FakeSyncApi()))),
      ],
      child: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844), padding: EdgeInsets.only(top: 44, bottom: 24), disableAnimations: true),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('png/$name.png'));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets('home dark', (t) => shoot(t, 'home_dark', const HomeScreen(), inShell: true), skip: skip != null);
  testWidgets('home light', (t) => shoot(t, 'home_light', const HomeScreen(), inShell: true, mode: ThemeMode.light), skip: skip != null);
  testWidgets('transactions', (t) => shoot(t, 'transactions_dark', const TransactionsScreen(), inShell: true), skip: skip != null);
  testWidgets('quick add', (t) => shoot(t, 'quick_add_dark', const QuickAddScreen()), skip: skip != null);
  testWidgets('quick add light', (t) => shoot(t, 'quick_add_light', const QuickAddScreen(), mode: ThemeMode.light), skip: skip != null);
  testWidgets('transfer', (t) => shoot(t, 'transfer_dark', const QuickAddScreen(initialType: TransactionType.transfer)), skip: skip != null);
  testWidgets('welcome', (t) => shoot(t, 'welcome_dark', const WelcomeScreen()), skip: skip != null);
  testWidgets('setup', (t) => shoot(t, 'setup_dark', const SetupScreen()), skip: skip != null);
  testWidgets('settings', (t) => shoot(t, 'settings_dark', const SettingsScreen()), skip: skip != null);
  testWidgets('account', (t) => shoot(t, 'account_new_dark', const AccountEditScreen()), skip: skip != null);
}
