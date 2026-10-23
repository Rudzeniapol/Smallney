import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import '../money/money.dart';
import '../money/money_format.dart';
import '../time/dates.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeName => Localizations.localeOf(this).languageCode;

  MoneyFormat get moneyFormat => MoneyFormat(locale: localeName);

  String money(Money money, {bool signed = false, bool compact = false}) =>
      moneyFormat.format(money, signed: signed, compact: compact);
}

abstract final class DateText {
  /// "22 октября" / "22 October".
  static String dayMonth(BuildContext context, DateTime date) => DateFormat.MMMMd(context.localeName).format(date);

  /// "5 окт — 4 ноя".
  static String range(BuildContext context, DateTime from, DateTime to) {
    final f = DateFormat('d MMM', context.localeName);
    return '${f.format(from).replaceAll('.', '')} — ${f.format(to).replaceAll('.', '')}';
  }

  /// "Октябрь" — the month name in nominative case.
  static String monthName(BuildContext context, DateTime date) {
    final name = DateFormat.LLLL(context.localeName).format(date);
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }

  /// Group header of the transactions list.
  static String dayHeader(BuildContext context, DateTime date, DateTime today) {
    final label = dayMonth(context, date);
    if (Dates.sameDay(date, today)) return context.l10n.dayToday(label);
    if (Dates.sameDay(date, Dates.addDays(today, -1))) return context.l10n.dayYesterday(label);
    final weekday = DateFormat.EEEE(context.localeName).format(date);
    return '$label, $weekday';
  }

  /// "Сегодня" / "Вчера" / "20 окт".
  static String shortDay(BuildContext context, DateTime date, DateTime today) {
    if (Dates.sameDay(date, today)) return context.l10n.today;
    if (Dates.sameDay(date, Dates.addDays(today, -1))) return context.l10n.yesterday;
    return DateFormat('d MMM', context.localeName).format(date).replaceAll('.', '');
  }

  static String ago(BuildContext context, DateTime moment, DateTime now) {
    final diff = now.difference(moment);
    if (diff.inMinutes < 1) return context.l10n.justNow;
    if (diff.inHours < 1) return context.l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return context.l10n.hoursAgo(diff.inHours);
    return context.l10n.daysAgo(diff.inDays);
  }
}
