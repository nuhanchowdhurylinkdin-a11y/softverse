import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../models/printer_model.dart';
import 'printer_controller.dart';

class AddPrinterController extends GetxController {
  static const _settingsChannel = MethodChannel('softverse/app_settings');
  static const _bleChannel = MethodChannel('softverse/ble_printer');
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
      if (!await _ensureBluetoothPermission()) {
        availableDevices.clear();
        AppHelperFunctions.showWarningSnackBar(
          'Allow Nearby devices permission to find paired printers.',
        );
        return;
      }
      final enabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!enabled) {
        AppHelperFunctions.showWarningSnackBar(
          'Turn on Bluetooth to discover nearby printers.',
        );
        availableDevices.clear();
        return;
      }
      final devices = connectionType.value == PrinterModel.bleConnection
          ? await _scanBlePrinters()
          : await PrintBluetoothThermal.pairedBluetooths;
      availableDevices.assignAll(devices);
    } on PlatformException catch (error) {
      availableDevices.clear();
      AppHelperFunctions.showErrorSnackBar(
        error.message ?? 'Could not scan for BLE printers.',
      );
    } finally {
      isScanning.value = false;
    }
  }

  Future<List<BluetoothInfo>> _scanBlePrinters() async {
    final values =
        await _bleChannel.invokeMethod<List<dynamic>>('scan') ?? <dynamic>[];
    return values
        .whereType<Map>()
        .map((value) {
          final device = Map<String, dynamic>.from(value);
          return BluetoothInfo(
            name: device['name']?.toString() ?? 'BLE Printer',
            macAdress: device['address']?.toString() ?? '',
          );
        })
        .where((device) => device.macAdress.isNotEmpty)
        .toList();
  }

  Future<bool> _ensureBluetoothPermission() async {
    if (!Platform.isAndroid) return true;
    if (await PrintBluetoothThermal.isPermissionBluetoothGranted) return true;
    try {
      return await _settingsChannel.invokeMethod<bool>(
            'requestBluetoothPermissions',
          ) ??
          false;
    } on PlatformException {
      return false;
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
      final connected = await _printerController.connectToPrinter(
        _draftPrinter()!,
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

  void setConnectionType(String type) {
    if (type == connectionType.value) return;
    connectionType.value = type;
    selectedDevice.value = null;
    isConnected.value = type == PrinterModel.virtualConnection;
    if (type == PrinterModel.virtualConnection &&
        nameController.text.trim().isEmpty) {
      nameController.text = 'Virtual Printer';
    } else if (type == PrinterModel.bluetoothConnection &&
        nameController.text.trim() == 'Virtual Printer') {
      nameController.clear();
    }
    availableDevices.clear();
    if (type != PrinterModel.virtualConnection) {
      scanForPrinters();
    }
  }

  void toggleDefault() => isDefault.value = !isDefault.value;

  Future<void> printTest() async {
    final printer = _draftPrinter();
    if (printer == null) {
      AppHelperFunctions.showWarningSnackBar(
        connectionType.value == PrinterModel.virtualConnection
            ? 'Enter a printer name first.'
            : 'Enter a name and select a paired Bluetooth printer first.',
      );
      return;
    }

    isConnecting.value = true;
    try {
      isConnected.value = await _printerController.printTest(printer);
    } finally {
      isConnecting.value = false;
    }
  }

  void save() {
    final printer = _draftPrinter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    if (printer == null) {
      AppHelperFunctions.showWarningSnackBar(
        connectionType.value == PrinterModel.virtualConnection
            ? 'Enter a printer name to continue.'
            : 'Enter a name and select a paired printer to continue.',
      );
      return;
    }

    _printerController.addPrinter(printer);
    Get.back();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      AppHelperFunctions.showSuccessSnackBar('Printer saved.');
    });
  }

  PrinterModel? _draftPrinter({String id = 'virtual-test'}) {
    final name = nameController.text.trim();
    final isVirtual = connectionType.value == PrinterModel.virtualConnection;
    final device = selectedDevice.value;
    if (name.isEmpty || (!isVirtual && device == null)) return null;
    return PrinterModel(
      id: id,
      name: name,
      printerModel: isVirtual ? PrinterModel.virtualModel : device!.name,
      category: 'Receipt Printer',
      connectionType: connectionType.value,
      macAddress: isVirtual ? 'virtual://softverse' : device!.macAdress,
      startTime: '',
      closeTime: '',
      isConnected: isVirtual || isConnected.value,
      isDefault: isDefault.value,
      printReceiptAndBills: printReceiptAndBills.value,
      printOrders: printOrders.value,
      paperSize: paperSize.value,
      printDensity: printDensity.value,
      autoCut: autoCut.value,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
