import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/currency.dart';
import '../../core/money/money_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/auth/session.dart';
import '../../data/model/enums.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';
import '../common/visuals.dart';
import 'onboarding_widgets.dart';

/// Steps 2 and 3 after registration: base currency and month start, then the first account.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _step = 2;
  String _currency = Currency.baseCode;
  int _day = 1;
  AccountType _type = AccountType.debitCard;
  final _name = TextEditingController();
  bool _named = false;
  final _balance = TextEditingController();
  bool _busy = false;

  static const _currencies = ['BYN', 'USD', 'EUR', 'RUB'];
  static const _types = [AccountType.debitCard, AccountType.cash, AccountType.savings, AccountType.creditCard];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_named) {
      _name.text = context.l10n.defaultAccountName;
      _named = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _busy = true);
    final accountId = await ref.read(accountsRepositoryProvider).create(AccountDraft(
          name: _name.text.trim().isEmpty ? context.l10n.defaultAccountName : _name.text,
          type: _type,
          currency: _currency,
          initialBalance: MoneyFormat.parse(_balance.text, Currency.of(_currency)) ?? 0,
        ));
    await ref.read(settingsRepositoryProvider).update(
          baseCurrency: _currency,
          firstDayOfMonth: _day,
          defaultSpendingAccountId: _type == AccountType.savings ? const Value.absent() : Value(accountId),
        );
    await ref.read(sessionProvider.notifier).completeSetup();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    final body = _step == 2
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.setupTitle, style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(l10n.setupSubtitle, style: text.bodyMedium?.copyWith(color: c.textSecondary, fontSize: 15)),
            const SizedBox(height: 20),
            Row(children: [
              for (final code in _currencies) ...[
                Expanded(
                  child: _CurrencyTile(code: code, selected: code == _currency, onTap: () => setState(() => _currency = code)),
                ),
                if (code != _currencies.last) const SizedBox(width: 8),
              ],
            ]),
            const SizedBox(height: 20),
            Text(l10n.monthStarts, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 28,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final day = i + 1;
                  final selected = day == _day;
                  return Pressable(
                    onTap: () => setState(() => _day = day),
                    child: AnimatedContainer(
                      duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 200),
                      width: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.dollar : c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? AppColors.dollar : c.outline),
                      ),
                      child: Text('$day',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: selected ? AppColors.onBright : c.textSecondary)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(_day == 1 ? l10n.calendarMonth : l10n.monthFromDay(_day, _day - 1), style: text.bodySmall),
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.firstAccountTitle, style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(l10n.firstAccountSubtitle, style: text.bodyMedium?.copyWith(color: c.textSecondary, fontSize: 15)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final type in _types)
                ChoiceButton(
                  label: accountTypeLabel(context, type),
                  selected: type == _type,
                  radius: 14,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () => setState(() => _type = type),
                ),
            ]),
            const SizedBox(height: 16),
            FieldLabel(l10n.accountName),
            TextField(controller: _name),
            const SizedBox(height: 14),
            FieldLabel(l10n.currentBalance(_currency)),
            TextField(
              controller: _balance,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(hintText: '0', suffixText: Currency.of(_currency).symbol),
            ),
          ]);

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [
            const BanknotesIllustration(height: 200),
            StepDots(step: _step),
            const SizedBox(height: 20),
            RiseIn(key: ValueKey(_step), child: body),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _step == 2 ? l10n.next : l10n.finish,
              busy: _busy,
              onPressed: _step == 2 ? () => setState(() => _step = 3) : _finish,
            ),
            if (_step == 3)
              TextButton(onPressed: () => setState(() => _step = 2), child: Text(l10n.back, style: TextStyle(color: c.accentText))),
          ]),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.code, required this.selected, required this.onTap});

  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: selected ? AppColors.ink.withValues(alpha: 0.22) : c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.inkLight : c.outline),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(Currency.of(code).symbol,
              style: TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w700, fontSize: 18, color: selected ? c.textPrimary : c.textSecondary)),
          const SizedBox(height: 2),
          Text(code, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? c.textPrimary : c.textSecondary)),
        ]),
      ),
    );
  }
}
