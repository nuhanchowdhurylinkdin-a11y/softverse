import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softverse/core/services/offline_database_service.dart';
import 'package:softverse/core/services/storage_service.dart';
import 'package:softverse/features/checkout/models/cart_item.dart';
import 'package:softverse/features/printer/controller/printer_controller.dart';
import 'package:softverse/features/printer/models/printer_model.dart';

void main() {
  late Directory databaseDirectory;

  setUpAll(() async {
    databaseDirectory = await Directory.systemTemp.createTemp(
      'softverse_virtual_printer_test_',
    );
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await OfflineDatabaseService.init(
      testPath: databaseDirectory.path,
      boxSuffix: '_virtual_printer_test',
    );
    await StorageService.saveUserSession(
      id: 'user-id',
      fullName: 'Owner',
      email: 'owner@example.com',
      accessToken: 'token',
      refreshToken: 'refresh',
      role: 'owner',
      businessId: 'business-id',
      permissions: const [],
    );
  });

  tearDownAll(() async {
    await OfflineDatabaseService.closeForTesting();
    await databaseDirectory.delete(recursive: true);
  });

  const virtualPrinter = PrinterModel(
    id: 'virtual-printer',
    name: 'Development Printer',
    printerModel: PrinterModel.virtualModel,
    category: 'Receipt Printer',
    connectionType: PrinterModel.virtualConnection,
    macAddress: 'virtual://softverse',
    startTime: '',
    closeTime: '',
    isConnected: true,
    isDefault: true,
    printReceiptAndBills: true,
    printOrders: false,
    paperSize: '80mm',
    printDensity: 'Medium',
    autoCut: false,
  );

  test('virtual printer survives cache serialization', () {
    final restored = PrinterModel.fromJson(virtualPrinter.toJson());

    expect(restored.isVirtual, isTrue);
    expect(restored.printerModel, PrinterModel.virtualModel);
    expect(restored.macAddress, 'virtual://softverse');
  });

  test('BLE printer survives cache serialization', () {
    final blePrinter = virtualPrinter.copyWith(
      connectionType: PrinterModel.bleConnection,
      macAddress: 'AA:BB:CC:DD:EE:FF',
      isConnected: false,
    );

    final restored = PrinterModel.fromJson(blePrinter.toJson());

    expect(restored.isBle, isTrue);
    expect(restored.isVirtual, isFalse);
    expect(restored.macAddress, 'AA:BB:CC:DD:EE:FF');
  });

  test('virtual print test produces a preview without Bluetooth', () async {
    final documents = <VirtualPrintDocument>[];
    final controller = PrinterController(
      virtualPrintPresenter: (document) async => documents.add(document),
    );

    final result = await controller.printTest(virtualPrinter);

    expect(result, isTrue);
    expect(documents, hasLength(1));
    expect(documents.single.title, 'Virtual printer test');
    expect(documents.single.content, contains('PRINTER TEST PAGE'));
    expect(documents.single.content, contains('Paper size: 80mm'));
  });

  test('virtual receipt contains checkout totals and items', () async {
    final documents = <VirtualPrintDocument>[];
    final controller = PrinterController(
      virtualPrintPresenter: (document) async => documents.add(document),
    )..printers.add(virtualPrinter);

    final result = await controller.printReceipt(
      invoiceNumber: 'INV-1001',
      customerName: 'Walk-in Customer',
      orderId: 'ORDER-9',
      dateTime: DateTime(2026, 9, 26, 14, 30),
      items: const [
        CartItem(
          itemId: 'item-1',
          name: 'Coffee',
          price: 5,
          imageUrl: '',
          quantity: 2,
        ),
      ],
      subtotal: 10,
      tax: 1,
      totalAmount: 11,
      amountReceived: 20,
      changeToReturn: 9,
      paymentLabel: 'Cash',
    );

    expect(result, isTrue);
    expect(documents, hasLength(1));
    expect(documents.single.title, 'Receipt INV-1001');
    expect(documents.single.content, contains('Coffee  x2'));
    expect(documents.single.content, contains('@ \$5.00'));
    expect(documents.single.content, contains('Total: \$11.00'));
    expect(documents.single.content, contains('Change: \$9.00'));
    expect(documents.single.content, contains('26 Sep 2026'));
    // The order number must only be printed once, not once unlabeled and
    // once again as a bare duplicate.
    expect('INV-1001'.allMatches(documents.single.content).length, 1);
  });

  test('virtual receipt hides received/change for a due sale', () async {
    final documents = <VirtualPrintDocument>[];
    final controller = PrinterController(
      virtualPrintPresenter: (document) async => documents.add(document),
    )..printers.add(virtualPrinter);

    await controller.printReceipt(
      invoiceNumber: 'INV-1003',
      customerName: 'Daniel Jean',
      orderId: 'INV-1003',
      dateTime: DateTime(2026, 9, 26, 14, 30),
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

    final content = documents.single.content;
    expect(content, contains('Amount due: \$200.00'));
    expect(content, isNot(contains('Received:')));
    expect(content, isNot(contains('Change:')));
  });

  test('virtual receipt includes the configured header and footer', () async {
    await OfflineDatabaseService.saveCache('business_profile', {
      'businessName': 'Louis Cafe',
      'receiptHeader': 'Welcome!',
      'receiptFooter': 'See you again',
    });

    final documents = <VirtualPrintDocument>[];
    final controller = PrinterController(
      virtualPrintPresenter: (document) async => documents.add(document),
    )..printers.add(virtualPrinter);

    await controller.printReceipt(
      invoiceNumber: 'INV-1002',
      customerName: 'Walk-in Customer',
      orderId: 'ORDER-10',
      dateTime: DateTime(2026, 9, 26, 14, 30),
      items: const [],
      subtotal: 0,
      tax: 0,
      totalAmount: 0,
      amountReceived: 0,
      changeToReturn: 0,
      paymentLabel: 'Cash',
    );

    expect(documents.single.content, contains('Welcome!'));
    expect(documents.single.content, contains('Louis Cafe'));
    expect(documents.single.content, contains('See you again'));
  });
}
