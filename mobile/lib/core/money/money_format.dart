import 'currency.dart';
import 'money.dart';

/// Formats money the way the design specifies: "12 480,35 Br", "−9,99 $".
/// Non-breaking spaces between thousands, U+2212 minus, symbol after the amount.
class MoneyFormat {
  const MoneyFormat({this.locale = 'ru'});

  final String locale;

  static const String nbsp = ' ';
  static const String minus = '−';

  String get _decimal => locale.startsWith('en') ? '.' : ',';
  String get _group => locale.startsWith('en') ? ',' : nbsp;

  /// [signed]: "+" for positive amounts too. [compact]: drop a zero fraction ("2 900 Br").
  String format(Money money, {bool signed = false, bool compact = false, bool symbol = true}) {
    final negative = money.amount < 0;
    final number = formatNumber(money.amount.abs(), money.currency.digits, compact: compact);
    final sign = negative ? minus : (signed && money.amount > 0 ? '+' : '');
    return symbol ? '$sign$number$nbsp${money.currency.symbol}' : '$sign$number';
  }

  /// Integer and fraction parts separately, for the hero "12 480" + ",35 Br" layout.
  (String whole, String fraction) split(Money money) {
    final full = format(money);
    final index = full.lastIndexOf(_decimal);
    if (index < 0) return (full, '');
    return (full.substring(0, index), full.substring(index));
  }

  String formatNumber(int minor, int digits, {bool compact = false}) {
    final factor = BigInt.from(10).pow(digits).toInt();
    final whole = minor ~/ factor;
    final fraction = minor % factor;
    final grouped = _groupDigits(whole.toString());
    if (digits == 0 || (compact && fraction == 0)) return grouped;
    return '$grouped$_decimal${fraction.toString().padLeft(digits, '0')}';
  }

  String _groupDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(_group);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Plain text for an input field: 123450 → "1234,5", no grouping (round-trips through [parse]).
  static String editable(int minor, int digits) {
    final negative = minor < 0;
    final factor = BigInt.from(10).pow(digits).toInt();
    final whole = minor.abs() ~/ factor;
    final fraction = (minor.abs() % factor).toString().padLeft(digits, '0').replaceFirst(RegExp(r'0+$'), '');
    return '${negative ? '-' : ''}$whole${fraction.isEmpty ? '' : ',$fraction'}';
  }

  /// Parses user input like "1 234,5" or "1234.50" into minor units; null if invalid.
  static int? parse(String input, Currency currency) {
    final cleaned = input.replaceAll(RegExp(r'[\s  ]'), '').replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    final match = RegExp(r'^-?\d+(\.\d+)?$').firstMatch(cleaned);
    if (match == null) return null;
    final negative = cleaned.startsWith('-');
    final parts = cleaned.replaceFirst('-', '').split('.');
    final fraction = parts.length > 1 ? parts[1] : '';
    if (fraction.length > currency.digits) return null;
    final minor = int.parse(parts[0]) * currency.factor.toInt() +
        (fraction.isEmpty ? 0 : int.parse(fraction.padRight(currency.digits, '0')));
    return negative ? -minor : minor;
  }
}
