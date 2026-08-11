import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/utils/helpers/app_helper.dart';

class ScanBarcodeController extends GetxController {
  static const _settingsChannel = MethodChannel('softverse/app_settings');

  final cameraController = MobileScannerController();

  bool _handled = false;

  void onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final rawValue = capture.barcodes.isNotEmpty
        ? capture.barcodes.first.rawValue
        : null;
    if (rawValue == null || rawValue.isEmpty) return;

    _handled = true;
    Get.back(result: rawValue);
  }

  void flipCamera() => cameraController.switchCamera();

  Future<void> openAppSettings() async {
    try {
      await _settingsChannel.invokeMethod<bool>('openAppSettings');
    } catch (_) {
      AppHelperFunctions.showErrorSnackBar(
        'Open app settings and allow camera permission.',
      );
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
