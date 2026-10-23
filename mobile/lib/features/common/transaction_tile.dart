import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/db/app_database.dart';
import '../../data/model/enums.dart';
import 'visuals.dart';

/// One operation row: category tile, title, subtitle, signed amount. Planned ones get a dashed gold border.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.accounts,
    required this.categories,
    this.onTap,
  });

  final TransactionRow transaction;
  final Map<String, AccountRow> accounts;
  final Map<String, CategoryRow> categories;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final t = transaction;
    final account = accounts[t.accountId];
    final category = t.categoryId == null ? null : categories[t.categoryId];
    final transfer = t.type == TransactionType.transfer;
    final planned = t.status == TransactionStatus.planned;
    final visual = transfer ? (icon: 'swap', color: const Color(0xFF9C90FF)) : categoryVisual(category);

    final title = t.note ?? (transfer ? l10n.transfer : category?.name ?? '—');
    final subtitle = planned
        ? l10n.planned
        : transfer
            ? '${account?.name ?? '—'} → ${accounts[t.toAccountId]?.name ?? '—'}'
            : [if (t.note != null) category?.name, account?.name].whereType<String>().join(' · ');

    final money = Money.of(t.amount, account?.currency ?? 'BYN');
    final amount = switch (t.type) {
      TransactionType.income => context.money(money, signed: true),
      TransactionType.expense => context.money(-money),
      TransactionType.transfer => context.money(money),
    };
    final amountColor = switch (t.type) {
      TransactionType.income => c.income,
      TransactionType.transfer => c.transfer,
      TransactionType.expense => c.textPrimary,
    };

    return Pressable(
      onTap: onTap,
      child: CustomPaint(
        foregroundPainter: planned ? _DashedBorder(color: AppColors.gold.withValues(alpha: 0.55)) : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: planned ? null : Border.all(color: c.outline),
          ),
          child: Row(children: [
            IconTile(icon: visual.icon, color: visual.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: planned ? c.warning : c.textSecondary)),
                ],
              ]),
            ),
            const SizedBox(width: 8),
            Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: amountColor)),
          ]),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}
