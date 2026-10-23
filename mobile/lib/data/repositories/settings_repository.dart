import 'package:drift/drift.dart';
import 'package:rational/rational.dart';

import '../../core/money/exchange.dart';
import '../../core/time/clock.dart';
import '../api/dto.dart';
import '../db/app_database.dart';
import '../model/enums.dart';
import '../sync/entity_codec.dart';
import '../sync/outbox.dart';

class SettingsRepository {
  SettingsRepository(this._db, this._clock, {this.onChange});

  final AppDatabase _db;
  final Clock _clock;
  final void Function()? onChange;

  late final _outbox = OutboxWriter(_db, _clock);

  Stream<SettingsRow?> watch() => _db.select(_db.userSettings).watchSingleOrNull();

  Future<SettingsRow?> get() => _db.select(_db.userSettings).getSingleOrNull();

  /// Stores the profile returned by the server right after sign-in (before the first pull).
  Future<void> saveFromServer(MeResponse me) => _db.into(_db.userSettings).insertOnConflictUpdate(UserSettingsCompanion.insert(
        id: me.id,
        email: Value(me.email),
        baseCurrency: Value(me.baseCurrency),
        timezone: Value(me.timezone),
        firstDayOfMonth: Value(me.firstDayOfMonth),
        defaultSpendingAccountId: Value(me.defaultSpendingAccountId),
        lowBalanceThreshold: Value(me.lowBalanceThreshold),
      ));

  Future<void> update({String? baseCurrency, int? firstDayOfMonth, Value<String?> defaultSpendingAccountId = const Value.absent()}) async {
    await _db.transaction(() async {
      final current = await get();
      if (current == null) return;
      await (_db.update(_db.userSettings)..where((s) => s.id.equals(current.id))).write(UserSettingsCompanion(
        baseCurrency: baseCurrency == null ? const Value.absent() : Value(baseCurrency),
        firstDayOfMonth: firstDayOfMonth == null ? const Value.absent() : Value(firstDayOfMonth),
        defaultSpendingAccountId: defaultSpendingAccountId,
      ));
      final updated = (await get())!;
      await _outbox.upsert(SyncEntity.settings, updated.id, EntityCodec.settings(updated));
    });
    onChange?.call();
  }
}

class RatesRepository {
  RatesRepository(this._db);

  final AppDatabase _db;

  Stream<ExchangeRates> watch() => _db.select(_db.rates).watch().map(
        (rows) => ExchangeRates({for (final r in rows) r.currency: Rational.parse(r.rate)}),
      );
}
