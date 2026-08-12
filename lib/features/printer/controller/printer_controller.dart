import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../checkout/models/cart_item.dart';
import '../models/printer_model.dart';

class PrinterController extends GetxController {
  static const _cacheKey = 'saved_printers';

  final printers = <PrinterModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrinters();
  }

  int _indexOf(String id) => printers.indexWhere((p) => p.id == id);

  void _update(String id, PrinterModel Function(PrinterModel) updater) {
    final index = _indexOf(id);
    if (index == -1) return;
    printers[index] = updater(printers[index]);
    _persist();
  }

  void _loadPrinters() {
    final cached = OfflineDatabaseService.readCache<List<dynamic>>(_cacheKey);
    if (cached == null) return;
    printers.assignAll(
      cached.whereType<Map>().map(
        (json) => PrinterModel.fromJson(
          Map<String, dynamic>.from(json),
        ).copyWith(isConnected: false),
      ),
    );
  }

  Future<void> _persist() {
    final saved = printers
        .map((printer) => printer.copyWith(isConnected: false).toJson())
        .toList();
    return OfflineDatabaseService.saveCache(_cacheKey, saved);
  }

  void addPrinter(PrinterModel printer) {
    final shouldBeDefault = printer.isDefault || printers.isEmpty;
    final savedPrinter = printer.copyWith(isDefault: shouldBeDefault);
    if (shouldBeDefault) {
      printers.assignAll(
        printers.map((p) => p.copyWith(isDefault: false)).toList(),
      );
    }
    final existingIndex = printers.indexWhere(
      (p) => p.macAddress == savedPrinter.macAddress,
    );
    if (existingIndex == -1) {
      printers.add(savedPrinter);
    } else {
      printers[existingIndex] = savedPrinter.copyWith(
        id: printers[existingIndex].id,
      );
    }
    _persist();
  }

  void removePrinter(String id) {
    final wasDefault = printers.firstWhereOrNull((p) => p.id == id)?.isDefault;
    printers.removeWhere((p) => p.id == id);
    if (wasDefault == true && printers.isNotEmpty) {
      printers[0] = printers[0].copyWith(isDefault: true);
    }
    _persist();
  }

  void setDefault(String id) {
    printers.assignAll(
      printers.map((p) => p.copyWith(isDefault: p.id == id)).toList(),
    );
    _persist();
  }

  void togglePrintReceiptAndBills(String id) => _update(
    id,
    (p) => p.copyWith(printReceiptAndBills: !p.printReceiptAndBills),
  );

  void togglePrintOrders(String id) =>
      _update(id, (p) => p.copyWith(printOrders: !p.printOrders));

  void toggleAutoCut(String id) =>
      _update(id, (p) => p.copyWith(autoCut: !p.autoCut));

  void toggleDefault(String id) {
    final index = _indexOf(id);
    if (index == -1) return;
    final printer = printers[index];
    if (printer.isDefault) {
      _update(id, (p) => p.copyWith(isDefault: false));
    } else {
      setDefault(id);
    }
  }

  void setPaperSize(String id, String size) =>
      _update(id, (p) => p.copyWith(paperSize: size));

  void setPrintDensity(String id, String density) =>
      _update(id, (p) => p.copyWith(printDensity: density));

  PrinterModel? get receiptPrinter {
    return printers.firstWhereOrNull(
          (printer) => printer.isDefault && printer.printReceiptAndBills,
        ) ??
        printers.firstWhereOrNull((printer) => printer.printReceiptAndBills);
  }

  Future<bool> connectToPrinter(PrinterModel printer) async {
    if (printer.macAddress.isEmpty) return false;
    final connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: printer.macAddress,
    );
    _update(printer.id, (p) => p.copyWith(isConnected: connected));
    return connected;
  }

  Future<bool> printTest(PrinterModel printer) async {
    if (printer.macAddress.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Select a real printer first.');
      return false;
    }

    final alreadyConnected = await PrintBluetoothThermal.connectionStatus;
    if (!alreadyConnected) {
      final connected = await connectToPrinter(printer);
      if (!connected) {
        AppHelperFunctions.showErrorSnackBar('Could not connect to printer.');
        return false;
      }
    }

    final profile = await CapabilityProfile.load();
    final paperSize = printer.paperSize == '58mm'
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    final isDark = printer.printDensity == 'Dark';

    final bytes = <int>[
      ...generator.text(
        'Softverse POS',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      ...generator.text(
        printer.printerModel,
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.hr(),
      ...generator.text(
        'PRINTER TEST PAGE',
        styles: PosStyles(align: PosAlign.center, bold: isDark),
      ),
      ...generator.text('Paper size: ${printer.paperSize}'),
      ...generator.text('Print density: ${printer.printDensity}'),
      ...generator.text('Auto cut: ${printer.autoCut ? 'On' : 'Off'}'),
      ...generator.hr(),
      ...generator.text(
        'If you can read this clearly, your printer is connected and configured correctly.',
      ),
      ...generator.feed(2),
      if (printer.autoCut) ...generator.cut(),
    ];

    final sent = await PrintBluetoothThermal.writeBytes(bytes);
    if (sent) {
      AppHelperFunctions.showSuccessSnackBar('Test page sent to printer.');
    } else {
      AppHelperFunctions.showErrorSnackBar('Failed to send test page.');
    }
    return sent;
  }

  Future<bool> printReceipt({
    required String invoiceNumber,
    required String customerName,
    required String orderId,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required double amountReceived,
    required double changeToReturn,
    required String paymentLabel,
  }) async {
    final printer = receiptPrinter;
    if (printer == null) {
      AppHelperFunctions.showWarningSnackBar('Add a receipt printer first.');
      return false;
    }

    final connected = await connectToPrinter(printer);
    if (!connected) {
      AppHelperFunctions.showErrorSnackBar('Could not connect to printer.');
      return false;
    }

    final profile = await CapabilityProfile.load();
    final paperSize = printer.paperSize == '58mm'
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    final isDark = printer.printDensity == 'Dark';

    final bytes = <int>[
      ...generator.text(
        'Softverse POS',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
      ...generator.text(
        'Receipt',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.text(invoiceNumber),
      ...generator.text(orderId),
      ...generator.text('Customer: $customerName'),
      ...generator.text('Payment: $paymentLabel'),
      ...generator.hr(),
      ...generator.text('Items', styles: PosStyles(bold: isDark)),
      for (final item in items) ...[
        ...generator.text('${item.name} x${item.quantity}'),
        ...generator.text(
          _money(item.lineSubtotal),
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
      ...generator.hr(),
      ...generator.text('Subtotal: ${_money(subtotal)}'),
      ...generator.text('Tax: ${_money(tax)}'),
      ...generator.text(
        'Total: ${_money(totalAmount)}',
        styles: PosStyles(bold: isDark),
      ),
      ...generator.text('Received: ${_money(amountReceived)}'),
      ...generator.text('Change: ${_money(changeToReturn)}'),
      ...generator.feed(2),
      if (printer.autoCut) ...generator.cut(),
    ];

    final sent = await PrintBluetoothThermal.writeBytes(bytes);
    if (sent) {
      AppHelperFunctions.showSuccessSnackBar('Receipt sent to printer.');
    } else {
      AppHelperFunctions.showErrorSnackBar('Failed to print receipt.');
    }
    return sent;
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';
}
