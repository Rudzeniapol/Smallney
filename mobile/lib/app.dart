import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_preferences.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers.dart';
import 'l10n/generated/app_localizations.dart';

class SmallneyApp extends ConsumerStatefulWidget {
  const SmallneyApp({super.key});

  @override
  ConsumerState<SmallneyApp> createState() => _SmallneyAppState();
}

class _SmallneyAppState extends ConsumerState<SmallneyApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Sync while in the foreground, pause the periodic sync in the background.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(syncSchedulerProvider).setForeground(true),
      onPause: () => ref.read(syncSchedulerProvider).setForeground(false),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: prefs.themeMode,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) =>
          supported.firstWhere((l) => l.languageCode == locale?.languageCode, orElse: () => const Locale('ru')),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
