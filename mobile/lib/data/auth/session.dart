import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart';

part 'session.g.dart';

sealed class SessionState {
  const SessionState();
}

class SignedOut extends SessionState {
  const SignedOut();
}

class SignedIn extends SessionState {
  const SignedIn(this.userId, {this.needsSetup = false});

  final String userId;

  /// Registration done, but the onboarding steps (currency, month, first account) are not.
  final bool needsSetup;
}

/// Who is signed in. Signing in or out resets the local database.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  static const setupKey = 'onboarding.pending';

  @override
  Future<SessionState> build() async {
    final tokens = ref.watch(tokenManagerProvider);
    tokens.onExpired = () {
      ref.read(syncSchedulerProvider).stop();
      state = const AsyncData(SignedOut());
    };
    final current = await tokens.current();
    if (current == null) return const SignedOut();
    final pending = await ref.read(databaseProvider).getValue(setupKey) == 'true';
    _startSync();
    return SignedIn(current.userId, needsSetup: pending);
  }

  Future<void> register(String email, String password) async {
    final api = ref.read(apiClientProvider);
    final auth = await api.register(email: email, password: password);
    await _signedIn(auth.userId, () => ref.read(tokenManagerProvider).save(auth), needsSetup: true);
  }

  Future<void> login(String email, String password) async {
    final auth = await ref.read(apiClientProvider).login(email, password);
    await _signedIn(auth.userId, () => ref.read(tokenManagerProvider).save(auth));
  }

  Future<void> _signedIn(String userId, Future<void> Function() saveTokens, {bool needsSetup = false}) async {
    final db = ref.read(databaseProvider);
    await db.wipe();
    await saveTokens();
    await ref.read(settingsRepositoryProvider).saveFromServer(await ref.read(apiClientProvider).me());
    if (needsSetup) await db.setValue(setupKey, 'true');
    state = AsyncData(SignedIn(userId, needsSetup: needsSetup));
    _startSync();
  }

  /// The onboarding steps are done.
  Future<void> completeSetup() async {
    await ref.read(databaseProvider).setValue(setupKey, null);
    if (state.value case SignedIn(:final userId)) state = AsyncData(SignedIn(userId));
    unawaited(ref.read(syncSchedulerProvider).syncNow());
  }

  Future<void> logout() async {
    ref.read(syncSchedulerProvider).stop();
    final tokens = ref.read(tokenManagerProvider);
    final current = await tokens.current();
    if (current != null) await ref.read(apiClientProvider).logout(current.refreshToken);
    await tokens.clear();
    await ref.read(databaseProvider).wipe();
    state = const AsyncData(SignedOut());
  }

  void _startSync() => ref.read(syncSchedulerProvider).start();
}
