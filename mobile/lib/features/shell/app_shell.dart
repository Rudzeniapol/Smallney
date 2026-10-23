import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';

/// Four tabs and the raised "+" in the middle (design/screens/TabBar).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      ('home_tab', l10n.tabHome),
      ('list', l10n.tabTransactions),
      ('pie', l10n.tabBudget),
      ('bars', l10n.tabAnalytics),
    ];

    Widget tab(int index) {
      final (icon, label) = tabs[index];
      final active = shell.currentIndex == index;
      final color = active ? c.accentText : c.textSecondary;
      return Expanded(
        child: Pressable(
          onTap: () => shell.goBranch(index, initialLocation: index == shell.currentIndex),
          semanticLabel: label,
          child: SizedBox(
            height: 52,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AppIcon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: Stack(clipBehavior: Clip.none, children: [
        // Only the background is clipped and blurred, so the raised "+" can stick out above the bar.
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: (dark ? const Color(0xFF0B0D12) : const Color(0xFFF4F5F1)).withValues(alpha: 0.82),
                  border: Border(top: BorderSide(color: c.outline)),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            height: 68,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              tab(0),
              tab(1),
              Expanded(child: Center(child: _AddButton(label: l10n.addTransaction))),
              tab(2),
              tab(3),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: () => context.push('/add'),
        semanticLabel: label,
        child: Transform.translate(
          offset: const Offset(0, -14),
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.fabGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: AppColors.dollar.withValues(alpha: 0.55), blurRadius: 30, offset: const Offset(0, 14), spreadRadius: -10)],
            ),
            child: const AppIcon('plus', size: 26, color: AppColors.onBright, stroke: 2.2),
          ),
        ),
      );
}
