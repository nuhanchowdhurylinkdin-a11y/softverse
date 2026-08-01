import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../models/transaction_record.dart';

class TransactionController extends GetxController {
  final transactions = const [
    TransactionRecord(
      companyName: 'ABC Corporation',
      invoiceNumber: 'INV 00012',
      orderId: 'POS-1 Order-5',
      dateTime: '29/06/2026 10:44am',
      paymentType: PaymentType.cash,
    ),
    TransactionRecord(
      companyName: 'XYZ Corporation',
      invoiceNumber: 'INV 00013',
      orderId: 'POS-1 Order-7',
      dateTime: '29/06/2026 10:44am',
      paymentType: PaymentType.card,
    ),
    TransactionRecord(
      companyName: 'Not Registered',
      invoiceNumber: 'INV 00014',
      orderId: 'POS-1 Order-10',
      dateTime: '29/06/2026 10:44am',
      paymentType: PaymentType.due,
    ),
    TransactionRecord(
      companyName: 'Tom Macey',
      invoiceNumber: 'INV 00015',
      orderId: 'POS-1 Order-11',
      dateTime: '29/06/2026 10:44am',
      paymentType: PaymentType.installment,
    ),
    TransactionRecord(
      companyName: 'Tom Macey',
      invoiceNumber: 'RINV 00001',
      orderId: 'POS-1 Order-11',
      dateTime: '29/06/2026 10:44am',
      paymentType: PaymentType.refund,
    ),
  ];

  final searchQuery = ''.obs;

  List<TransactionRecord> get filteredTransactions {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return transactions;
    return transactions
        .where(
          (transaction) =>
              transaction.companyName.toLowerCase().contains(query) ||
              transaction.invoiceNumber.toLowerCase().contains(query),
        )
        .toList();
  }

  void updateSearchQuery(String value) => searchQuery.value = value;

  void openTransaction(TransactionRecord transaction) {
    final invoiceController = Get.find<InvoiceController>();
    invoiceController.invoiceNumber.value = transaction.invoiceNumber;
    invoiceController.paymentType.value = transaction.paymentType;

    if (transaction.paymentType == PaymentType.refund) {
      Get.toNamed(AppRoute.getRefundInvoiceScreen());
    } else {
      Get.toNamed(AppRoute.getInvoiceScreen());
    }
  }

  void openFilter() {}

  void openNotifications() {}
}
