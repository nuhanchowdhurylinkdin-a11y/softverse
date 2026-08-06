import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../home/controller/home_controller.dart';
import '../../home/models/table_order.dart';

class AddTableController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final nameController = TextEditingController();
  final capacityController = TextEditingController();
  final isSubmitting = false.obs;
  final isLoadingTables = false.obs;
  final deletingTableIds = <String>{}.obs;
  final tables = <TableOrder>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

  Future<void> createTable() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Enter a table name.');
      return;
    }

    final capacityText = capacityController.text.trim();
    final payload = {
      'name': name,
      if (capacityText.isNotEmpty) 'capacity': int.tryParse(capacityText),
      'isActive': true,
    };

    isSubmitting.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.tables,
      body: payload,
    );
    isSubmitting.value = false;

    if (!response.isSuccess) return;
    AppHelperFunctions.showSuccessSnackBar('Table added.');
    nameController.clear();
    capacityController.clear();
    await fetchTables();
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().fetchTables();
    }
  }

  Future<void> fetchTables() async {
    isLoadingTables.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.tables);
    isLoadingTables.value = false;
    if (!response.isSuccess || response.responseData is! Map) return;
    final data = Map<String, dynamic>.from(response.responseData as Map);
    final rawTables = data['tables'];
    if (rawTables is! List) return;
    tables.assignAll(
      rawTables
          .whereType<Map>()
          .map((entry) => TableOrder.fromApi(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }

  Future<void> deleteTable(TableOrder table) async {
    if (table.tableId.isEmpty) return;
    if (table.availability == 'booked' || table.status == OrderStatus.ongoing) {
      AppHelperFunctions.showWarningSnackBar(
        'Complete payment before deleting table.',
      );
      return;
    }

    deletingTableIds.add(table.tableId);
    final response = await _networkCaller.deleteRequest(
      ApiConstants.table(table.tableId),
    );
    deletingTableIds.remove(table.tableId);

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    tables.removeWhere((entry) => entry.tableId == table.tableId);
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().fetchTables();
    }
    AppHelperFunctions.showSuccessSnackBar('Table deleted.');
  }

  @override
  void onClose() {
    nameController.dispose();
    capacityController.dispose();
    super.onClose();
  }
}
