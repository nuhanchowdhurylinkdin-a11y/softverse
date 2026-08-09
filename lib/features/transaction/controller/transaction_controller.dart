import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../models/transaction_record.dart';

class TransactionController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final transactions = <TransactionRecord>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedTransactions();
    fetchTransactions();
  }

  List<TransactionRecord> get filteredTransactions {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return transactions;
    return transactions
        .where(
          (transaction) =>
              transaction.companyName.toLowerCase().contains(query) ||
              transaction.invoiceNumber.toLowerCase().contains(query) ||
              transaction.orderId.toLowerCase().contains(query),
        )
        .toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

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
    await openTransaction(transaction);
    await Get.find<InvoiceController>().exportPdf();
  }

  void openFilter() {}

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
