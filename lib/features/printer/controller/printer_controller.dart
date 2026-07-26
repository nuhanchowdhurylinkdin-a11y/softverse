import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../models/printer_model.dart';

class PrinterController extends GetxController {
  final printers = <PrinterModel>[
    const PrinterModel(
      id: '1',
      name: 'Epson',
      printerModel: 'Epson TM-T2011',
      category: 'Receipt Printer',
      connectionType: 'Bluetooth',
      macAddress: '',
      startTime: '10.00 am',
      closeTime: '6.00 pm',
      isConnected: false,
      isDefault: true,
      printReceiptAndBills: true,
      printOrders: false,
      paperSize: '80mm',
      printDensity: 'Medium',
      autoCut: true,
    ),
    const PrinterModel(
      id: '2',
      name: 'Zebra',
      printerModel: 'Zebra GK420d',
      category: 'Receipt Printer',
      connectionType: 'Bluetooth',
      macAddress: '',
      startTime: '10.00 am',
      closeTime: '6.00 pm',
      isConnected: false,
      isDefault: false,
      printReceiptAndBills: true,
      printOrders: false,
      paperSize: '80mm',
      printDensity: 'Medium',
      autoCut: true,
    ),
    const PrinterModel(
      id: '3',
      name: 'Xprinter',
      printerModel: 'Xprinter XP-80C',
      category: 'Printer',
      connectionType: 'Bluetooth',
      macAddress: '',
      startTime: '10.00 am',
      closeTime: '6.00 pm',
      isConnected: false,
      isDefault: false,
      printReceiptAndBills: true,
      printOrders: false,
      paperSize: '80mm',
      printDensity: 'Medium',
      autoCut: true,
    ),
  ].obs;

  int _indexOf(String id) => printers.indexWhere((p) => p.id == id);

  void _update(String id, PrinterModel Function(PrinterModel) updater) {
    final index = _indexOf(id);
    if (index == -1) return;
    printers[index] = updater(printers[index]);
  }

  void addPrinter(PrinterModel printer) {
    if (printer.isDefault) {
      printers.assignAll(
        printers.map((p) => p.copyWith(isDefault: false)).toList(),
      );
    }
    printers.add(printer);
  }

  void removePrinter(String id) => printers.removeWhere((p) => p.id == id);

  void setDefault(String id) {
    printers.assignAll(
      printers.map((p) => p.copyWith(isDefault: p.id == id)).toList(),
    );
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
    final printer = printers[_indexOf(id)];
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

  Future<bool> connectToPrinter(PrinterModel printer) async {
    if (printer.macAddress.isEmpty) return false;
    final connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: printer.macAddress,
    );
    _update(printer.id, (p) => p.copyWith(isConnected: connected));
    return connected;
  }

  Future<bool> printTest(PrinterModel printer) async {
    if (printer.macAddress.isEmpty) return false;

    final alreadyConnected = await PrintBluetoothThermal.connectionStatus;
    if (!alreadyConnected) {
      final connected = await connectToPrinter(printer);
      if (!connected) return false;
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

    return PrintBluetoothThermal.writeBytes(bytes);
  }
}
