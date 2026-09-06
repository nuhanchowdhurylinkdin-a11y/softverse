import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../models/transaction_record.dart';
import '../widgets/transaction_filter_sheet.dart';

class TransactionController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final transactions = <TransactionRecord>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final Rxn<PaymentType> statusFilter = Rxn<PaymentType>();

  @override
  void onInit() {
    super.onInit();
    _loadCachedTransactions();
    fetchTransactions();
  }

  String get filterLabel => statusFilter.value?.label ?? 'Transaction';

  List<TransactionRecord> get filteredTransactions {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = statusFilter.value;
    return transactions.where((transaction) {
      final matchesQuery =
          query.isEmpty ||
          transaction.companyName.toLowerCase().contains(query) ||
          transaction.invoiceNumber.toLowerCase().contains(query) ||
          transaction.orderId.toLowerCase().contains(query);
      final matchesFilter = filter == null || transaction.paymentType == filter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  Future<void> openFilterSheet(BuildContext context) async {
    final result = await showTransactionFilterSheet(
      context: context,
      selected: statusFilter.value,
    );
    if (result == null) return;
    statusFilter.value = result == kTransactionFilterAll
        ? null
        : result as PaymentType;
  }

  Future<void> fetchTransactions({bool showMessage = false}) async {
    isLoading.value = true;
    final response = await _networkCaller.getRequest(ApiConstants.transactions);
    isLoading.value = false;

    if (!response.isSuccess || response.responseData is! List) {
      if (showMessage) {
        AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      }
      return;
    }

    final data = List<dynamic>.from(response.responseData as List);
    await OfflineDatabaseService.saveCache('transactions', data);
    _applyTransactions(data);

    if (showMessage) {
      AppHelperFunctions.showSuccessSnackBar('Transactions synced.');
    }
  }

  Future<void> openTransaction(TransactionRecord transaction) async {
    Map<String, dynamic> payload = transaction.raw;
    final response = await _networkCaller.getRequest(
      ApiConstants.transaction(transaction.id),
    );
    if (response.isSuccess && response.responseData is Map) {
      payload = Map<String, dynamic>.from(response.responseData as Map);
    }

    Get.find<InvoiceController>().loadFromOrder(payload);
    Get.toNamed(AppRoute.getInvoiceScreen());
  }

  Future<void> exportInvoice(TransactionRecord transaction) async {
    Map<String, dynamic> payload = transaction.raw;
    final response = await _networkCaller.getRequest(
      ApiConstants.transaction(transaction.id),
    );
    if (response.isSuccess && response.responseData is Map) {
      payload = Map<String, dynamic>.from(response.responseData as Map);
    }

    final invoiceController = Get.find<InvoiceController>();
    invoiceController.loadFromOrder(payload);
    await invoiceController.exportAndSharePdf();
  }

  void openNotifications() {}

  Future<void> forceSync() => fetchTransactions(showMessage: true);

  void _loadCachedTransactions() {
    final cached = OfflineDatabaseService.readCache<List<dynamic>>(
      'transactions',
    );
    if (cached != null) _applyTransactions(cached);
  }

  void _applyTransactions(List<dynamic> data) {
    transactions.assignAll(
      data
          .whereType<Map>()
          .map(
            (entry) =>
                TransactionRecord.fromApi(Map<String, dynamic>.from(entry)),
          )
          .where((transaction) => transaction.id.isNotEmpty)
          .toList(),
    );
  }
}
