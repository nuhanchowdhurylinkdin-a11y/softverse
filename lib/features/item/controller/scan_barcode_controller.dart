import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/utils/helpers/app_helper.dart';

class ScanBarcodeController extends GetxController with WidgetsBindingObserver {
  static const _settingsChannel = MethodChannel('softverse/app_settings');

  final cameraController = MobileScannerController();

  bool _handled = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

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

  Future<void> retryCamera() => cameraController.start();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!cameraController.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(cameraController.start());
      case AppLifecycleState.inactive:
        unawaited(cameraController.stop());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
    }
  }

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
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.onClose();
  }
}
