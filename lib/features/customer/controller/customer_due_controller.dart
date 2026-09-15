import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/customer_due_model.dart';

class CustomerDueController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final dues = <CustomerDueModel>[].obs;
  final isLoading = false.obs;
  final totalDue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDues();
  }

  Future<void> fetchDues() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.customerDues);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    final data = Map<String, dynamic>.from(response.responseData as Map);
    totalDue.value = double.tryParse(data['totalDue']?.toString() ?? '') ?? 0;
    final raw = data['customers'];
    dues.assignAll(
      raw is List
          ? raw.whereType<Map>().map(
              (value) =>
                  CustomerDueModel.fromJson(Map<String, dynamic>.from(value)),
            )
          : const <CustomerDueModel>[],
    );
  }

  void openCustomerDueOrders(CustomerDueModel due) {
    final id = due.customerId;
    if (id == null || id.isEmpty) {
      AppHelperFunctions.showWarningSnackBar(
        'This customer has no matching customer record to open.',
      );
      return;
    }
    Get.toNamed(AppRoute.getCustomerDueOrdersScreen(), arguments: due);
  }
}
