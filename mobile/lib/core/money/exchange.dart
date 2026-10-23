import 'package:rational/rational.dart';

import 'currency.dart';
import 'money.dart';

/// Latest known official rates: BYN per one unit of a currency. All conversions go through BYN,
/// rounding once at the end — the same rule as the server.
class ExchangeRates {
  ExchangeRates(Map<String, Rational> ratesToByn) : _rates = {...ratesToByn, Currency.baseCode: Rational.one};

  static final ExchangeRates empty = ExchangeRates(const {});

  final Map<String, Rational> _rates;

  bool canConvert(String from, String to) => from == to || (_rates.containsKey(from) && _rates.containsKey(to));

  /// Null when a rate is missing.
  Money? convert(Money money, String to) {
    if (money.currency.code == to) return money;
    final from = _rates[money.currency.code];
    final target = _rates[to];
    if (from == null || target == null) return null;
    return Money.fromRational(money.toRational() * from / target, Currency.of(to));
  }

  static Rational parseRate(String value) => Rational.parse(value);
}
