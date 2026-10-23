import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/currency.dart';
import '../../core/money/money_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/time/clock.dart';
import '../../core/time/dates.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/model/enums.dart';
import '../../data/providers.dart';
import '../../data/repositories/accounts_repository.dart';
import '../common/visuals.dart';

class AccountEditScreen extends ConsumerStatefulWidget {
  const AccountEditScreen({super.key, this.accountId});

  final String? accountId;

  @override
  ConsumerState<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends ConsumerState<AccountEditScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _balance = TextEditingController();
  final _limit = TextEditingController();
  final _rate = TextEditingController();
  AccountType _type = AccountType.debitCard;
  String? _currency;
  bool _includeInTotals = true;
  bool _archived = false;
  CapitalizationPeriod _capitalization = CapitalizationPeriod.monthly;
  DateTime? _openDate;
  DateTime? _maturityDate;
  AccountDraft? _original;
  bool _hasTransactions = false;
  bool _loaded = false;
  bool _saving = false;

  bool get _isEdit => widget.accountId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = ref.read(accountsRepositoryProvider);
    if (!_isEdit) {
      final settings = await ref.read(settingsRepositoryProvider).get();
      setState(() {
        _currency = settings?.baseCurrency ?? Currency.baseCode;
        _loaded = true;
      });
      return;
    }
    final account = await repository.watchOne(widget.accountId!).first;
    final hasTransactions = await repository.hasTransactions(widget.accountId!);
    if (account == null || !mounted) return;
    final a = account.account;
    final digits = Currency.of(a.currency).digits;
    setState(() {
      _original = AccountDraft.of(a);
      _hasTransactions = hasTransactions;
      _name.text = a.name;
      _type = a.type;
      _currency = a.currency;
      _balance.text = a.initialBalance == 0 ? '' : MoneyFormat.editable(a.initialBalance, digits);
      _limit.text = a.creditLimit == null ? '' : MoneyFormat.editable(a.creditLimit!, digits);
      _rate.text = a.interestRatePercent?.replaceAll('.', ',') ?? '';
      _capitalization = a.capitalizationPeriod ?? CapitalizationPeriod.monthly;
      _openDate = a.openDate;
      _maturityDate = a.maturityDate;
      _includeInTotals = a.includeInTotals;
      _archived = a.isArchived;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    _limit.dispose();
    _rate.dispose();
    super.dispose();
  }

  Currency get _cur => Currency.of(_currency ?? Currency.baseCode);

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final rate = _rate.text.trim().replaceAll(',', '.');
    final draft = AccountDraft(
      name: _name.text,
      type: _type,
      currency: _cur.code,
      initialBalance: MoneyFormat.parse(_balance.text, _cur) ?? 0,
      includeInTotals: _includeInTotals,
      isArchived: _archived,
      sortOrder: _original?.sortOrder ?? 0,
      color: _original?.color,
      icon: _original?.icon,
      creditLimit: _type == AccountType.creditCard ? MoneyFormat.parse(_limit.text, _cur) : null,
      interestRatePercent: _type.supportsInterest && rate.isNotEmpty ? rate : null,
      capitalizationPeriod: _type.supportsInterest && rate.isNotEmpty ? _capitalization : null,
      openDate: _type.supportsInterest ? (_openDate ?? (rate.isNotEmpty ? ref.read(clockProvider).today() : null)) : null,
      maturityDate: _type.supportsInterest ? _maturityDate : null,
    );
    final repository = ref.read(accountsRepositoryProvider);
    if (_isEdit) {
      await repository.update(widget.accountId!, draft);
    } else {
      await repository.create(draft);
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final repository = ref.read(accountsRepositoryProvider);
    if (_hasTransactions) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.accountHasTransactions)));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteAccountConfirm(_name.text)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await repository.delete(widget.accountId!);
      if (mounted) context.pop();
    } on AccountHasTransactionsException {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.accountHasTransactions)));
    }
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    final today = ref.read(clockProvider).today();
    final picked = await showDatePicker(context: context, initialDate: initial ?? today, firstDate: DateTime.utc(1990), lastDate: DateTime.utc(today.year + 30));
    return picked == null ? null : Dates.of(picked.year, picked.month, picked.day);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    if (!_loaded) return const Scaffold(body: SizedBox.shrink());

    String? amountValidator(String? v, {bool required = false}) {
      if (v == null || v.trim().isEmpty) return required ? l10n.invalidAmount : null;
      return MoneyFormat.parse(v, _cur) == null ? l10n.invalidAmount : null;
    }

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 18),
          child: Text(text, style: TextStyle(fontSize: 13, color: c.textSecondary)),
        );

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
              Row(children: [
                SquareIconButton(icon: 'chevron_left', label: l10n.back, onTap: () => context.pop()),
                const SizedBox(width: 12),
                Expanded(child: Text(_isEdit ? l10n.editAccount : l10n.newAccount, style: Theme.of(context).textTheme.headlineSmall)),
                if (_isEdit) SquareIconButton(icon: 'trash', label: l10n.deleteAccount, onTap: _delete),
              ]),
              label(l10n.accountType),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final type in AccountType.values)
                  ChoiceButton(
                    label: accountTypeLabel(context, type),
                    selected: _type == type,
                    radius: 14,
                    height: 44,
                    onTap: () => setState(() => _type = type),
                  ),
              ]),
              label(l10n.accountName),
              TextFormField(
                controller: _name,
                maxLength: 100,
                decoration: const InputDecoration(counterText: ''),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.nameRequired : null,
              ),
              label(l10n.currency),
              _CurrencyPicker(
                value: _cur.code,
                locked: _hasTransactions,
                onChanged: (code) => setState(() => _currency = code),
              ),
              label(l10n.initialBalance),
              TextFormField(
                controller: _balance,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(hintText: '0', suffixText: _cur.symbol),
                validator: amountValidator,
              ),
              if (_type == AccountType.creditCard) ...[
                label(l10n.creditLimit),
                TextFormField(
                  controller: _limit,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(hintText: '0', suffixText: _cur.symbol),
                  validator: amountValidator,
                ),
              ],
              if (_type.supportsInterest) ...[
                label(l10n.interestRate),
                TextFormField(
                  controller: _rate,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: '0', suffixText: '%'),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final value = double.tryParse(v.trim().replaceAll(',', '.'));
                    return value == null || value < 0 || value > 100 ? l10n.invalidAmount : null;
                  },
                ),
                if (_rate.text.trim().isNotEmpty) ...[
                  label(l10n.capitalization),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final (period, text) in [
                      (CapitalizationPeriod.monthly, l10n.capMonthly),
                      (CapitalizationPeriod.quarterly, l10n.capQuarterly),
                      (CapitalizationPeriod.atEnd, l10n.capAtEnd),
                      (CapitalizationPeriod.none, l10n.capNone),
                    ])
                      ChoiceButton(label: text, selected: _capitalization == period, onTap: () => setState(() => _capitalization = period)),
                  ]),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: _DateField(
                      label: l10n.openDate,
                      value: _openDate,
                      onTap: () async {
                        final d = await _pickDate(_openDate);
                        if (d != null) setState(() => _openDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: l10n.maturityDate,
                      value: _maturityDate,
                      onTap: () async {
                        final d = await _pickDate(_maturityDate ?? _openDate);
                        if (d != null) setState(() => _maturityDate = d);
                      },
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                value: _includeInTotals,
                onChanged: (v) => setState(() => _includeInTotals = v),
                title: Text(l10n.includeInTotals),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              if (_isEdit)
                SwitchListTile(
                  value: _archived,
                  onChanged: (v) => setState(() => _archived = v),
                  title: Text(l10n.archived),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              const SizedBox(height: 20),
              PrimaryButton(label: l10n.save, busy: _saving, onPressed: _save),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Pressable(
      onTap: onTap,
      child: SurfaceCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          const SizedBox(height: 4),
          Text(value == null ? context.l10n.notSet : '${DateText.dayMonth(context, value!)} ${value!.year}',
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.value, required this.onChanged, this.locked = false});

  final String value;
  final bool locked;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = {...Currency.popular, value}.toList();
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final code in options)
        Opacity(
          opacity: locked && code != value ? 0.4 : 1,
          child: ChoiceButton(
            label: '${Currency.of(code).symbol == code ? '' : '${Currency.of(code).symbol} '}$code',
            selected: code == value,
            onTap: locked ? () {} : () => onChanged(code),
          ),
        ),
      if (!locked)
        ChoiceButton(
          label: '…',
          selected: false,
          onTap: () async {
            final picked = await showAppSheet<String>(context, (context) => _AllCurrencies(selected: value));
            if (picked != null) onChanged(picked);
          },
        ),
    ]);
  }
}

class _AllCurrencies extends StatelessWidget {
  const _AllCurrencies({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context) {
    final codes = Currency.codes.toList()..sort();
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, controller) => ListView.builder(
          controller: controller,
          itemCount: codes.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(codes[i]),
            trailing: Text(Currency.of(codes[i]).symbol),
            selected: codes[i] == selected,
            onTap: () => Navigator.pop(context, codes[i]),
          ),
        ),
      ),
    );
  }
}
