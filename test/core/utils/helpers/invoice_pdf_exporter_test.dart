import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:softverse/core/utils/helpers/invoice_pdf_exporter.dart';
import 'package:softverse/features/checkout/models/cart_item.dart';

void main() {
  late Directory documentsDirectory;

  setUpAll(() async {
    documentsDirectory = await Directory.systemTemp.createTemp(
      'softverse_invoice_pdf_test_',
    );
    PathProviderPlatform.instance = _FakePathProviderPlatform(
      documentsDirectory.path,
    );
  });

  tearDownAll(() async {
    await documentsDirectory.delete(recursive: true);
  });

  test('includes the merchant\'s real business name, address, and phone', () async {
    final file = await InvoicePdfExporter.exportInvoice(
      invoiceNumber: 'INV-1',
      customerName: 'Jane Doe',
      items: const [
        CartItem(name: 'Mouse', price: 20, imageUrl: '', quantity: 2),
      ],
      subtotal: 40,
      tax: 0,
      totalAmount: 40,
      amountReceived: 40,
      changeToReturn: 0,
      paymentLabel: 'Cash Payment',
      businessName: 'Softverse ERP2',
      businessAddress: '12 Main St',
      businessPhone: '+1 555-0100',
    );

    final text = latin1.decode(await file.readAsBytes(), allowInvalid: true);
    expect(text, contains('Softverse ERP2'));
    expect(text, contains('12 Main St'));
    expect(text, contains('Tel: +1 555-0100'));
    expect(text, isNot(contains('Softverse POS Invoice')));
  });

  test('shows amount due instead of received/change for a due sale', () async {
    final file = await InvoicePdfExporter.exportInvoice(
      invoiceNumber: 'INV-3',
      customerName: 'Jane Doe',
      items: const [
        CartItem(name: 'Test', price: 100, imageUrl: '', quantity: 2),
      ],
      subtotal: 200,
      tax: 0,
      totalAmount: 200,
      amountReceived: 200,
      changeToReturn: 0,
      paymentLabel: 'Due Payment',
    );

    final text = latin1.decode(await file.readAsBytes(), allowInvalid: true);
    expect(text, contains('Amount Due: \$200.00'));
    expect(text, isNot(contains('Amount Received')));
    expect(text, isNot(contains('Change to Return')));
    expect(text, contains('@ \$100.00'));
  });

  test('falls back to the generic name when the business has none set', () async {
    final file = await InvoicePdfExporter.exportInvoice(
      invoiceNumber: 'INV-2',
      customerName: 'Jane Doe',
      items: const [],
      subtotal: 0,
      tax: 0,
      totalAmount: 0,
      amountReceived: 0,
      changeToReturn: 0,
      paymentLabel: 'Cash Payment',
    );

    final text = latin1.decode(await file.readAsBytes(), allowInvalid: true);
    expect(text, contains('Softverse POS'));
    expect(text, isNot(contains('Tel:')));
  });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);

  final String _path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _path;

  @override
  Future<String?> getTemporaryPath() async => _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;

  @override
  Future<String?> getLibraryPath() async => _path;

  @override
  Future<String?> getExternalStoragePath() async => _path;

  @override
  Future<List<String>?> getExternalCachePaths() async => [_path];

  @override
  Future<List<String>?> getExternalStoragePaths({
    dynamic type,
  }) async => [_path];

  @override
  Future<String?> getDownloadsPath() async => _path;

  @override
  Future<String?> getApplicationCachePath() async => _path;
}
