import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/network_caller.dart';
import '../../../core/services/kds_order_sender.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/constants/product_images.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/helpers/invoice_pdf_exporter.dart';
import '../../../routes/app_routes.dart';
import '../../checkout/models/cart_item.dart';
import '../../transaction/models/transaction_record.dart';
import '../../home/controller/home_controller.dart';
import '../../main_nav/controller/main_nav_controller.dart';
import '../../printer/controller/printer_controller.dart';
import '../../transaction/controller/transaction_controller.dart';

class InvoiceController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final KdsOrderSender _kdsOrderSender = KdsOrderSender();
  final checkoutOrderId = RxnString();
  final invoiceNumber = 'INV 00012'.obs;
  final refundInvoiceNumber = 'RINV 00001';
  final paymentType = PaymentType.cash.obs;
  final customerName = 'Abs Corporation'.obs;
  final orderId = 'POS-1 Order-1'.obs;
  final receiptPdfUrl = RxnString();
  final tableId = RxnString();
  final tableName = RxnString();
  final status = ''.obs;
  final isClearingTable = false.obs;
  final isPreparingPdf = false.obs;
  final isPrinting = false.obs;
  final isRefunding = false.obs;
  final localPdfPath = RxnString();
  final subtotalValue = 0.0.obs;
  final taxValue = 0.0.obs;
  final totalValue = 0.0.obs;
  final amountReceivedValue = 0.0.obs;
  final changeToReturnValue = 0.0.obs;

  final taxRate = 0.075;
  double get refundAmount => totalAmount;

  final selectedRefundIndex = Rx<int?>(null);

  final items = <CartItem>[
    CartItem(
      name: 'A4Ttech Keyboard',
      price: 800,
      imageUrl: ProductImages.keyboard,
      quantity: 1,
    ),
    CartItem(
      name: 'A4Ttech Mouse',
      price: 400,
      imageUrl: ProductImages.mouse,
      quantity: 1,
    ),
    CartItem(
      name: 'HP Monitor',
      price: 18000,
      imageUrl: ProductImages.monitor,
      quantity: 1,
    ),
  ].obs;

  double get subtotal => subtotalValue.value == 0
      ? items.fold<double>(
          0,
          (sum, item) =>
              sum + (item.bundle?.subtotal ?? item.price) * item.quantity,
        )
      : subtotalValue.value;

  double get tax => taxValue.value == 0 ? subtotal * taxRate : taxValue.value;

  double get totalAmount =>
      totalValue.value == 0 ? subtotal + tax : totalValue.value;

  double get amountReceived => amountReceivedValue.value;

  double get changeToReturn => changeToReturnValue.value;

  void loadFromOrder(
    Map<String, dynamic> order, {
    String? fallbackTableId,
    String? fallbackTableName,
  }) {
    invoiceNumber.value =
        order['orderNumber']?.toString() ?? invoiceNumber.value;
    checkoutOrderId.value = _cleanText(order['id']);
    customerName.value =
        order['customerName']?.toString().trim().isNotEmpty == true
        ? order['customerName'].toString()
        : 'Not registered';
    orderId.value = order['orderNumber']?.toString() ?? invoiceNumber.value;
    receiptPdfUrl.value = order['receiptPdfUrl']?.toString();
    status.value = order['status']?.toString() ?? '';
    tableId.value = _cleanText(order['tableId']) ?? _cleanText(fallbackTableId);
    tableName.value =
        _cleanText(order['tableName']) ?? _cleanText(fallbackTableName);
    subtotalValue.value = _toDouble(order['subtotal']);
    taxValue.value = _toDouble(order['taxAmount']);
    totalValue.value = _toDouble(order['totalAmount']);
    amountReceivedValue.value = _toDouble(order['amountReceived']);
    changeToReturnValue.value = _toDouble(order['changeToReturn']);
    paymentType.value = status.value == 'refunded'
        ? PaymentType.refund
        : _paymentTypeFrom(order['paymentMethod']?.toString());

    final rawItems = order['items'] is List
        ? List<dynamic>.from(order['items'] as List)
        : <dynamic>[];
    items.assignAll(
      rawItems.whereType<Map>().map((entry) {
        final item = Map<String, dynamic>.from(entry);
        return CartItem(
          itemId: item['itemId']?.toString(),
          name: item['name']?.toString() ?? 'Item',
          price: _toDouble(item['unitPrice']),
          imageUrl: item['imageUrl']?.toString() ?? '',
          quantity:
              (_toDouble(item['quantity']) == 0
                      ? 1
                      : _toDouble(item['quantity']))
                  .round(),
        );
      }),
    );
  }

  void selectRefundItem(int index) => selectedRefundIndex.value = index;

  bool get isRefunded => status.value == 'refunded';

  void goToRefund() {
    if (checkoutOrderId.value == null || checkoutOrderId.value!.isEmpty) {
      AppHelperFunctions.showWarningSnackBar(
        'This invoice cannot be refunded.',
      );
      return;
    }
    if (isRefunded) {
      AppHelperFunctions.showWarningSnackBar(
        'This invoice is already refunded.',
      );
      return;
    }
    Get.toNamed(AppRoute.getRefundScreen());
  }

  void cancelRefund() => Get.back();

  Future<void> confirmRefund() async {
    final id = checkoutOrderId.value;
    if (id == null || id.isEmpty || isRefunding.value) return;

    isRefunding.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.refundCheckout(id),
    );
    isRefunding.value = false;

    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    loadFromOrder(Map<String, dynamic>.from(response.responseData as Map));
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().fetchItems();
    }
    if (Get.isRegistered<TransactionController>()) {
      await Get.find<TransactionController>().fetchTransactions();
    }
    AppHelperFunctions.showSuccessSnackBar('Invoice refunded.');
    Get.offNamed(AppRoute.getRefundInvoiceScreen());
  }

  void viewOriginalInvoice() {
    paymentType.value = PaymentType.cash;
    Get.toNamed(AppRoute.getInvoiceScreen());
  }

  void openNotifications() {}

  void openMail() {}

  Future<void> openPrint() async {
    if (isPrinting.value) return;
    if (!Get.isRegistered<PrinterController>()) {
      AppHelperFunctions.showWarningSnackBar('Add a receipt printer first.');
      return;
    }

    isPrinting.value = true;
    await Get.find<PrinterController>().printReceipt(
      invoiceNumber: invoiceNumber.value,
      customerName: customerName.value,
      orderId: orderId.value,
      items: items.toList(),
      subtotal: subtotal,
      tax: tax,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      changeToReturn: changeToReturn,
      paymentLabel: paymentType.value.label,
    );
    isPrinting.value = false;
  }

  void returnHome() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(0);
    }
    Get.until((route) => route.settings.name == AppRoute.getHomeScreen());
  }

  Future<void> markTableEmpty() async {
    final id = tableId.value;
    if (id == null || id.isEmpty) {
      AppHelperFunctions.showWarningSnackBar(
        'This invoice is not linked to a table.',
      );
      return;
    }

    isClearingTable.value = true;
    final response = await _networkCaller.postRequest(
      ApiConstants.clearTable(id),
      body: const {},
    );
    isClearingTable.value = false;

    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    tableId.value = null;
    tableName.value = null;
    await _kdsOrderSender.completeAny([
      checkoutOrderId.value,
      orderId.value,
      id,
    ]);
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().fetchTables();
    }
    AppHelperFunctions.showSuccessSnackBar('Table marked empty.');
  }

  Future<void> exportPdf() async {
    if (isPreparingPdf.value) return;

    isPreparingPdf.value = true;
    try {
      final file = await _downloadBackendReceipt() ?? await _createLocalPdf();
      localPdfPath.value = file.path;
      Get.toNamed(AppRoute.getReceiptPreviewScreen());
    } catch (_) {
      AppHelperFunctions.showErrorSnackBar('Could not prepare receipt PDF.');
    } finally {
      isPreparingPdf.value = false;
    }
  }

  Future<File> _createLocalPdf() {
    return InvoicePdfExporter.exportInvoice(
      invoiceNumber: invoiceNumber.value,
      customerName: customerName.value,
      orderId: orderId.value,
      items: items.toList(),
      subtotal: subtotal,
      tax: tax,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      changeToReturn: changeToReturn,
    );
  }

  Future<File?> _downloadBackendReceipt() async {
    final url = _backendReceiptUrl();
    final token = StorageService.accessToken;
    if (url == null || token == null || token.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final contentType = response.headers['content-type'] ?? '';
      if (response.statusCode != 200 || !contentType.contains('pdf')) {
        return null;
      }

      final filename =
          '${invoiceNumber.value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf';
      final file = File('${Directory.systemTemp.path}/$filename');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  String? _backendReceiptUrl() {
    final id = checkoutOrderId.value;
    if (id != null && id.isNotEmpty) return ApiConstants.checkoutReceipt(id);
    final url = _cleanText(receiptPdfUrl.value);
    if (url == null) return null;
    return ApiConstants.resolveAssetUrl(url);
  }

  double _toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  String? _cleanText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  PaymentType _paymentTypeFrom(String? value) {
    return switch (value) {
      'card' => PaymentType.card,
      'due' => PaymentType.due,
      'installment' => PaymentType.installment,
      _ => PaymentType.cash,
    };
  }
}
