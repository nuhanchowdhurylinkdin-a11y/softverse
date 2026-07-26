import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBarcodeController extends GetxController {
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

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
