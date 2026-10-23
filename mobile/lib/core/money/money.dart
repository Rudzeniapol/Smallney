import 'package:rational/rational.dart';

import 'currency.dart';

/// Money is always integer minor units plus a currency. Doubles are never used for amounts.
class Money implements Comparable<Money> {
  const Money(this.amount, this.currency);

  Money.of(int amount, String code) : this(amount, Currency.of(code));

  factory Money.zero(String code) => Money(0, Currency.of(code));

  /// Minor units, e.g. kopecks.
  final int amount;
  final Currency currency;

  bool get isZero => amount == 0;
  bool get isNegative => amount < 0;

  Money operator +(Money other) {
    _ensureSame(other);
    return Money(amount + other.amount, currency);
  }

  Money operator -(Money other) {
    _ensureSame(other);
    return Money(amount - other.amount, currency);
  }

  Money operator -() => Money(-amount, currency);

  Money abs() => Money(amount.abs(), currency);

  /// Exact major-unit value.
  Rational toRational() => Rational(BigInt.from(amount), currency.factor);

  /// Rounds a major-unit value to minor units, half to even (as on the server).
  static Money fromRational(Rational value, Currency currency) =>
      Money(roundHalfEven(value * Rational(currency.factor)).toInt(), currency);

  /// Splits into [parts] that sum exactly to this amount; the remainder goes to the first parts.
  List<Money> allocate(int parts) {
    if (parts <= 0) throw ArgumentError.value(parts, 'parts');
    final share = amount ~/ parts;
    final remainder = amount.remainder(parts);
    final sign = remainder.sign;
    return [for (var i = 0; i < parts; i++) Money(share + (i < remainder.abs() ? sign : 0), currency)];
  }

  @override
  int compareTo(Money other) {
    _ensureSame(other);
    return amount.compareTo(other.amount);
  }

  void _ensureSame(Money other) {
    if (other.currency != currency) {
      throw StateError('Cannot combine ${currency.code} and ${other.currency.code} without conversion');
    }
  }

  @override
  bool operator ==(Object other) => other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => '$amount ${currency.code}';
}

/// Banker's rounding of a rational number to an integer.
BigInt roundHalfEven(Rational value) {
  final floor = value.floor();
  final fraction = value - Rational(floor);
  final half = Rational(BigInt.one, BigInt.two);
  if (fraction < half) return floor;
  if (fraction > half) return floor + BigInt.one;
  return floor.isEven ? floor : floor + BigInt.one;
}
