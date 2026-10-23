import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../core/money/exchange.dart';
import '../core/time/clock.dart';
import 'api/api_client.dart';
import 'auth/token_manager.dart';
import 'auth/token_store.dart';
import 'db/app_database.dart';
import 'repositories/accounts_repository.dart';
import 'repositories/categories_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/transactions_repository.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_scheduler.dart';

part 'providers.g.dart';

/// Overridden in main() and in tests.
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) => throw UnimplementedError('database is provided by main()');

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) => throw UnimplementedError('sharedPreferences is provided by main()');

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => SecureTokenStore();

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => AppConfig(ref.watch(sharedPreferencesProvider));

BaseOptions _options(String baseUrl) => BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

@Riverpod(keepAlive: true)
TokenManager tokenManager(Ref ref) =>
    TokenManager(ref.watch(tokenStoreProvider), Dio(_options(ref.watch(appConfigProvider).baseUrl)));

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final dio = Dio(_options(ref.watch(appConfigProvider).baseUrl));
  dio.interceptors.add(AuthInterceptor(ref.watch(tokenManagerProvider), dio));
  return ApiClient(dio);
}

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) =>
    SyncEngine(ref.watch(databaseProvider), ref.watch(apiClientProvider), clock: ref.watch(clockProvider));

@Riverpod(keepAlive: true)
SyncScheduler syncScheduler(Ref ref) {
  final scheduler = SyncScheduler(ref.watch(syncEngineProvider), connectivity: Connectivity().onConnectivityChanged);
  ref.onDispose(scheduler.dispose);
  return scheduler;
}

/// Local writes ask for a (debounced) sync.
void Function() _localChange(Ref ref) => () => ref.read(syncSchedulerProvider).localChange();

@Riverpod(keepAlive: true)
AccountsRepository accountsRepository(Ref ref) =>
    AccountsRepository(ref.watch(databaseProvider), ref.watch(clockProvider), onChange: _localChange(ref));

@Riverpod(keepAlive: true)
CategoriesRepository categoriesRepository(Ref ref) => CategoriesRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
TransactionsRepository transactionsRepository(Ref ref) =>
    TransactionsRepository(ref.watch(databaseProvider), ref.watch(clockProvider), onChange: _localChange(ref));

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(databaseProvider), ref.watch(clockProvider), onChange: _localChange(ref));

@Riverpod(keepAlive: true)
RatesRepository ratesRepository(Ref ref) => RatesRepository(ref.watch(databaseProvider));

@riverpod
Stream<ExchangeRates> exchangeRates(Ref ref) => ref.watch(ratesRepositoryProvider).watch();

@riverpod
Stream<SyncStatus> syncStatus(Ref ref) async* {
  final scheduler = ref.watch(syncSchedulerProvider);
  yield scheduler.current;
  yield* scheduler.status;
}
