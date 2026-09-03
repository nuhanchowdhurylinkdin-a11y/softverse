import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/features/checkout/models/cart_item.dart';
import 'package:softverse/features/printer/controller/printer_controller.dart';
import 'package:softverse/features/printer/models/printer_model.dart';

void main() {
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
    expect(documents.single.content, contains('Coffee x2'));
    expect(documents.single.content, contains('Total: \$11.00'));
    expect(documents.single.content, contains('Change: \$9.00'));
  });
}
