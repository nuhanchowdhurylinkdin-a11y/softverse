import 'dart:io';

import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../models/customer_model.dart';

class CustomerController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final customer = const CustomerModel(
    name: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    region: '',
    postalCode: '',
    country: '',
    customerCode: '',
    imageUrl: '',
  ).obs;
  final customers = <CustomerModel>[].obs;
  final isLoading = false.obs;
  final showDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.customers);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! List) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    final fetched = List<dynamic>.from(response.responseData as List)
        .whereType<Map>()
        .map(
          (entry) => CustomerModel.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();
    customers.assignAll(fetched);
    if (fetched.isNotEmpty) customer.value = fetched.first;
  }

  Future<bool> createCustomer(CustomerModel nextCustomer, {File? image}) async {
    final response = image == null
        ? await _networkCaller.postRequest(
            ApiConstants.customers,
            body: nextCustomer.toCreateJson(),
          )
        : await _networkCaller.multipartRequest(
            ApiConstants.customers,
            fields: _fields(nextCustomer.toCreateJson()),
            file: image,
          );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }

    final created = CustomerModel.fromJson(
      Map<String, dynamic>.from(response.responseData as Map),
    );
    customers.insert(0, created);
    customer.value = created;
    return true;
  }

  Future<bool> updateCustomer(CustomerModel nextCustomer, {File? image}) async {
    final response = image == null
        ? await _networkCaller.patchRequest(
            ApiConstants.customer(nextCustomer.id),
            body: nextCustomer.toUpdateJson(),
          )
        : await _networkCaller.multipartRequest(
            ApiConstants.customer(nextCustomer.id),
            fields: _fields(nextCustomer.toUpdateJson()),
            file: image,
            method: 'PATCH',
          );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }

    final updated = CustomerModel.fromJson(
      Map<String, dynamic>.from(response.responseData as Map),
    );
    final index = customers.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      customers.insert(0, updated);
    } else {
      customers[index] = updated;
    }
    customer.value = updated;
    return true;
  }

  void selectCustomer(CustomerModel selected) => customer.value = selected;

  void openDetails(CustomerModel selected) {
    customer.value = selected;
    showDetails.value = true;
  }

  void showList() => showDetails.value = false;

  void openEdit() {
    if (customer.value.id.isEmpty && customer.value.name.isEmpty) return;
    Get.toNamed(AppRoute.getEditCustomerScreen());
  }

  void openAddCustomer() => Get.toNamed(AppRoute.getAddCustomerScreen());

  void redeemPoints() {}

  void viewPurchaseHistory() {}

  Map<String, String> _fields(Map<String, dynamic> payload) {
    return payload.map((key, value) => MapEntry(key, '$value'));
  }
}
