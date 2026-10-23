import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smallney/core/theme/app_theme.dart';
import 'package:smallney/core/time/clock.dart';
import 'package:smallney/data/db/app_database.dart';
import 'package:smallney/data/model/enums.dart';
import 'package:smallney/data/providers.dart';
import 'package:smallney/data/sync/sync_engine.dart';
import 'package:smallney/data/sync/sync_scheduler.dart';
import 'package:smallney/features/quick_add/quick_add_screen.dart';
import 'package:smallney/l10n/generated/app_localizations.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late String card;
  late String cash;
  late String cafe;
  late String salary;

  setUpAll(() => initializeDateFormatting('ru'));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = memoryDb();
    card = '0190a5d2-ac96-774b-bcce-000000000001';
    cash = '0190a5d2-ac96-774b-bcce-000000000002';
    await db.into(db.accounts).insert(AccountsCompanion.insert(id: card, name: 'Карта', type: AccountType.debitCard, currency: 'BYN', sortOrder: const Value(1)));
    await db.into(db.accounts).insert(AccountsCompanion.insert(id: cash, name: 'Наличные', type: AccountType.cash, currency: 'BYN', sortOrder: const Value(2)));
    await seedSettings(db, defaultAccount: card);
    cafe = await seedCategory(db, 'Кафе', icon: 'cafe');
    await seedCategory(db, 'Продукты', icon: 'cart');
    salary = await seedCategory(db, 'Зарплата', kind: CategoryKind.income, icon: 'salary');
  });

  tearDown(() => db.close());

  Future<void> pumpQuickAdd(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(initialLocation: '/', routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/add', builder: (_, _) => const QuickAddScreen()),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 22, 12))),
        syncSchedulerProvider.overrideWithValue(SyncScheduler(SyncEngine(db, FakeSyncApi()))),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.dark(),
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ));
    router.push('/add');
    await _settle(tester);
  }

  Future<void> tapKeys(WidgetTester tester, String keys) async {
    for (final key in keys.split('')) {
      await tester.tap(find.byKey(Key('key_$key')));
      await tester.pump();
    }
  }

  testWidgets('an expense in three taps: amount, category, save', (tester) async {
    await pumpQuickAdd(tester);

    expect(find.text('Карта'), findsOneWidget, reason: 'the default spending account is preselected');
    await tapKeys(tester, '24,5');
    expect(find.byKey(const Key('amount')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('amount'))).data, '24,5');

    final save = find.textContaining('Сохранить');
    expect(tester.widget<Opacity>(find.ancestor(of: save, matching: find.byType(Opacity)).first).opacity, lessThan(1),
        reason: 'disabled until a category is chosen');

    await tester.tap(find.text('Кафе'));
    await tester.pump();
    expect(find.text('Сохранить · −24,50 Br'), findsOneWidget);

    await tester.tap(find.text('Сохранить · −24,50 Br'));
    await _settle(tester);

    final saved = await db.select(db.transactions).getSingle();
    expect(saved.type, TransactionType.expense);
    expect(saved.amount, 2450);
    expect(saved.accountId, card);
    expect(saved.categoryId, cafe);
    expect(saved.status, TransactionStatus.cleared);
    expect((await db.select(db.outbox).getSingle()).entityType, 'transaction');
    expect(find.text('home'), findsOneWidget, reason: 'the screen closes after saving');
    await _finish(tester);
  });

  testWidgets('switching to income shows income categories and clears the selection', (tester) async {
    await pumpQuickAdd(tester);
    await tester.tap(find.text('Кафе'));
    await tester.pump();

    await tester.tap(find.text('Доход'));
    await _settle(tester);

    expect(find.text('Кафе'), findsNothing);
    expect(find.text('Зарплата'), findsOneWidget);
    await tapKeys(tester, '1000');
    await tester.tap(find.text('Зарплата'));
    await tester.pump();
    await tester.tap(find.textContaining('Сохранить'));
    await _settle(tester);

    final saved = await db.select(db.transactions).getSingle();
    expect(saved.type, TransactionType.income);
    expect(saved.amount, 100000);
    expect(saved.categoryId, salary);
    await _finish(tester);
  });

  testWidgets('a transfer goes from the default account to another one', (tester) async {
    await pumpQuickAdd(tester);
    await tester.tap(find.text('Перевод'));
    await _settle(tester);

    expect(find.text('Карта · BYN'), findsOneWidget);
    expect(find.text('Наличные · BYN'), findsOneWidget);
    await tapKeys(tester, '50');
    await tester.tap(find.textContaining('Сохранить'));
    await _settle(tester);

    final saved = await db.select(db.transactions).getSingle();
    expect(saved.type, TransactionType.transfer);
    expect(saved.accountId, card);
    expect(saved.toAccountId, cash);
    expect(saved.toAmount, 5000);
    expect(saved.categoryId, isNull);
    await _finish(tester);
  });

  testWidgets('backspace and the decimal limit', (tester) async {
    await pumpQuickAdd(tester);
    await tapKeys(tester, '12,345');
    expect(tester.widget<Text>(find.byKey(const Key('amount'))).data, '12,34');
    await tester.tap(find.byKey(const Key('key_back')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('amount'))).data, '12,3');
    await _finish(tester);
  });
}

/// Unmounts the app and lets the sync debounce and drift's stream cleanup timers run out.
Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
}

/// pumpAndSettle never settles here (the caret blinks forever), so pump a fixed time instead.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
