import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../models/tax_model.dart';

class TaxController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final taxes = <TaxModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTaxes();
  }

  int _indexOf(String id) => taxes.indexWhere((t) => t.id == id);

  TaxModel? taxById(String id) => taxes.firstWhereOrNull((t) => t.id == id);

  Future<bool> fetchTaxes() async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.taxes);
    isLoading.value = false;
    if (!response.isSuccess || response.responseData is! List) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    taxes.assignAll(
      List<dynamic>.from(response.responseData as List).whereType<Map>().map(
        (json) => TaxModel.fromApi(Map<String, dynamic>.from(json)),
      ),
    );
    return true;
  }

  Future<bool> addTax(TaxModel tax) async {
    final response = await _networkCaller.postRequest(
      ApiConstants.taxes,
      body: tax.toApi(),
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    taxes.insert(
      0,
      TaxModel.fromApi(Map<String, dynamic>.from(response.responseData as Map)),
    );
    return true;
  }

  Future<bool> removeTax(String id) async {
    final response = await _networkCaller.deleteRequest(ApiConstants.tax(id));
    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    taxes.removeWhere((t) => t.id == id);
    return true;
  }

  Future<bool> updateTax(TaxModel updated) async {
    final response = await _networkCaller.patchRequest(
      ApiConstants.tax(updated.id),
      body: updated.toApi(),
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return false;
    }
    final index = _indexOf(updated.id);
    if (index != -1) {
      taxes[index] = TaxModel.fromApi(
        Map<String, dynamic>.from(response.responseData as Map),
      );
    }
    return true;
  }
}
