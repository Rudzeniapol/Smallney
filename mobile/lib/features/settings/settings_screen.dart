import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_preferences.dart';
import '../../core/money/currency.dart';
import '../../core/theme/app_colors.dart';
import '../../core/time/clock.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/auth/session.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/sync/sync_scheduler.dart';
import '../common/data.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider).value;
    final prefs = ref.watch(preferencesProvider);

    Widget group(List<Widget> children) => SurfaceCard(
          padding: EdgeInsets.zero,
          radius: 22,
          child: Column(children: [
            for (final (i, child) in children.indexed) ...[if (i > 0) Divider(height: 1, color: c.divider), child],
          ]),
        );

    Widget row(String icon, String title, {String? value, VoidCallback? onTap, Color? color}) => ListTile(
          leading: AppIcon(icon, size: 20, color: color ?? c.textSecondary),
          title: Text(title, style: TextStyle(color: color)),
          trailing: value == null ? null : Text(value, style: TextStyle(color: c.textSecondary)),
          onTap: onTap,
        );

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
            Row(children: [
              SquareIconButton(icon: 'chevron_left', label: l10n.back, onTap: () => context.pop()),
              const SizedBox(width: 12),
              Text(l10n.settingsTitle, style: Theme.of(context).textTheme.headlineSmall),
            ]),
            const SizedBox(height: 20),
            if (settings != null) Text(settings.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const _SyncCard(),
            const SizedBox(height: 16),
            group([
              row('card', l10n.accountsTitle, onTap: () => context.push('/accounts')),
              row('cashback', l10n.baseCurrency,
                  value: settings?.baseCurrency,
                  onTap: settings == null ? null : () => _pickBaseCurrency(context, ref, settings)),
              row('calendar', l10n.firstDayOfMonth,
                  value: settings == null ? null : l10n.dayN(settings.firstDayOfMonth),
                  onTap: settings == null ? null : () => _pickFirstDay(context, ref, settings)),
            ]),
            const SizedBox(height: 16),
            Text(l10n.theme, style: TextStyle(fontSize: 13, color: c.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              for (final (mode, label) in [
                (ThemeMode.system, l10n.themeSystem),
                (ThemeMode.light, l10n.themeLight),
                (ThemeMode.dark, l10n.themeDark),
              ]) ...[
                Expanded(
                  child: ChoiceButton(
                    label: label,
                    selected: prefs.themeMode == mode,
                    radius: 14,
                    height: 44,
                    onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(mode),
                  ),
                ),
                if (mode != ThemeMode.dark) const SizedBox(width: 8),
              ],
            ]),
            const SizedBox(height: 16),
            Text(l10n.language, style: TextStyle(fontSize: 13, color: c.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              for (final (code, label) in [('ru', 'Русский'), ('en', 'English')]) ...[
                Expanded(
                  child: ChoiceButton(
                    label: label,
                    selected: context.localeName == code,
                    radius: 14,
                    height: 44,
                    onTap: () => ref.read(preferencesProvider.notifier).setLocale(Locale(code)),
                  ),
                ),
                if (code == 'ru') const SizedBox(width: 8),
              ],
            ]),
            const SizedBox(height: 24),
            group([row('logout', l10n.logout, color: c.danger, onTap: () => _logout(context, ref))]),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickBaseCurrency(BuildContext context, WidgetRef ref, SettingsRow settings) async {
    final picked = await showAppSheet<String>(context, (context) => SafeArea(
          child: ListView(shrinkWrap: true, children: [
            for (final code in Currency.popular)
              ListTile(
                title: Text(code),
                trailing: Text(Currency.of(code).symbol),
                selected: code == settings.baseCurrency,
                onTap: () => Navigator.pop(context, code),
              ),
          ]),
        ));
    if (picked != null) await ref.read(settingsRepositoryProvider).update(baseCurrency: picked);
  }

  Future<void> _pickFirstDay(BuildContext context, WidgetRef ref, SettingsRow settings) async {
    final picked = await showAppSheet<int>(context, (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (var day = 1; day <= 28; day++)
                SizedBox(
                  width: 46,
                  child: ChoiceButton(label: '$day', selected: day == settings.firstDayOfMonth, radius: 14, height: 52, padding: EdgeInsets.zero, onTap: () => Navigator.pop(context, day)),
                ),
            ]),
          ),
        ));
    if (picked != null) await ref.read(settingsRepositoryProvider).update(firstDayOfMonth: picked);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.logout)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(sessionProvider.notifier).logout();
  }
}

/// Sync status, pending changes, rejected ones (with discard) and a manual sync button.
class _SyncCard extends ConsumerWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider).value;
    final outbox = ref.watch(outboxProvider).value ?? const <OutboxRow>[];
    final lastSync = DateTime.tryParse(ref.watch(lastSyncAtProvider).value ?? '');
    final now = ref.watch(clockProvider).now();
    final pending = outbox.map((e) => (e.entityType, e.entityId)).toSet().length;
    final failed = outbox.where((e) => e.errorCode != null).toList();

    final line = switch (status?.phase) {
      SyncPhase.syncing => l10n.syncing,
      SyncPhase.offline => l10n.offline,
      SyncPhase.error => status?.lastError ?? l10n.networkError,
      _ => lastSync == null ? l10n.neverSynced : l10n.lastSync(DateText.ago(context, lastSync.toLocal(), now)),
    };

    return SurfaceCard(
      radius: 22,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AppIcon(status?.phase == SyncPhase.offline ? 'cloud_off' : 'sync', size: 20, color: c.accentText),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.sync, style: Theme.of(context).textTheme.titleMedium)),
          ChoiceButton(label: l10n.syncNow, selected: true, onTap: () => ref.read(syncSchedulerProvider).syncNow()),
        ]),
        const SizedBox(height: 10),
        Text(line, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(pending == 0 ? l10n.allSynced : l10n.pendingChanges(pending), style: Theme.of(context).textTheme.bodySmall),
        if (failed.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.failedChanges, style: TextStyle(color: c.danger, fontWeight: FontWeight.w600)),
          for (final entry in failed.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text('${entry.entityType} · ${entry.errorCode}'),
              subtitle: Text(entry.errorMessage ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: TextButton(
                onPressed: () async {
                  await ref.read(syncEngineProvider).discardRejected(entry);
                  await ref.read(syncSchedulerProvider).syncNow();
                },
                child: Text(l10n.discardChange),
              ),
            ),
        ],
      ]),
    );
  }
}
