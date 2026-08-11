import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/shift_record.dart';

class ShiftController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final currentShift = Rxn<ShiftRecord>();
  final shiftHistory = <ShiftRecord>[].obs;
  final selectedReport = Rxn<ShiftRecord>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentShift();
  }

  Future<void> fetchCurrentShift() async {
    final response = await _networkCaller.getRequest(ApiConstants.currentShift);
    if (!response.isSuccess) return;
    currentShift.value = response.responseData is Map
        ? ShiftRecord.fromApi(Map<String, dynamic>.from(response.responseData))
        : null;
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.shiftHistory);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! List) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    shiftHistory.assignAll(
      List<dynamic>.from(response.responseData as List).whereType<Map>().map(
        (entry) => ShiftRecord.fromApi(Map<String, dynamic>.from(entry)),
      ),
    );
  }

  Future<bool> openShift(double startingCash) async {
    final response = await _networkCaller.postRequest(
      ApiConstants.openShift,
      body: {'startingCash': startingCash},
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    currentShift.value = ShiftRecord.fromApi(
      Map<String, dynamic>.from(response.responseData),
    );
    AppHelperFunctions.showSuccessSnackBar('Shift opened.');
    return true;
  }

  Future<bool> addMovement(String type, double amount, String note) async {
    final response = await _networkCaller.postRequest(
      ApiConstants.shiftMovements,
      body: {
        'type': type,
        'amount': amount,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    currentShift.value = ShiftRecord.fromApi(
      Map<String, dynamic>.from(response.responseData),
    );
    AppHelperFunctions.showSuccessSnackBar('Cash drawer updated.');
    return true;
  }

  Future<bool> closeShift(double actualCashAmount) async {
    final response = await _networkCaller.postRequest(
      ApiConstants.closeShift,
      body: {'actualCashAmount': actualCashAmount},
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    final closed = ShiftRecord.fromApi(
      Map<String, dynamic>.from(response.responseData),
    );
    selectedReport.value = closed;
    currentShift.value = null;
    AppHelperFunctions.showSuccessSnackBar('Shift closed.');
    return true;
  }

  void openCashManagement() => Get.toNamed(AppRoute.getCashManagementScreen());

  void openCloseShift() {
    if (currentShift.value == null) {
      Get.toNamed(AppRoute.getOpenShiftScreen());
      return;
    }
    Get.toNamed(AppRoute.getCloseShiftScreen());
  }

  void openShiftHistory() {
    fetchHistory();
    Get.toNamed(AppRoute.getShiftListScreen());
  }

  void openShiftReport(ShiftRecord record) {
    selectedReport.value = record;
    Get.toNamed(AppRoute.getShiftReportScreen());
  }
}
