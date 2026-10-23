import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../api/api_exception.dart';
import 'sync_engine.dart';

enum SyncPhase { idle, syncing, offline, error }

class SyncStatus {
  const SyncStatus({this.phase = SyncPhase.idle, this.lastError});

  final SyncPhase phase;
  final String? lastError;
}

/// Exponential backoff: 2 s, 4 s, 8 s … capped at 5 minutes.
Duration backoffDelay(int failures) =>
    Duration(seconds: min(300, 2 * pow(2, max(0, failures - 1)).toInt()));

/// Decides when to sync: on start, when the network returns, after local changes (debounced),
/// periodically while the app is in the foreground, and on demand. Never blocks the UI.
class SyncScheduler {
  SyncScheduler(
    this._engine, {
    this.connectivity,
    this.period = const Duration(minutes: 1),
    this.debounce = const Duration(seconds: 2),
  });

  final SyncEngine _engine;

  /// Network changes; null in tests.
  final Stream<List<ConnectivityResult>>? connectivity;
  final Duration period;
  final Duration debounce;

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodic;
  Timer? _debounced;
  Timer? _retry;
  int _failures = 0;
  bool _foreground = true;
  bool _started = false;

  Stream<SyncStatus> get status => _status.stream;
  SyncStatus get current => _current;

  void start() {
    if (_started) return;
    _started = true;
    _connectivitySub = connectivity?.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        syncNow();
      } else {
        _emit(const SyncStatus(phase: SyncPhase.offline));
      }
    });
    _schedulePeriodic();
    syncNow();
  }

  /// Stops all automatic syncing (sign-out).
  void stop() {
    _started = false;
    _periodic?.cancel();
    _debounced?.cancel();
    _retry?.cancel();
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _emit(const SyncStatus());
  }

  /// The app went to the background or came back.
  void setForeground(bool foreground) {
    _foreground = foreground;
    _schedulePeriodic();
    if (foreground) syncNow();
  }

  /// A local change was written: sync soon, coalescing bursts of edits.
  void localChange() {
    _debounced?.cancel();
    _debounced = Timer(debounce, syncNow);
  }

  Future<void> syncNow() async {
    if (!_started) return;
    _retry?.cancel();
    _emit(const SyncStatus(phase: SyncPhase.syncing));
    try {
      await _engine.run();
      _failures = 0;
      _emit(const SyncStatus(phase: SyncPhase.idle));
    } on ApiException catch (e) {
      _failed(e.isNetwork ? const SyncStatus(phase: SyncPhase.offline) : SyncStatus(phase: SyncPhase.error, lastError: e.message));
    } catch (e) {
      _failed(SyncStatus(phase: SyncPhase.error, lastError: '$e'));
    }
  }

  void _failed(SyncStatus status) {
    _failures++;
    _emit(status);
    _retry = Timer(backoffDelay(_failures), syncNow);
  }

  void _schedulePeriodic() {
    _periodic?.cancel();
    if (_started && _foreground) {
      _periodic = Timer.periodic(period, (_) => syncNow());
    }
  }

  void _emit(SyncStatus status) {
    _current = status;
    if (!_status.isClosed) _status.add(status);
  }

  Future<void> dispose() async {
    _started = false;
    _periodic?.cancel();
    _debounced?.cancel();
    _retry?.cancel();
    await _connectivitySub?.cancel();
    await _status.close();
  }
}
