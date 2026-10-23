import 'package:flutter/material.dart';

import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';

/// Tabs whose screens arrive in later phases.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen.budget({super.key}) : _budget = true;

  const ComingSoonScreen.analytics({super.key}) : _budget = false;

  final bool _budget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlowBackground(
      child: SafeArea(
        child: Center(
          child: EmptyState(
            icon: _budget ? 'pie' : 'bars',
            title: l10n.comingSoonTitle,
            message: _budget ? l10n.comingSoonBudget : l10n.comingSoonAnalytics,
          ),
        ),
      ),
    );
  }
}
