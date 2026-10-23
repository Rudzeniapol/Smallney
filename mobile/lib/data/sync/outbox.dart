import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../db/app_database.dart';
import '../model/enums.dart';

/// Records local changes for the next push. Call inside the same database transaction as the change.
class OutboxWriter {
  OutboxWriter(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Future<void> upsert(SyncEntity entity, String id, Map<String, dynamic> payload) =>
      _add(entity, id, SyncOperation.upsert, jsonEncode(payload));

  Future<void> delete(SyncEntity entity, String id) => _add(entity, id, SyncOperation.delete, null);

  Future<void> _add(SyncEntity entity, String id, SyncOperation operation, String? payload) async {
    // Strictly increasing timestamps, even for changes made within the same microsecond.
    final last = await (_db.selectOnly(_db.outbox)..addColumns([_db.outbox.clientUpdatedAtUs.max()]))
        .map((r) => r.read(_db.outbox.clientUpdatedAtUs.max()))
        .getSingleOrNull();
    var now = _clock.now().toUtc().microsecondsSinceEpoch;
    if (last != null && now <= last) now = last + 1;

    await _db.into(_db.outbox).insert(OutboxCompanion.insert(
          entityType: entity.wire,
          entityId: id,
          operation: operation.wire,
          payload: Value(payload),
          clientUpdatedAtUs: now,
        ));
  }
}
