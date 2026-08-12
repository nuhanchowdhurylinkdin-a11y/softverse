import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/printer_model.dart';
import 'printer_controller.dart';

class AddPrinterController extends GetxController {
  final PrinterController _printerController = Get.find<PrinterController>();

  final nameController = TextEditingController();

  final isScanning = false.obs;
  final isConnecting = false.obs;
  final availableDevices = <BluetoothInfo>[].obs;
  final Rxn<BluetoothInfo> selectedDevice = Rxn<BluetoothInfo>();
  final isConnected = false.obs;

  final connectionType = 'Bluetooth'.obs;
  final printReceiptAndBills = true.obs;
  final printOrders = false.obs;
  final paperSize = '80mm'.obs;
  final printDensity = 'Medium'.obs;
  final autoCut = false.obs;
  final isDefault = false.obs;

  @override
  void onInit() {
    super.onInit();
    scanForPrinters();
  }

  Future<void> scanForPrinters() async {
    isScanning.value = true;
    try {
      final enabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!enabled) {
        AppHelperFunctions.showWarningSnackBar(
          'Turn on Bluetooth to discover nearby printers.',
        );
        availableDevices.clear();
        return;
      }
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      availableDevices.assignAll(devices);
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> selectDevice(BluetoothInfo device) async {
    selectedDevice.value = device;
    isConnected.value = false;
    if (nameController.text.trim().isEmpty) {
      nameController.text = device.name;
    }
    isConnecting.value = true;
    try {
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );
      isConnected.value = connected;
      if (connected) {
        AppHelperFunctions.showSuccessSnackBar('Connected to ${device.name}.');
      } else {
        AppHelperFunctions.showErrorSnackBar(
          'Could not connect to ${device.name}.',
        );
      }
    } finally {
      isConnecting.value = false;
    }
  }

  void setPaperSize(String size) => paperSize.value = size;

  void setPrintDensity(String density) => printDensity.value = density;

  void toggleDefault() => isDefault.value = !isDefault.value;

  Future<void> printTest() async {
    final device = selectedDevice.value;
    if (device == null) {
      AppHelperFunctions.showWarningSnackBar(
        'Select a paired Bluetooth printer first.',
      );
      return;
    }

    isConnecting.value = true;
    try {
      if (!isConnected.value) {
        isConnected.value = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress,
        );
      }
      if (!isConnected.value) {
        AppHelperFunctions.showErrorSnackBar(
          'Could not connect to ${device.name}.',
        );
        return;
      }

      final profile = await CapabilityProfile.load();
      final size = paperSize.value == '58mm' ? PaperSize.mm58 : PaperSize.mm80;
      final generator = Generator(size, profile);
      final isDark = printDensity.value == 'Dark';

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
          device.name,
          styles: const PosStyles(align: PosAlign.center),
        ),
        ...generator.hr(),
        ...generator.text(
          'PRINTER TEST PAGE',
          styles: PosStyles(align: PosAlign.center, bold: isDark),
        ),
        ...generator.feed(2),
        if (autoCut.value) ...generator.cut(),
      ];

      final sent = await PrintBluetoothThermal.writeBytes(bytes);
      if (sent) {
        AppHelperFunctions.showSuccessSnackBar('Test page sent to printer.');
      } else {
        AppHelperFunctions.showErrorSnackBar('Failed to send test page.');
      }
    } finally {
      isConnecting.value = false;
    }
  }

  void save() {
    final device = selectedDevice.value;
    if (nameController.text.trim().isEmpty || device == null) {
      AppHelperFunctions.showWarningSnackBar(
        'Enter a name and select a paired printer to continue.',
      );
      return;
    }

    _printerController.addPrinter(
      PrinterModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        printerModel: device.name,
        category: 'Receipt Printer',
        connectionType: connectionType.value,
        macAddress: device.macAdress,
        startTime: '',
        closeTime: '',
        isConnected: isConnected.value,
        isDefault: isDefault.value,
        printReceiptAndBills: printReceiptAndBills.value,
        printOrders: printOrders.value,
        paperSize: paperSize.value,
        printDensity: printDensity.value,
        autoCut: autoCut.value,
      ),
    );
    Get.back();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      AppHelperFunctions.showSuccessSnackBar('Printer saved.');
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
