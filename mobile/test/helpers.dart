import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:smallney/core/ids/uuid_v7.dart';
import 'package:smallney/core/time/clock.dart';
import 'package:smallney/data/api/api_client.dart';
import 'package:smallney/data/api/dto.dart';
import 'package:smallney/data/db/app_database.dart';
import 'package:smallney/data/model/enums.dart';

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

class FixedClock extends Clock {
  FixedClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;

  void advance(Duration d) => value = value.add(d);
}

Future<void> seedSettings(AppDatabase db, {String id = 'user-1', String base = 'BYN', String? defaultAccount}) =>
    db.into(db.userSettings).insert(UserSettingsCompanion.insert(
          id: id,
          email: const Value('me@test.by'),
          baseCurrency: Value(base),
          defaultSpendingAccountId: Value(defaultAccount),
        ));

Future<String> seedCategory(AppDatabase db, String name, {CategoryKind kind = CategoryKind.expense, String? parentId, String? icon}) async {
  final id = Ids.newId();
  await db.into(db.categories).insert(CategoriesCompanion.insert(
        id: id,
        name: name,
        kind: kind,
        parentId: Value(parentId),
        icon: Value(icon),
        color: const Value('#85BB65'),
        version: const Value(1),
      ));
  return id;
}

/// Records pushes and serves scripted pull pages.
class FakeSyncApi implements SyncApi {
  final pushes = <List<SyncChangeDto>>[];
  final pullPages = <PullResponseDto>[];
  final pullCalls = <int>[];
  int ratesCalls = 0;
  RatesResponseDto ratesResponse = const RatesResponseDto(baseCurrency: 'BYN', date: '2026-10-22', rates: [RateDto(currency: 'USD', rate: 3.0, date: '2026-10-22')]);

  /// Decides the outcome of each pushed change; default: accept with an increasing version.
  PushResponseDto Function(List<SyncChangeDto> changes)? onPush;
  int _version = 100;

  @override
  Future<PushResponseDto> push(List<SyncChangeDto> changes) async {
    pushes.add(changes);
    return onPush?.call(changes) ??
        PushResponseDto(accepted: [
          for (final c in changes)
            AcceptedChangeDto(entityType: c.entityType, id: c.id, operation: c.operation, version: ++_version, status: 'Applied'),
        ]);
  }

  @override
  Future<PullResponseDto> pull(int since, {int limit = 500}) async {
    pullCalls.add(since);
    if (pullPages.isEmpty) return PullResponseDto(changes: const [], nextCursor: since, hasMore: false);
    return pullPages.removeAt(0);
  }

  @override
  Future<RatesResponseDto> rates() async {
    ratesCalls++;
    return ratesResponse;
  }
}
