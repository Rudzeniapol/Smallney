import '../../core/money/money_format.dart';

/// Keypad editing of an amount kept as text ("24,5"). Pure, so it is unit-tested directly.
abstract final class AmountInput {
  static const backspace = 'back';
  static const decimal = ',';
  static const maxWholeDigits = 9;

  static String press(String current, String key, {required int digits}) {
    if (key == backspace) return current.isEmpty ? current : current.substring(0, current.length - 1);

    if (key == decimal) {
      if (digits == 0 || current.contains(decimal)) return current;
      return '${current.isEmpty ? '0' : current}$decimal';
    }

    if (!RegExp(r'^\d$').hasMatch(key)) return current;
    final parts = current.split(decimal);
    if (parts.length == 2 && parts[1].length >= digits) return current;
    if (parts.length == 1 && parts[0].length >= maxWholeDigits) return current;
    if (current == '0') return key;
    return '$current$key';
  }

  /// Minor units of the typed amount.
  static int toMinor(String text, {required int digits}) {
    if (text.isEmpty) return 0;
    final parts = text.split(decimal);
    final whole = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? 0;
    final fraction = parts.length > 1 ? parts[1].padRight(digits, '0').substring(0, digits) : ''.padRight(digits, '0');
    return whole * _pow10(digits) + (digits == 0 ? 0 : int.parse(fraction));
  }

  /// Text for editing an existing amount: 2450 → "24,5", 2400 → "24".
  static String fromMinor(int minor, {required int digits}) {
    final factor = _pow10(digits);
    final whole = minor ~/ factor;
    final fraction = (minor % factor).toString().padLeft(digits, '0').replaceFirst(RegExp(r'0+$'), '');
    return fraction.isEmpty ? '$whole' : '$whole$decimal$fraction';
  }

  /// "12 480,5" for display (thousands grouped with non-breaking spaces).
  static String display(String text) {
    if (text.isEmpty) return '0';
    final parts = text.split(decimal);
    final grouped = const MoneyFormat().formatNumber(int.tryParse(parts[0]) ?? 0, 0);
    return parts.length > 1 ? '$grouped$decimal${parts[1]}' : grouped;
  }

  static int _pow10(int digits) {
    var result = 1;
    for (var i = 0; i < digits; i++) {
      result *= 10;
    }
    return result;
  }
}
