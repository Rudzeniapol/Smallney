import 'package:flutter_test/flutter_test.dart';
import 'package:smallney/features/quick_add/amount_input.dart';

String type(String keys, {int digits = 2}) =>
    keys.split('').fold('', (text, key) => AmountInput.press(text, key == '<' ? AmountInput.backspace : key, digits: digits));

void main() {
  test('types digits and one decimal separator', () {
    expect(type('245'), '245');
    expect(type('24,5'), '24,5');
    expect(type(',5'), '0,5');
    expect(type('24,,5'), '24,5');
  });

  test('limits fraction digits by the currency', () {
    expect(type('24,567'), '24,56');
    expect(type('24,5', digits: 0), '245', reason: 'no decimals for JPY');
    expect(type('1,2345', digits: 3), '1,234');
  });

  test('no leading zeros, bounded length, backspace', () {
    expect(type('007'), '7');
    expect(type('1234567890123'), '123456789');
    expect(type('24,5<<'), '24');
    expect(type('<'), '');
  });

  test('converts to and from minor units', () {
    expect(AmountInput.toMinor('24,5', digits: 2), 2450);
    expect(AmountInput.toMinor('24,', digits: 2), 2400);
    expect(AmountInput.toMinor('', digits: 2), 0);
    expect(AmountInput.toMinor('1500', digits: 0), 1500);
    expect(AmountInput.fromMinor(2450, digits: 2), '24,5');
    expect(AmountInput.fromMinor(2400, digits: 2), '24');
    expect(AmountInput.fromMinor(5, digits: 2), '0,05');
  });

  test('groups thousands for display', () {
    expect(AmountInput.display('12480,5'), '12 480,5');
    expect(AmountInput.display(''), '0');
  });
}
