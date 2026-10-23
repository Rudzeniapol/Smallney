import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/currency.dart';
import '../../core/money/exchange.dart';
import '../../core/money/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/time/clock.dart';
import '../../core/ui/app_icons.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/db/app_database.dart';
import '../../data/model/enums.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/transactions_repository.dart';
import '../common/data.dart';
import '../common/visuals.dart';
import 'amount_input.dart';
import 'pickers.dart';

/// Quick add (FAB) and editing of an operation: keypad open from the start, recent categories first,
/// the default account preselected — an expense takes three taps.
class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({super.key, this.initialType = TransactionType.expense, this.transactionId});

  final TransactionType initialType;

  /// Edit mode when set.
  final String? transactionId;

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

enum _Field { amount, toAmount }

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  late TransactionType _type = widget.initialType;
  String _amount = '';
  String _toAmount = '';
  bool _toAmountTouched = false;
  _Field _active = _Field.amount;
  String? _accountId;
  String? _toAccountId;
  String? _categoryId;
  DateTime? _date;
  String? _note;
  List<String> _tags = const [];
  TransactionRow? _editing;
  bool _loaded = false;
  bool _saving = false;

  bool get _isEdit => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) unawaited(_loadExisting());
  }

  Future<void> _loadExisting() async {
    final row = await ref.read(transactionsRepositoryProvider).watchOne(widget.transactionId!).first;
    if (row == null || !mounted) return;
    final accounts = await ref.read(accountsRepositoryProvider).watchAll(includeArchived: true).first;
    String currencyOf(String? id) => accounts.where((a) => a.account.id == id).firstOrNull?.account.currency ?? Currency.baseCode;
    setState(() {
      _editing = row;
      _type = row.type;
      _amount = AmountInput.fromMinor(row.amount, digits: Currency.of(currencyOf(row.accountId)).digits);
      _accountId = row.accountId;
      _toAccountId = row.toAccountId;
      if (row.toAmount != null) {
        _toAmount = AmountInput.fromMinor(row.toAmount!, digits: Currency.of(currencyOf(row.toAccountId)).digits);
        _toAmountTouched = true;
      }
      _categoryId = row.categoryId;
      _date = row.date;
      _note = row.note;
      _tags = row.tags;
      _loaded = true;
    });
  }

  AccountWithBalance? _find(List<AccountWithBalance> accounts, String? id) =>
      accounts.where((a) => a.account.id == id).firstOrNull;

  /// The preselected account: the default spending account, else the first one.
  String? _defaultAccount(List<AccountWithBalance> accounts, SettingsRow? settings) {
    if (accounts.isEmpty) return null;
    final preferred = settings?.defaultSpendingAccountId;
    return accounts.any((a) => a.account.id == preferred) ? preferred : accounts.first.account.id;
  }

  void _setType(TransactionType type) => setState(() {
        if (_type != type) _categoryId = null;
        _type = type;
        _active = _Field.amount;
      });

  void _press(String key, Currency currency, Currency? toCurrency) => setState(() {
        if (_active == _Field.toAmount && toCurrency != null) {
          _toAmount = AmountInput.press(_toAmount, key, digits: toCurrency.digits);
          _toAmountTouched = true;
        } else {
          _amount = AmountInput.press(_amount, key, digits: currency.digits);
        }
      });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final accounts = ref.watch(accountsProvider()).value ?? const <AccountWithBalance>[];
    final settings = ref.watch(settingsProvider).value;
    final rates = ref.watch(exchangeRatesProvider).value ?? ExchangeRates.empty;
    final today = ref.watch(clockProvider).today();

    if (_isEdit && !_loaded) return const Scaffold(body: SizedBox.shrink());

    _accountId ??= _defaultAccount(accounts, settings);
    final account = _find(accounts, _accountId);
    if (_type == TransactionType.transfer && (_toAccountId == null || _toAccountId == _accountId)) {
      _toAccountId = accounts.where((a) => a.account.id != _accountId).firstOrNull?.account.id;
    }
    final toAccount = _type == TransactionType.transfer ? _find(accounts, _toAccountId) : null;

    final currency = Currency.of(account?.account.currency ?? settings?.baseCurrency ?? Currency.baseCode);
    final toCurrency = toAccount == null ? null : Currency.of(toAccount.account.currency);
    final crossCurrency = toCurrency != null && toCurrency != currency;
    final amountMinor = AmountInput.toMinor(_amount, digits: currency.digits);

    // Suggest the credited amount at today's rate until the user types their own.
    if (crossCurrency && !_toAmountTouched) {
      final converted = rates.convert(Money(amountMinor, currency), toCurrency.code);
      _toAmount = converted == null || converted.isZero ? '' : AmountInput.fromMinor(converted.amount, digits: toCurrency.digits);
    }
    final toAmountMinor = crossCurrency ? AmountInput.toMinor(_toAmount, digits: toCurrency.digits) : amountMinor;

    final tint = switch (_type) {
      TransactionType.expense => AppColors.coral,
      TransactionType.income => AppColors.dollar,
      TransactionType.transfer => const Color(0xFF9C90FF),
    };
    final sign = switch (_type) {
      TransactionType.expense => '−',
      TransactionType.income => '+',
      TransactionType.transfer => '',
    };

    final canSave = !_saving &&
        account != null &&
        amountMinor > 0 &&
        (_type == TransactionType.transfer ? toAccount != null && toAccountMinorValid(crossCurrency, toAmountMinor) : _categoryId != null);

    final signedMoney = _type == TransactionType.expense ? -Money(amountMinor, currency) : Money(amountMinor, currency);
    final saveLabel = amountMinor > 0
        ? l10n.saveWithAmount(context.money(signedMoney, signed: _type == TransactionType.income))
        : l10n.save;

    return Scaffold(
      body: GlowBackground(
        tint: tint.withValues(alpha: 0.2),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(children: [
              Row(children: [
                SquareIconButton(icon: 'close', label: l10n.close, onTap: () => context.pop()),
                const SizedBox(width: 12),
                Expanded(child: _TypeSegments(type: _type, onChanged: _isEdit ? null : _setType)),
                if (_isEdit) ...[
                  const SizedBox(width: 12),
                  SquareIconButton(icon: 'trash', label: l10n.delete, onTap: _delete),
                ],
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _active = _Field.amount),
                child: _AmountDisplay(
                  sign: sign,
                  text: AmountInput.display(_amount),
                  symbol: currency.symbol,
                  color: _type == TransactionType.income ? c.income : c.textPrimary,
                  signColor: tint,
                  active: _active == _Field.amount || !crossCurrency,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
                if (_type != TransactionType.transfer)
                  _Chip(
                    icon: 'card',
                    label: account?.account.name ?? l10n.chooseAccount,
                    onTap: () => _pickAccount(accounts, (id) => _accountId = id),
                  ),
                _Chip(
                  icon: 'calendar',
                  label: DateText.shortDay(context, _date ?? today, today),
                  onTap: () => _pickDate(today),
                ),
                _Chip(
                  icon: 'note',
                  label: _note ?? (_tags.isEmpty ? l10n.note : _tags.map((t) => '#$t').join(' ')),
                  muted: _note == null && _tags.isEmpty,
                  onTap: _editNote,
                ),
              ]),
              const SizedBox(height: 16),
              Expanded(
                child: _type == TransactionType.transfer
                    ? _TransferSection(
                        from: account,
                        to: toAccount,
                        crossCurrency: crossCurrency,
                        toAmountText: AmountInput.display(_toAmount),
                        toCurrency: toCurrency,
                        toAmountActive: _active == _Field.toAmount,
                        onPickFrom: () => _pickAccount(accounts, (id) => _accountId = id),
                        onPickTo: () => _pickAccount(accounts.where((a) => a.account.id != _accountId).toList(), (id) => _toAccountId = id),
                        onTapToAmount: () => setState(() => _active = _Field.toAmount),
                      )
                    : _CategoryGrid(
                        kind: _type.categoryKind!,
                        selectedId: _categoryId,
                        onSelected: (id) => setState(() => _categoryId = id),
                      ),
              ),
              const SizedBox(height: 10),
              _Keypad(onKey: (key) => _press(key, currency, toCurrency)),
              const SizedBox(height: 10),
              PrimaryButton(
                label: saveLabel,
                busy: _saving,
                gradient: LinearGradient(colors: [tint, tint]),
                foreground: AppColors.onBright,
                onPressed: canSave ? () => _save(account.account, amountMinor, toAmountMinor, today) : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  bool toAccountMinorValid(bool crossCurrency, int toAmountMinor) => !crossCurrency || toAmountMinor > 0;

  Future<void> _pickAccount(List<AccountWithBalance> accounts, void Function(String id) apply) async {
    final id = await pickAccount(context, accounts);
    if (id != null) setState(() => apply(id));
  }

  Future<void> _pickDate(DateTime today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(today.year + 5),
    );
    if (picked != null) setState(() => _date = DateTime.utc(picked.year, picked.month, picked.day));
  }

  Future<void> _editNote() async {
    final result = await editNote(context, note: _note, tags: _tags);
    if (result != null) {
      setState(() {
        _note = result.note;
        _tags = result.tags;
      });
    }
  }

  Future<void> _save(AccountRow account, int amount, int toAmount, DateTime today) async {
    setState(() => _saving = true);
    final repository = ref.read(transactionsRepositoryProvider);
    final draft = TransactionDraft(
      type: _type,
      accountId: account.id,
      amount: amount,
      date: _date ?? today,
      categoryId: _type == TransactionType.transfer ? null : _categoryId,
      note: _note,
      tags: _tags,
      status: _editing?.status ?? TransactionStatus.cleared,
      toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
      toAmount: _type == TransactionType.transfer ? toAmount : null,
      savingsGoalId: _editing?.savingsGoalId,
      recurringRuleId: _editing?.recurringRuleId,
      recurrenceDate: _editing?.recurrenceDate,
    );
    if (_editing != null) {
      await repository.update(_editing!.id, draft);
    } else {
      await repository.create(draft);
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.savedOffline;
    context.pop(true);
    messenger.showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteTransactionConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true || _editing == null) return;
    await ref.read(transactionsRepositoryProvider).delete(_editing!.id);
    if (mounted) context.pop(true);
  }
}

class _TypeSegments extends StatelessWidget {
  const _TypeSegments({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final items = [
      (TransactionType.expense, l10n.expense, AppColors.coral),
      (TransactionType.income, l10n.income, AppColors.dollar),
      (TransactionType.transfer, l10n.transfer, const Color(0xFF9C90FF)),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.outline)),
      child: Row(children: [
        for (final (value, label, color) in items)
          Expanded(
            child: Semantics(
              selected: value == type,
              button: true,
              child: GestureDetector(
                onTap: onChanged == null ? null : () => onChanged!(value),
                child: AnimatedContainer(
                  duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 250),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: value == type ? color : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: Text(label,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: value == type ? AppColors.onBright : c.textSecondary)),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({
    required this.sign,
    required this.text,
    required this.symbol,
    required this.color,
    required this.signColor,
    required this.active,
  });

  final String sign;
  final String text;
  final String symbol;
  final Color color;
  final Color signColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const display = TextStyle(fontFamily: 'Unbounded', fontWeight: FontWeight.w600, letterSpacing: -1, fontFeatures: [FontFeature.tabularFigures()]);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (sign.isNotEmpty) Text(sign, style: display.copyWith(fontSize: 44, color: signColor)),
        Text(text, key: const Key('amount'), style: display.copyWith(fontSize: 52, color: color)),
        if (active) const _Caret(),
        const SizedBox(width: 10),
        Text(symbol, style: TextStyle(fontSize: 26, color: c.textSecondary, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _Caret extends StatefulWidget {
  const _Caret();

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion(context) && !_blink.isAnimating) _blink.repeat();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _blink,
        builder: (_, _) => Opacity(
          opacity: _blink.value < 0.5 ? 1 : 0,
          child: Container(
            width: 3,
            height: 44,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(color: AppColors.dollar, borderRadius: BorderRadius.circular(2)),
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.onTap, this.muted = false});

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = muted ? c.textSecondary : c.textPrimary;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.outline)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AppIcon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
          ),
        ]),
      ),
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid({required this.kind, required this.selectedId, required this.onSelected});

  final CategoryKind kind;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  static const visible = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final picks = ref.watch(_quickPicksProvider(kind)).value ?? const <CategoryRow>[];

    // The selected category is always visible, even if it is not among the recent ones.
    final shown = picks.take(visible).toList();
    final selected = picks.where((p) => p.id == selectedId).firstOrNull;
    if (selected != null && !shown.contains(selected)) shown[shown.length - 1] = selected;

    Widget cell({required String icon, required Color color, required String label, required bool isSelected, required VoidCallback onTap}) =>
        Pressable(
          onTap: onTap,
          semanticLabel: label,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: reduceMotion(context) ? Duration.zero : const Duration(milliseconds: 250),
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.tile(color),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: -2)] : null,
              ),
              child: AppIcon(icon, size: 24, color: isSelected ? AppColors.onBright : color),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? c.textPrimary : c.textSecondary)),
          ]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.recentFirst, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.textSecondary)),
      const SizedBox(height: 10),
      Expanded(
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 8,
          childAspectRatio: 0.92,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final category in shown)
              cell(
                icon: categoryVisual(category).icon,
                color: categoryVisual(category).color,
                label: category.name,
                isSelected: category.id == selectedId,
                onTap: () => onSelected(category.id),
              ),
            cell(
              icon: 'more',
              color: c.textSecondary,
              label: l10n.allCategories,
              isSelected: false,
              onTap: () async {
                final id = await pickCategory(context, kind, selectedId);
                if (id != null) onSelected(id);
              },
            ),
          ],
        ),
      ),
    ]);
  }
}

