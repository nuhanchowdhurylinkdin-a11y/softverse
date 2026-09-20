import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/customer_due_model.dart';
import '../models/due_order_model.dart';

class CustomerDueOrdersController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final customerName = ''.obs;
  final totalDue = 0.0.obs;
  final orders = <DueOrderModel>[].obs;
  final isLoading = false.obs;
  final collectingOrderId = RxnString();

  CustomerDueModel? get _due =>
      Get.arguments is CustomerDueModel ? Get.arguments as CustomerDueModel : null;

  /// Walk-in due sales have no customerId at all (no FK, and no name to
  /// even match by) - they're reached through a dedicated "unassigned"
  /// endpoint instead of /customers/:id/due-orders.
  bool get _isWalkIn => _due != null && _due!.customerId == null;

  String get _customerId => _due?.customerId ?? '';

  @override
  void onInit() {
    super.onInit();
    if (_due != null) {
      customerName.value = _due!.customerName;
    }
    fetchDueOrders();
  }

  Future<void> fetchDueOrders() async {
    final isWalkIn = _isWalkIn;
    final id = _customerId;
    if (!isWalkIn && id.isEmpty) return;

    isLoading.value = true;
    final response = await _networkCaller.getRequest(
      isWalkIn
          ? ApiConstants.unassignedDueOrders
          : ApiConstants.customerDueOrders(id),
    );
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    final data = Map<String, dynamic>.from(response.responseData as Map);
    customerName.value =
        data['customerName']?.toString() ?? customerName.value;
    totalDue.value = double.tryParse(data['totalDue']?.toString() ?? '') ?? 0;
    final raw = data['orders'];
    orders.assignAll(
      raw is List
          ? raw.whereType<Map>().map(
              (value) =>
                  DueOrderModel.fromJson(Map<String, dynamic>.from(value)),
            )
          : const <DueOrderModel>[],
    );
  }

  Future<void> collectPayment(DueOrderModel order, double amount) async {
    if (collectingOrderId.value != null) return;
    if (amount <= 0) {
      AppHelperFunctions.showWarningSnackBar('Enter an amount to collect.');
      return;
    }
    if (amount > order.amountDue) {
      AppHelperFunctions.showWarningSnackBar(
        'Amount cannot exceed this order\'s outstanding balance.',
      );
      return;
    }

    collectingOrderId.value = order.checkoutOrderId;
    final response = await _networkCaller.postRequest(
      ApiConstants.collectDuePayment(order.checkoutOrderId),
      body: {'amount': amount},
    );
    collectingOrderId.value = null;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    AppHelperFunctions.showSuccessSnackBar('Payment collected.');
    await fetchDueOrders();
  }
}
