import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/clock.dart';
import '../../core/time/dates.dart';
import '../api/api_client.dart';
import '../api/dto.dart';
import '../db/app_database.dart';
import 'entity_codec.dart';

class SyncReport {
  const SyncReport({this.pushed = 0, this.rejected = 0, this.pulled = 0});

  final int pushed;
  final int rejected;
  final int pulled;
}

/// One sync round: push the outbox, then pull everything new (docs/sync.md).
///
/// * Only the latest outbox entry of an entity is sent; entries are removed up to the sent one, so a change
///   made while a push is in flight stays queued.
/// * A pulled change never overwrites an entity that still has unsent local changes (the local one is newer).
/// * Concurrent calls share one run.
class SyncEngine {
  SyncEngine(this._db, this._api, {this.clock = const Clock()});

  final AppDatabase _db;
  final SyncApi _api;
  final Clock clock;
  Future<SyncReport>? _running;

  static const cursorKey = 'sync.cursor';
  static const lastSyncKey = 'sync.lastSuccessAt';
  static const ratesFetchedKey = 'rates.fetchedAt';
  static const batchSize = 500;
  static const ratesMaxAge = Duration(hours: 6);

  Future<SyncReport> run() => _running ??= _run().whenComplete(() => _running = null);

  Future<SyncReport> _run() async {
    final (pushed, rejected) = await _push();
    final pulled = await _pull();
    await _refreshRates();
    await _db.setValue(lastSyncKey, clock.now().toUtc().toIso8601String());
    return SyncReport(pushed: pushed, rejected: rejected, pulled: pulled);
  }

  Future<(int, int)> _push() async {
    final entries = await (_db.select(_db.outbox)..orderBy([(o) => OrderingTerm.asc(o.seq)])).get();
    if (entries.isEmpty) return (0, 0);

    final latest = <(String, String), OutboxRow>{};
    for (final entry in entries) {
      latest[(entry.entityType, entry.entityId)] = entry;
    }

    var accepted = 0;
    var rejected = 0;
    final pending = latest.values.toList();
    for (var i = 0; i < pending.length; i += batchSize) {
      final batch = pending.sublist(i, i + batchSize > pending.length ? pending.length : i + batchSize);
      final bySeq = {for (final e in batch) (e.entityType, e.entityId): e};
      final response = await _api.push([
        for (final e in batch)
          SyncChangeDto(
            entityType: e.entityType,
            id: e.entityId,
            operation: e.operation,
            payload: e.payload == null ? null : jsonDecode(e.payload!) as Map<String, dynamic>,
            clientUpdatedAt: DateTime.fromMicrosecondsSinceEpoch(e.clientUpdatedAtUs, isUtc: true),
          ),
      ]);

      await _db.transaction(() async {
        for (final a in response.accepted) {
          final sent = bySeq[(a.entityType, a.id)];
          if (sent == null) continue;
          await _removeUpTo(sent);
          if (a.version != null && a.operation.toLowerCase() == 'upsert') {
            await EntityCodec.setVersion(_db, a.entityType, a.id, a.version!);
          }
          accepted++;
        }

        for (final r in response.rejected) {
          final sent = bySeq[(r.entityType ?? '', r.id)];
          if (sent == null) continue;
          if (r.code == 'entity_deleted') {
            // Deleted on the server: deletion wins, drop the local copy.
            await EntityCodec.applyDelete(_db, sent.entityType, sent.entityId);
            await _removeUpTo(sent);
            continue;
          }

          await (_db.update(_db.outbox)..where((o) => o.entityType.equals(sent.entityType) & o.entityId.equals(sent.entityId) & o.seq.isSmallerOrEqualValue(sent.seq)))
              .write(OutboxCompanion(
            errorCode: Value(r.code),
            errorMessage: Value(r.message),
            attempts: Value(sent.attempts + 1),
          ));
          rejected++;
        }
      });
    }

    return (accepted, rejected);
  }

  Future<void> _removeUpTo(OutboxRow sent) =>
      (_db.delete(_db.outbox)..where((o) => o.entityType.equals(sent.entityType) & o.entityId.equals(sent.entityId) & o.seq.isSmallerOrEqualValue(sent.seq)))
          .go();

  Future<int> _pull() async {
    var cursor = int.tryParse(await _db.getValue(cursorKey) ?? '') ?? 0;
    var applied = 0;
    while (true) {
      final page = await _api.pull(cursor, limit: batchSize);
      await _db.transaction(() async {
        final unsent = (await _db.select(_db.outbox).get()).map((e) => (e.entityType, e.entityId)).toSet();
        for (final change in page.changes) {
          if (unsent.contains((change.entityType, change.id))) continue;
          if (change.deleted) {
            await EntityCodec.applyDelete(_db, change.entityType, change.id);
          } else if (change.data != null) {
            await EntityCodec.applyUpsert(_db, change.entityType, change.id, change.version, change.data!);
          }
          applied++;
        }

        cursor = page.nextCursor;
        await _db.setValue(cursorKey, '$cursor');
      });

      if (!page.hasMore) return applied;
    }
  }

  Future<void> _refreshRates() async {
    final fetched = DateTime.tryParse(await _db.getValue(ratesFetchedKey) ?? '');
    if (fetched != null && clock.now().toUtc().difference(fetched) < ratesMaxAge) return;

    final response = await _api.rates();
    await _db.transaction(() async {
      for (final rate in response.rates) {
        await _db.into(_db.rates).insertOnConflictUpdate(RatesCompanion.insert(
              currency: rate.currency,
              rate: rate.rate.toString(),
              date: Dates.parse(rate.date),
            ));
      }
      await _db.setValue(ratesFetchedKey, clock.now().toUtc().toIso8601String());
    });
  }

  /// Forgets a rejected change and resynchronizes from scratch, so the server state wins.
  Future<void> discardRejected(OutboxRow entry) async {
    await _db.transaction(() async {
      final isLocalOnlyCreate = entry.operation.toLowerCase() == 'upsert' && await _isNeverSynced(entry);
      if (isLocalOnlyCreate) await EntityCodec.applyDelete(_db, entry.entityType, entry.entityId);
      await (_db.delete(_db.outbox)..where((o) => o.entityType.equals(entry.entityType) & o.entityId.equals(entry.entityId))).go();
      await _db.setValue(cursorKey, '0');
    });
  }

  Future<bool> _isNeverSynced(OutboxRow entry) async {
    final rows = await _db.customSelect(
      'SELECT version FROM ${_tableName(entry.entityType)} WHERE id = ?',
      variables: [Variable.withString(entry.entityId)],
    ).get();
    return rows.isEmpty || rows.first.read<int?>('version') == null;
  }

  static String _tableName(String entityType) => switch (entityType) {
        'account' => 'accounts',
        'category' => 'categories',
        'transaction' => 'transactions',
        'recurringRule' => 'recurring_rules',
        'budget' => 'budgets',
        'budgetLine' => 'budget_lines',
        'budgetGoalAllocation' => 'budget_goal_allocations',
        'savingsGoal' => 'savings_goals',
        _ => 'user_settings',
      };
}