final _quickPicksProvider = StreamProvider.family<List<CategoryRow>, CategoryKind>(
  (ref, kind) => ref.watch(categoriesRepositoryProvider).watchQuickPicks(kind),
);

class _TransferSection extends StatelessWidget {
  const _TransferSection({
    required this.from,
    required this.to,
    required this.crossCurrency,
    required this.toAmountText,
    required this.toCurrency,
    required this.toAmountActive,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onTapToAmount,
  });

  final AccountWithBalance? from;
  final AccountWithBalance? to;
  final bool crossCurrency;
  final String toAmountText;
  final Currency? toCurrency;
  final bool toAmountActive;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onTapToAmount;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;

    Widget row(String label, AccountWithBalance? account, VoidCallback onTap) => Pressable(
          onTap: onTap,
          child: SurfaceCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Text(label, style: TextStyle(fontSize: 13, color: c.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  account == null ? l10n.chooseAccount : '${account.account.name} · ${account.account.currency}',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
        );

    return SingleChildScrollView(
      child: Column(children: [
        row(l10n.from, from, onPickFrom),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.ink.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: AppIcon('arrow_down', size: 18, color: c.accentText),
        ),
        const SizedBox(height: 8),
        row(l10n.to, to, onPickTo),
        if (crossCurrency && toCurrency != null) ...[
          const SizedBox(height: 10),
          Pressable(
            onTap: onTapToAmount,
            child: SurfaceCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: Border.all(color: toAmountActive ? AppColors.inkLight : c.outline),
              child: Row(children: [
                Text(l10n.creditedAmount(toCurrency!.code), style: TextStyle(fontSize: 13, color: c.textSecondary)),
                const Spacer(),
                Text('$toAmountText ${toCurrency!.symbol}', key: const Key('toAmount'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', AmountInput.decimal, '0', AmountInput.backspace];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final key in keys)
          Pressable(
            key: Key('key_$key'),
            onTap: () => onKey(key),
            semanticLabel: key == AmountInput.backspace ? 'backspace' : key,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16)),
              child: key == AmountInput.backspace
                  ? AppIcon('backspace', size: 24, color: c.textPrimary)
                  : Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
          ),
      ],
    );
  }
}
