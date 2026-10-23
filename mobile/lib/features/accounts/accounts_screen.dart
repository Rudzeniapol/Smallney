import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/repositories/accounts_repository.dart';
import '../common/data.dart';
import '../common/visuals.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final accounts = ref.watch(accountsProvider(includeArchived: _showArchived)).value ?? const <AccountWithBalance>[];

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
            Row(children: [
              SquareIconButton(icon: 'chevron_left', label: l10n.back, onTap: () => context.pop()),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.accountsTitle, style: Theme.of(context).textTheme.headlineSmall)),
              SquareIconButton(icon: 'plus', label: l10n.newAccount, onTap: () => context.push('/accounts/new')),
            ]),
            const SizedBox(height: 20),
            if (accounts.isEmpty)
              EmptyState(icon: 'card', title: l10n.noAccountsTitle, action: l10n.addAccount, onAction: () => context.push('/accounts/new')),
            if (accounts.isNotEmpty)
              SurfaceCard(
                padding: EdgeInsets.zero,
                radius: 24,
                child: Column(children: [
                  for (final (i, a) in accounts.indexed) ...[
                    if (i > 0) Divider(height: 1, color: c.divider),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: IconTile(icon: accountVisual(a.account.type).icon, color: accountVisual(a.account.type).color, size: 40),
                      title: Text(a.account.name, style: TextStyle(color: a.account.isArchived ? c.textSecondary : c.textPrimary)),
                      subtitle: Text(
                        a.account.isArchived ? l10n.archived : accountTypeLabel(context, a.account.type),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Text(
                        context.money(a.money),
                        style: TextStyle(fontWeight: FontWeight.w600, color: a.balance < 0 ? c.expenseAccent : c.textPrimary),
                      ),
                      onTap: () => context.push('/accounts/${a.account.id}'),
                    ),
                  ],
                ]),
              ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _showArchived,
              onChanged: (v) => setState(() => _showArchived = v),
              title: Text(l10n.showArchived),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ]),
        ),
      ),
    );
  }
}
