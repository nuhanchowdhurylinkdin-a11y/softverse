import 'package:intl/intl.dart';

/// Names the business currency was stored as before ISO codes.
const _legacyCurrencies = {
  'DOLLAR': 'USD',
  'US DOLLAR': 'USD',
  'TAKA': 'BDT',
  'BANGLADESHI TAKA': 'BDT',
  'EURO': 'EUR',
  'POUND': 'GBP',
  'POUND STERLING': 'GBP',
  'RUPEE': 'INR',
  'INDIAN RUPEE': 'INR',
};

/// ISO 4217 code of the business currency ("BDT", or an old "Taka").
String currencyCode(String? currency) {
  final value = currency?.trim().toUpperCase() ?? '';
  if (value.isEmpty) return 'USD';
  return _legacyCurrencies[value] ?? value;
}

/// Symbol written before amounts ("\$", "৳", "CHF "), for any currency.
/// Letter symbols get a space so "CHF 12.00" doesn't run together.
String currencyDisplaySymbol(String? currency) {
  final code = currencyCode(currency);
  String symbol;
  try {
    symbol = NumberFormat.simpleCurrency(name: code).currencySymbol;
  } catch (_) {
    symbol = code;
  }
  if (symbol.isEmpty) symbol = code;
  return RegExp(r'[A-Za-z]$').hasMatch(symbol) ? '$symbol ' : symbol;
}

/// Printer-safe symbol: thermal printers' default code page only has
/// ASCII, so "€"/"৳" print as "EUR "/"Tk ".
String currencyPrintSymbol(String? currency) {
  final code = currencyCode(currency);
  if (code == 'BDT') return 'Tk ';
  final symbol = currencyDisplaySymbol(code);
  return RegExp(r'^[\x20-\x7E]+$').hasMatch(symbol) ? symbol : '$code ';
}
