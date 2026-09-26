import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/services/business_profile_service.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../checkout/models/cart_item.dart';
import '../models/printer_model.dart';

class VirtualPrintDocument {
  final String title;
  final String content;

  const VirtualPrintDocument({required this.title, required this.content});
}

typedef VirtualPrintPresenter =
    Future<void> Function(VirtualPrintDocument document);

class PrinterController extends GetxController {
  static const _cacheKey = 'saved_printers';
  static const _bleChannel = MethodChannel('softverse/ble_printer');

  final VirtualPrintPresenter? _virtualPrintPresenter;

  PrinterController({VirtualPrintPresenter? virtualPrintPresenter})
    : _virtualPrintPresenter = virtualPrintPresenter;

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
      cached.whereType<Map>().map((json) {
        final printer = PrinterModel.fromJson(Map<String, dynamic>.from(json));
        return printer.copyWith(isConnected: printer.isVirtual);
      }),
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
      (p) => savedPrinter.isVirtual
          ? p.isVirtual
          : p.macAddress.isNotEmpty && p.macAddress == savedPrinter.macAddress,
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

  /// Printing silently no-ops without this - from the tap it just looks
  /// like the button did nothing. Explain why and send the user straight
  /// to where they can fix it instead of leaving them to guess.
  void _warnNoPrinterConfigured() {
    AppHelperFunctions.showSnackBarWithTitle(
      'No receipt printer set up',
      'Add a printer and mark it as your default receipt printer to enable printing.',
      type: AppSnackBarType.warning,
    );
    Get.toNamed(AppRoute.getPrinterListScreen());
  }

