import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/formatters.dart';
import '../../data/db/app_database.dart';
import '../../data/model/enums.dart';

/// Icon and color of a category; unknown icons fall back to "other".
({String icon, Color color}) categoryVisual(CategoryRow? category) => (
      icon: AppIcons.has(category?.icon) ? category!.icon! : 'other',
      color: AppColors.parse(category?.color),
    );

/// Accounts are drawn by type, tinted like the home cards of the design.
({String icon, Color color}) accountVisual(AccountType type) => switch (type) {
      AccountType.cash => (icon: 'cash_note', color: AppColors.sky),
      AccountType.debitCard => (icon: 'card', color: const Color(0xFF9C90FF)),
      AccountType.creditCard => (icon: 'credit_card', color: AppColors.coral),
      AccountType.savings => (icon: 'target', color: AppColors.gold),
      AccountType.deposit => (icon: 'bank', color: AppColors.dollar),
      AccountType.investment => (icon: 'invest', color: const Color(0xFFC58BFF)),
    };

String accountTypeLabel(BuildContext context, AccountType type) {
  final l10n = context.l10n;
  return switch (type) {
    AccountType.cash => l10n.accountTypeCash,
    AccountType.debitCard => l10n.accountTypeDebitCard,
    AccountType.creditCard => l10n.accountTypeCreditCard,
    AccountType.savings => l10n.accountTypeSavings,
    AccountType.deposit => l10n.accountTypeDeposit,
    AccountType.investment => l10n.accountTypeInvestment,
  };
}
