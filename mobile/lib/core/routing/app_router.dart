import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/auth/session.dart';
import '../../features/accounts/account_edit_screen.dart';
import '../../features/accounts/accounts_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/setup_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/placeholders/coming_soon_screen.dart';
import '../../features/quick_add/quick_add_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../data/model/enums.dart';

/// Bridges the session provider to go_router's refresh mechanism.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      if (session.isLoading || !session.hasValue) return location == '/splash' ? null : '/splash';
      return switch (session.requireValue) {
        SignedOut() => location == '/welcome' ? null : '/welcome',
        SignedIn(needsSetup: true) => location == '/setup' ? null : '/setup',
        SignedIn() => (location == '/welcome' || location == '/setup' || location == '/splash') ? '/home' : null,
      };
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _Splash()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/transactions', builder: (_, _) => const TransactionsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/budget', builder: (_, _) => const ComingSoonScreen.budget())]),
          StatefulShellBranch(routes: [GoRoute(path: '/analytics', builder: (_, _) => const ComingSoonScreen.analytics())]),
        ],
      ),
      GoRoute(
        path: '/add',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: QuickAddScreen(
            initialType: switch (state.uri.queryParameters['type']) {
              'income' => TransactionType.income,
              'transfer' => TransactionType.transfer,
              _ => TransactionType.expense,
            },
          ),
        ),
      ),
      GoRoute(
        path: '/transactions/:id',
        pageBuilder: (context, state) =>
            MaterialPage(fullscreenDialog: true, child: QuickAddScreen(transactionId: state.pathParameters['id'])),
      ),
      GoRoute(path: '/accounts', builder: (_, _) => const AccountsScreen()),
      GoRoute(path: '/accounts/new', builder: (_, _) => const AccountEditScreen()),
      GoRoute(path: '/accounts/:id', builder: (_, state) => AccountEditScreen(accountId: state.pathParameters['id'])),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    ],
  );
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