  /// The native print_bluetooth_thermal Android plugin keeps a socket
  /// reference between calls and silently refuses to open a new one
  /// whenever that reference is still set — even if the physical
  /// connection has already died. Forcing a disconnect first guarantees
  /// the next connect() attempt actually opens a fresh socket instead of
  /// returning false immediately.
  Future<bool> connectToMacAddress(String macAddress) async {
    final alreadyConnected = await PrintBluetoothThermal.connectionStatus;
    if (alreadyConnected) return true;
    await PrintBluetoothThermal.disconnect;
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> connectToPrinter(PrinterModel printer) async {
    if (printer.isVirtual) {
      _update(printer.id, (p) => p.copyWith(isConnected: true));
      return true;
    }
    if (printer.macAddress.isEmpty) return false;
    if (printer.isBle) {
      try {
        final resolvedPrinter = printer.isConnected
            ? printer
            : await _resolveBlePrinter(printer);
        final connected =
            await _bleChannel.invokeMethod<bool>(
              'connect',
              resolvedPrinter.macAddress,
            ) ??
            false;
        _update(
          printer.id,
          (p) => p.copyWith(
            isConnected: connected,
            macAddress: connected ? resolvedPrinter.macAddress : p.macAddress,
            printerModel: connected
                ? resolvedPrinter.printerModel
                : p.printerModel,
          ),
        );
        return connected;
      } on PlatformException catch (error) {
        _update(printer.id, (p) => p.copyWith(isConnected: false));
        AppHelperFunctions.showErrorSnackBar(
          error.message ?? 'Could not connect to the BLE printer.',
        );
        return false;
      }
    }
    final connected = await connectToMacAddress(printer.macAddress);
    _update(printer.id, (p) => p.copyWith(isConnected: connected));
    return connected;
  }

  Future<bool> printTest(PrinterModel printer) async {
    if (printer.isVirtual) {
      await _showVirtualPrint(
        VirtualPrintDocument(
          title: 'Virtual printer test',
          content: _testPreview(printer),
        ),
      );
      return true;
    }
    if (printer.macAddress.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Select a real printer first.');
      return false;
    }

    final alreadyConnected = printer.isBle
        ? await _bleConnectionStatus()
        : await PrintBluetoothThermal.connectionStatus;
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
      ...await _businessHeaderBytes(generator),
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

    final sent = await _writePrinterBytesWithReconnect(printer, bytes);
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
    required DateTime dateTime,
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
      _warnNoPrinterConfigured();
      return false;
    }

    if (printer.isVirtual) {
      await _showVirtualPrint(
        VirtualPrintDocument(
          title: 'Receipt $invoiceNumber',
          content: _receiptPreview(
            invoiceNumber: invoiceNumber,
            customerName: customerName,
            orderId: orderId,
            dateTime: dateTime,
            items: items,
            subtotal: subtotal,
            tax: tax,
            totalAmount: totalAmount,
            amountReceived: amountReceived,
            changeToReturn: changeToReturn,
            paymentLabel: paymentLabel,
          ),
        ),
      );
      return true;
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
      ...await _businessHeaderBytes(generator),
      ...generator.text(
        'Receipt',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.text('Order: $invoiceNumber'),
      ...generator.text(
        AppHelperFunctions.getFormattedDate(
          dateTime,
          format: 'dd MMM yyyy, hh:mm a',
        ),
      ),
      ...generator.text('Customer: $customerName'),
      ...generator.text('Payment: $paymentLabel'),
      ...generator.hr(),
      ...generator.text('Items', styles: PosStyles(bold: isDark)),
      for (final item in items) ...[
        ...generator.text('${item.name}  x${item.quantity}'),
        ...generator.text(
          _money(item.lineSubtotal),
          styles: const PosStyles(align: PosAlign.right),
        ),
        ...generator.text(
          '  @ ${_money(item.price)}',
          styles: const PosStyles(height: PosTextSize.size1),
        ),
      ],
      ...generator.hr(),
      ...generator.text('Subtotal: ${_money(subtotal)}'),
      ...generator.text('Tax: ${_money(tax)}'),
      ...generator.text(
        'Total: ${_money(totalAmount)}',
        styles: PosStyles(bold: isDark),
      ),
      // A due/credit sale hasn't actually received anything yet - showing
      // "Received"/"Change" on it would make it look already paid in full.
      if (paymentLabel == 'Due Payment') ...[
        ...generator.text(
          'Amount due: ${_money(totalAmount)}',
          styles: PosStyles(bold: isDark),
        ),
      ] else ...[
        ...generator.text('Received: ${_money(amountReceived)}'),
        ...generator.text('Change: ${_money(changeToReturn)}'),
      ],
      ..._businessFooterBytes(generator),
      ...generator.feed(2),
      if (printer.autoCut) ...generator.cut(),
    ];

    final sent = await _writePrinterBytesWithReconnect(printer, bytes);
    if (sent) {
      AppHelperFunctions.showSuccessSnackBar('Receipt sent to printer.');
    } else {
      AppHelperFunctions.showErrorSnackBar('Failed to print receipt.');
    }
    return sent;
  }

  /// Prints a pre-payment estimate for an in-progress order — same layout as
  /// a receipt, minus the amount-received/change lines that don't exist yet.
  Future<bool> printEstimate({
    required String orderId,
    required String customerName,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double totalAmount,
  }) async {
    final printer = receiptPrinter;
    if (printer == null) {
      _warnNoPrinterConfigured();
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
      ...await _businessHeaderBytes(generator),
      ...generator.text(
        'ESTIMATE (not a receipt)',
        styles: const PosStyles(align: PosAlign.center),
      ),
      ...generator.text(orderId),
      ...generator.text('Customer: $customerName'),
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
      ..._businessFooterBytes(generator),
      ...generator.feed(2),
      if (printer.autoCut) ...generator.cut(),
    ];

    final sent = await _writePrinterBytesWithReconnect(printer, bytes);
    if (sent) {
      AppHelperFunctions.showSuccessSnackBar('Estimate sent to printer.');
    } else {
      AppHelperFunctions.showErrorSnackBar('Failed to print estimate.');
    }
    return sent;
  }

  /// Business name/address/phone (and logo, when reachable) for the top of
  /// every real print - pulled from [BusinessProfileService] instead of a
  /// hardcoded "Softverse POS" so receipts reflect what the merchant
  /// actually entered on the Business Admin dashboard.
  Future<List<int>> _businessHeaderBytes(Generator generator) async {
    final bytes = <int>[];
    if (BusinessProfileService.header.isNotEmpty) {
      bytes.addAll(
        generator.text(
          BusinessProfileService.header,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      );
    }
    final logo = await BusinessProfileService.loadLogoImage();
    if (logo != null) {
      final resized = logo.width > 300 ? img.copyResize(logo, width: 300) : logo;
      // A logo exported with transparency often has black (or garbage)
      // RGB underneath the transparent pixels - the printer only sees RGB
      // and has no idea alpha exists, so it dithered every "invisible"
      // pixel as solid black instead of leaving it white. Flattening onto
      // a white background first makes transparent areas actually white.
      final flattened = img.Image(
        width: resized.width,
        height: resized.height,
        numChannels: 3,
      )..clear(img.ColorRgb8(255, 255, 255));
      img.compositeImage(flattened, resized);
      bytes.addAll(generator.image(flattened));
    }
    bytes.addAll(
      generator.text(
        BusinessProfileService.name,
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    if (BusinessProfileService.address.isNotEmpty) {
      bytes.addAll(
        generator.text(
          BusinessProfileService.address,
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }
    if (BusinessProfileService.phone.isNotEmpty) {
      bytes.addAll(
        generator.text(
          'Tel: ${BusinessProfileService.phone}',
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }
    return bytes;
  }

  /// Configured Receipt Settings footer text, printed at the bottom of
  /// every real print - empty (no bytes) when nothing is configured.
  List<int> _businessFooterBytes(Generator generator) {
    if (BusinessProfileService.footer.isEmpty) return const [];
    return generator.text(
      BusinessProfileService.footer,
      styles: const PosStyles(align: PosAlign.center),
    );
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  Future<bool> _bleConnectionStatus() async {
    try {
      return await _bleChannel.invokeMethod<bool>('connectionStatus') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<PrinterModel> _resolveBlePrinter(PrinterModel printer) async {
    try {
      final values =
          await _bleChannel.invokeMethod<List<dynamic>>(
            'scan',
            printer.macAddress.isNotEmpty ? printer.macAddress : null,
          ) ??
          <dynamic>[];
      final devices = values
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .where(
            (value) => value['address']?.toString().trim().isNotEmpty == true,
          )
          .toList();
      if (devices.isEmpty) return printer;

      Map<String, dynamic>? match = devices.firstWhereOrNull(
        (value) => value['address']?.toString() == printer.macAddress,
      );
      match ??= devices.firstWhereOrNull(
        (value) => value['name']?.toString() == printer.printerModel,
      );
      match ??= devices.length == 1 ? devices.single : null;
      if (match == null) return printer;

      return printer.copyWith(
        macAddress: match['address']!.toString(),
        printerModel: match['name']?.toString() ?? printer.printerModel,
      );
    } on PlatformException {
      return printer;
    }
  }

  Future<bool> _writePrinterBytes(PrinterModel printer, List<int> bytes) async {
    if (!printer.isBle) return PrintBluetoothThermal.writeBytes(bytes);
    try {
      return await _bleChannel.invokeMethod<bool>('writeBytes', bytes) ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _writePrinterBytesWithReconnect(
    PrinterModel printer,
    List<int> bytes,
  ) async {
    final sent = await _writePrinterBytes(printer, bytes);
    if (sent || !printer.isBle) return sent;

    try {
      await _bleChannel.invokeMethod<bool>('disconnect');
    } on PlatformException {
      // The reconnect below also replaces any stale native GATT state.
    }
    _update(printer.id, (p) => p.copyWith(isConnected: false));
    final latestPrinter = printers.firstWhereOrNull((p) => p.id == printer.id);
    final connected = await connectToPrinter(
      (latestPrinter ?? printer).copyWith(isConnected: false),
    );
    if (!connected) return false;
    return _writePrinterBytes(latestPrinter ?? printer, bytes);
  }

  String _testPreview(PrinterModel printer) =>
      '''
${_businessHeaderPreview()}
${printer.printerModel}
--------------------------------
PRINTER TEST PAGE
Paper size: ${printer.paperSize}
Print density: ${printer.printDensity}
Auto cut: ${printer.autoCut ? 'On' : 'Off'}
--------------------------------
Virtual printer is ready.
'''
          .trim();

  String _businessHeaderPreview() {
    final lines = [
      if (BusinessProfileService.header.isNotEmpty) BusinessProfileService.header,
      BusinessProfileService.name,
      if (BusinessProfileService.address.isNotEmpty) BusinessProfileService.address,
      if (BusinessProfileService.phone.isNotEmpty)
        'Tel: ${BusinessProfileService.phone}',
    ];
    return lines.join('\n');
  }

  String _receiptPreview({
    required String invoiceNumber,
    required String customerName,
    required String orderId,
    required DateTime dateTime,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double totalAmount,
    required double amountReceived,
    required double changeToReturn,
    required String paymentLabel,
  }) {
    final output = StringBuffer()
      ..writeln(_businessHeaderPreview())
      ..writeln('Receipt')
      ..writeln('Order: $invoiceNumber')
      ..writeln(
        AppHelperFunctions.getFormattedDate(
          dateTime,
          format: 'dd MMM yyyy, hh:mm a',
        ),
      )
      ..writeln('Customer: $customerName')
      ..writeln('Payment: $paymentLabel')
      ..writeln('--------------------------------')
      ..writeln('Items');
    for (final item in items) {
      output
        ..writeln('${item.name}  x${item.quantity}')
        ..writeln(_money(item.lineSubtotal))
        ..writeln('  @ ${_money(item.price)}');
    }
    output
      ..writeln('--------------------------------')
      ..writeln('Subtotal: ${_money(subtotal)}')
      ..writeln('Tax: ${_money(tax)}')
      ..writeln('Total: ${_money(totalAmount)}');
    if (paymentLabel == 'Due Payment') {
      output.writeln('Amount due: ${_money(totalAmount)}');
    } else {
      output
        ..writeln('Received: ${_money(amountReceived)}')
        ..writeln('Change: ${_money(changeToReturn)}');
    }
    if (BusinessProfileService.footer.isNotEmpty) {
      output.writeln(BusinessProfileService.footer);
    }
    return output.toString().trim();
  }

  Future<void> _showVirtualPrint(VirtualPrintDocument document) async {
    final presenter = _virtualPrintPresenter;
    if (presenter != null) {
      await presenter(document);
      return;
    }
    await Get.dialog<void>(
      AlertDialog(
        title: Text(document.title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: SingleChildScrollView(
            child: SelectableText(
              document.content,
              style: const TextStyle(fontFamily: 'monospace', height: 1.45),
            ),
          ),
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
      ),
    );
  }
}
