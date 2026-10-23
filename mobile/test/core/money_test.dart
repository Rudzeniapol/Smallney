import 'package:flutter_test/flutter_test.dart';
import 'package:rational/rational.dart';
import 'package:smallney/core/money/currency.dart';
import 'package:smallney/core/money/exchange.dart';
import 'package:smallney/core/money/money.dart';
import 'package:smallney/core/money/money_format.dart';

void main() {
  group('Money', () {
    test('arithmetic stays in one currency', () {
      expect(Money.of(1000, 'BYN') + Money.of(250, 'BYN'), Money.of(1250, 'BYN'));
      expect(Money.of(1000, 'BYN') - Money.of(250, 'BYN'), Money.of(750, 'BYN'));
      expect(-Money.of(5, 'BYN'), Money.of(-5, 'BYN'));
      expect(Money.of(-5, 'BYN').abs(), Money.of(5, 'BYN'));
      expect(() => Money.of(1, 'BYN') + Money.of(1, 'USD'), throwsStateError);
    });

    test('rounds half to even like the server', () {
      expect(roundHalfEven(Rational.parse('234.5')), BigInt.from(234));
      expect(roundHalfEven(Rational.parse('235.5')), BigInt.from(236));
      expect(roundHalfEven(Rational.parse('-234.5')), BigInt.from(-234));
      expect(roundHalfEven(Rational.parse('2.51')), BigInt.from(3));
      expect(Money.fromRational(Rational.parse('2.345'), Currency.byn).amount, 234);
      expect(Money.fromRational(Rational.parse('1234.5'), Currency.of('JPY')).amount, 1234);
    });

    test('allocate keeps every minor unit', () {
      expect(Money.of(1000, 'BYN').allocate(3).map((m) => m.amount), [334, 333, 333]);
      expect(Money.of(-1000, 'BYN').allocate(3).map((m) => m.amount), [-334, -333, -333]);
      expect(Money.of(2, 'BYN').allocate(5).fold<int>(0, (s, m) => s + m.amount), 2);
    });

    test('currencies know their digits and symbols', () {
      expect(Currency.of('KWD').digits, 3);
      expect(Currency.of('JPY').digits, 0);
      expect(Currency.byn.symbol, 'Br');
      expect(Currency.of('CHF').symbol, 'Fr');
      expect(Currency.of('SEK').symbol, 'SEK');
      expect(Currency.isSupported('XXX'), isFalse);
      expect(() => Currency.of('XXX'), throwsArgumentError);
    });
  });

  group('MoneyFormat', () {
    const ru = MoneyFormat();
    const en = MoneyFormat(locale: 'en');
    const nb = MoneyFormat.nbsp;

    test('formats as in the design', () {
      expect(ru.format(Money.of(1248035, 'BYN')), '12${nb}480,35${nb}Br');
      expect(ru.format(Money.of(-999, 'USD')), '−9,99$nb\$');
      expect(ru.format(Money.of(250000, 'BYN'), signed: true), '+2${nb}500,00${nb}Br');
      expect(ru.format(Money.of(290000, 'BYN'), compact: true), '2${nb}900${nb}Br');
      expect(ru.format(Money.of(1500, 'JPY')), '1${nb}500$nb¥');
      expect(en.format(Money.of(1248035, 'BYN')), '12,480.35${nb}Br');
    });

    test('splits the hero amount', () {
      expect(ru.split(Money.of(1248035, 'BYN')), ('12${nb}480', ',35${nb}Br'));
    });

    test('parses user input', () {
      expect(MoneyFormat.parse('1 234,5', Currency.byn), 123450);
      expect(MoneyFormat.parse('1234.50', Currency.byn), 123450);
      expect(MoneyFormat.parse('-15', Currency.byn), -1500);
      expect(MoneyFormat.parse('1,234', Currency.byn), isNull, reason: 'too many decimals');
      expect(MoneyFormat.parse('abc', Currency.byn), isNull);
      expect(MoneyFormat.parse('', Currency.byn), isNull);
    });

    test('editable text round-trips', () {
      expect(MoneyFormat.editable(123450, 2), '1234,5');
      expect(MoneyFormat.editable(-1500, 2), '-15');
      expect(MoneyFormat.parse(MoneyFormat.editable(98765, 2), Currency.byn), 98765);
    });
  });

  group('ExchangeRates', () {
    final rates = ExchangeRates({'USD': Rational.parse('3.0'), 'EUR': Rational.parse('3.5'), 'JPY': Rational.parse('0.020123')});

    test('converts through BYN and rounds once', () {
      expect(rates.convert(Money.of(10000, 'USD'), 'BYN'), Money.of(30000, 'BYN'));
      expect(rates.convert(Money.of(10000, 'BYN'), 'USD'), Money.of(3333, 'USD'));
      expect(rates.convert(Money.of(10000, 'USD'), 'EUR'), Money.of(8571, 'EUR'));
      expect(rates.convert(Money.of(10000, 'JPY'), 'BYN'), Money.of(20123, 'BYN'));
    });

    test('missing rates give null, same currency passes through', () {
      expect(rates.convert(Money.of(1, 'GBP'), 'BYN'), isNull);
      expect(ExchangeRates.empty.convert(Money.of(7, 'GBP'), 'GBP'), Money.of(7, 'GBP'));
      expect(rates.canConvert('USD', 'EUR'), isTrue);
      expect(rates.canConvert('USD', 'GBP'), isFalse);
    });
  });
}
