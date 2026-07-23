import 'package:get/get.dart';

class ScanBarcodeController extends GetxController {
  final showPermissionPrompt = true.obs;

  void allowWhileUsingApp() => showPermissionPrompt.value = false;

  void allowOnlyThisTime() => showPermissionPrompt.value = false;

  void denyPermission() => showPermissionPrompt.value = false;

  void flipCamera() {}
}
