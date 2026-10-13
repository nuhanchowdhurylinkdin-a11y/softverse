import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/core/utils/helpers/currency.dart';

void main() {
  test('old currency names read as ISO codes', () {
    expect(currencyCode('Dollar'), 'USD');
    expect(currencyCode('Taka'), 'BDT');
    expect(currencyCode(null), 'USD');
    expect(currencyCode('xof'), 'XOF');
  });

  test('any currency gets its symbol', () {
    expect(currencyDisplaySymbol('USD'), r'$');
    expect(currencyDisplaySymbol('BDT'), '৳');
    expect(currencyDisplaySymbol('INR'), '₹');
    expect(currencyDisplaySymbol('Euro'), '€');
    expect(currencyDisplaySymbol('CHF'), 'CHF ');
  });

  test('printed symbols stay ASCII', () {
    expect(currencyPrintSymbol('USD'), r'$');
    expect(currencyPrintSymbol('BDT'), 'Tk ');
    expect(currencyPrintSymbol('EUR'), 'EUR ');
    expect(currencyPrintSymbol('INR'), 'INR ');
  });
}
