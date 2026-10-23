import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/time/clock.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/sync/sync_scheduler.dart';
import '../common/data.dart';
import '../common/transaction_tile.dart';
import '../common/visuals.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider).value;
    final month = ref.watch(currentMonthProvider);
    final accounts = ref.watch(accountsProvider()).value ?? const <AccountWithBalance>[];

    return GlowBackground(
      child: RefreshIndicator(
        onRefresh: () => ref.read(syncSchedulerProvider).syncNow(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 16, 20, 120),
          children: [
            RiseIn(
              child: Row(children: [
                _Avatar(email: settings?.email ?? ''),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.financialMonth, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(DateText.range(context, month.start, month.end), style: Theme.of(context).textTheme.titleMedium),
                  ]),
                ),
                SquareIconButton(icon: 'settings', label: l10n.settings, onTap: () => context.push('/settings')),
              ]),
            ),
            const SizedBox(height: 22),
            const RiseIn(index: 1, child: _CapitalCard()),
            const SizedBox(height: 22),
            RiseIn(
              index: 2,
              child: SectionHeader(
                title: l10n.accounts,
                action: accounts.isEmpty ? null : l10n.allCount(accounts.length),
                onAction: () => context.push('/accounts'),
              ),
            ),
            const SizedBox(height: 12),
            RiseIn(index: 2, child: _AccountsStrip(accounts: accounts)),
            const SizedBox(height: 22),
            RiseIn(
              index: 3,
              child: SectionHeader(
                title: l10n.recentTransactions,
                action: l10n.allCategories,
                onAction: () => context.go('/transactions'),
              ),
            ),
            const SizedBox(height: 12),
            const RiseIn(index: 3, child: _RecentTransactions()),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.dollar, Color(0xFF3E8E5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          email.isEmpty ? '·' : email[0].toUpperCase(),
          style: const TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.onBright),
        ),
      );
}

/// The "banknote" hero: total capital in the base currency.
class _CapitalCard extends ConsumerWidget {
  const _CapitalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final capital = ref.watch(capitalProvider);
    final status = ref.watch(syncStatusProvider).value;
    final lastSync = DateTime.tryParse(ref.watch(lastSyncAtProvider).value ?? '');
    final now = ref.watch(clockProvider).now();
    final (whole, fraction) = capital == null ? ('—', '') : context.moneyFormat.split(capital.total);

    final syncLabel = switch (status?.phase) {
      SyncPhase.syncing => l10n.syncing,
      SyncPhase.offline => l10n.offline,
      _ => lastSync == null ? l10n.notSyncedYet : DateText.ago(context, lastSync.toLocal(), now),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.6), blurRadius: 60, offset: const Offset(0, 24), spreadRadius: -24)],
      ),
      child: CustomPaint(
        painter: const _Guilloche(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(l10n.totalCapital, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.82))),
            const Spacer(),
            AppIcon(status?.phase == SyncPhase.offline ? 'cloud_off' : 'sync', size: 14, color: Colors.white.withValues(alpha: 0.82)),
            const SizedBox(width: 6),
            Text(syncLabel, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.82))),
          ]),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: whole, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
                TextSpan(text: fraction, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75))),
              ]),
              key: const Key('capital'),
              style: const TextStyle(fontFamily: 'Unbounded', color: Colors.white, letterSpacing: -0.7, fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
          if (capital != null && capital.missingRates.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(l10n.noRateFor(capital.missingRates.join(', ')),
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ]),
      ),
    );
  }
}

/// Fine concentric "banknote" lines in the corner of the hero.
class _Guilloche extends CustomPainter {
  const _Guilloche();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.07);
    final center = Offset(size.width * 1.15, -size.height * 0.2);
    for (var r = 9.0; r < size.width; r += 9) {
      canvas.drawCircle(center, r, paint);
    }
    paint.color = AppColors.dollar.withValues(alpha: 0.12);
    final second = Offset(-size.width * 0.2, size.height * 1.3);
    for (var r = 11.0; r < size.width * 0.7; r += 11) {
      canvas.drawCircle(second, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AccountsStrip extends StatelessWidget {
  const _AccountsStrip({required this.accounts});

  final List<AccountWithBalance> accounts;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    return SizedBox(
      height: 118,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          for (final a in accounts) ...[
            _AccountCard(account: a),
            const SizedBox(width: 10),
          ],
          Pressable(
            onTap: () => context.push('/accounts/new'),
            semanticLabel: l10n.addAccount,
            child: Container(
              width: accounts.isEmpty ? 160 : 76,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: c.outline)),
              alignment: Alignment.center,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AppIcon('plus', color: c.textSecondary),
                if (accounts.isEmpty) ...[
                  const SizedBox(height: 6),
                  Text(l10n.addAccount, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final AccountWithBalance account;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final a = account.account;
    final visual = accountVisual(a.type);
    final caption = switch (a) {
      AccountRow(creditLimit: final limit?) => '${a.name} · ${l10n.creditLimitShort(context.money(Money.of(limit, a.currency), compact: true))}',
      AccountRow(interestRatePercent: final rate?) => '${a.name} · ${l10n.interestShort(rate.replaceAll('.', ','))}',
      _ => a.name,
    };
    return Pressable(
      onTap: () => context.push('/accounts/${a.id}'),
      child: SizedBox(
        width: 148,
        child: SurfaceCard(
          radius: 20,
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconTile(icon: visual.icon, color: visual.color, size: 36, radius: 12, iconSize: 20),
            const Spacer(),
            Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.textSecondary)),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                context.money(account.money),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: account.balance < 0 ? c.expenseAccent : c.textPrimary),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RecentTransactions extends ConsumerWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recent = ref.watch(_recentProvider).value;
    final accounts = {for (final a in ref.watch(accountsProvider(includeArchived: true)).value ?? const <AccountWithBalance>[]) a.account.id: a.account};
    final categories = ref.watch(categoriesByIdProvider).value ?? const <String, CategoryRow>{};

    if (recent == null) return const SizedBox(height: 120);
    if (recent.isEmpty) return EmptyState(icon: 'list', title: l10n.noTransactionsYet, message: l10n.noTransactionsHint);

    return Column(children: [
      for (final t in recent) ...[
        TransactionTile(transaction: t, accounts: accounts, categories: categories, onTap: () => context.push('/transactions/${t.id}')),
        const SizedBox(height: 8),
      ],
    ]);
  }
}

final _recentProvider = StreamProvider<List<TransactionRow>>(
  (ref) => ref.watch(transactionsRepositoryProvider).watch(const TransactionQuery(limit: 5)),
);
