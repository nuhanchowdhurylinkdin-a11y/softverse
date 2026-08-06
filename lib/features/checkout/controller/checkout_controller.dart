import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/utils/constants/colors.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../customer/controller/customer_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../home/models/table_order.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../../main_nav/controller/main_nav_controller.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

enum PriceAdjustmentMode { modifier, discount }

class CheckoutController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final activeOrderId = RxnString();
  final activeOrderNumber = ''.obs;
  final customerName = 'Abs Corporation';

  final priceAdjustmentMode = PriceAdjustmentMode.modifier.obs;
  final amountReceived = 2200.0.obs;
  final selectedPaymentMethod = 'cash'.obs;
  final isSubmittingCheckout = false.obs;
  final amountEditedManually = false.obs;
  final orders = <Map<String, dynamic>>[].obs;
  late final amountReceivedController = TextEditingController(
    text: AppHelperFunctions.getFormattedMoney(amountReceived.value),
  );

  final taxRate = 0.075;

  final cartItems = <CartItem>[].obs;

  String get orderId => activeOrderNumber.value.isEmpty
      ? 'POS-1 Order-1'
      : activeOrderNumber.value;

  final paymentMethods = const [
    PaymentMethod(
      label: 'Cash',
      icon: Iconsax.money,
      gradientStart: AppColors.completeBadgeStart,
      gradientEnd: AppColors.completeBadgeEnd,
    ),
    PaymentMethod(
      label: 'Card',
      icon: Iconsax.card,
      gradientStart: AppColors.ongoingBadgeStart,
      gradientEnd: AppColors.ongoingBadgeEnd,
    ),
    PaymentMethod(
      label: 'Due',
      icon: Iconsax.dollar_circle,
      gradientStart: AppColors.dueStart,
      gradientEnd: AppColors.dueEnd,
    ),
    PaymentMethod(
      label: 'Installment',
      icon: Iconsax.truck,
      gradientStart: AppColors.installmentStart,
      gradientEnd: AppColors.installmentEnd,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  double get subtotal {
    double total = 0;
    for (final item in cartItems) {
      total += (item.bundle?.subtotal ?? item.price) * item.quantity;
    }
    return total;
  }

  double get tax => subtotal * taxRate;

  double get totalAmount => subtotal + tax;

  double get changeToReturn => amountReceived.value - totalAmount;

  void addProduct({
    String? itemId,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    final index = cartItems.indexWhere((item) => item.name == name);
    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      cartItems.add(
        CartItem(
          itemId: itemId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          quantity: 1,
        ),
      );
    }
    _syncAmountReceivedWithTotal();
  }

  void incrementQuantity(int index) {
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity + 1,
    );
    _syncAmountReceivedWithTotal();
  }

  void decrementQuantity(int index) {
    if (cartItems[index].quantity <= 1) return;
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity - 1,
    );
    _syncAmountReceivedWithTotal();
  }

  void selectModifier() =>
      priceAdjustmentMode.value = PriceAdjustmentMode.modifier;

  void selectDiscount() =>
      priceAdjustmentMode.value = PriceAdjustmentMode.discount;

  void setAmountReceived(String value) {
    amountEditedManually.value = true;
    final normalized = value.replaceAll(',', '').replaceAll('\$', '');
    amountReceived.value = double.tryParse(normalized) ?? amountReceived.value;
  }

  void addCustomer() => Get.toNamed(AppRoute.getAddCustomerScreen());

  Future<void> sendToTable() async {
    final homeController = Get.find<HomeController>();
    await homeController.fetchTables();
    final availableTables = homeController.availableTables;

    if (availableTables.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('No table found.');
      return;
    }

    final selected = await Get.bottomSheet<TableOrder>(
      _AvailableTableSheet(tables: availableTables),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );

    if (selected == null) {
      AppHelperFunctions.showWarningSnackBar('Select a table first.');
      return;
    }
    await _submitCheckout(
      sendToTable: true,
      tableId: selected.tableId,
      tableName: selected.tableName,
    );
  }

  Future<void> saveOrder() async {
    await _submitCheckout(saveOrder: true);
  }

  void clearOrder() {
    cartItems.clear();
    activeOrderId.value = null;
    activeOrderNumber.value = '';
    amountEditedManually.value = false;
    _syncAmountReceivedWithTotal(force: true);
  }

  Future<void> selectPaymentMethod(PaymentMethod method) async {
    if (await _mustSelectTableBeforePayment()) return;

    selectedPaymentMethod.value = method.label.toLowerCase();
    if (method.label != 'Due') {
      await _submitCheckout();
      return;
    }

    final customer = Get.find<CustomerController>().customer.value;
    if (totalAmount > customer.creditLimit) {
      AppHelperFunctions.showErrorSnackBar(
        'Credit sale denied. ${customer.name} has a \$${AppHelperFunctions.getFormattedMoney(customer.creditLimit)} credit limit.',
      );
      return;
    }

    AppHelperFunctions.showSuccessSnackBar('Credit sale is within limit.');
    await _submitCheckout();
  }

  void openSearch() {}

  void openScan() {}

  void closeCheckout() => Get.find<MainNavController>().changeTab(0);

  Future<void> forceSync() async {
    if (Get.isRegistered<SyncService>()) {
      await Get.find<SyncService>().syncPendingActions();
    }
    await fetchOrders();
    AppHelperFunctions.showSuccessSnackBar('Checkout data synced.');
  }

  Future<void> fetchOrders() async {
    final cached = OfflineDatabaseService.readCache<List<dynamic>>('orders');
    if (cached != null) {
      orders.assignAll(
        cached.map((entry) => Map<String, dynamic>.from(entry as Map)),
      );
    }
    final response = await _networkCaller.getRequest(ApiConstants.checkout);
    if (!response.isSuccess || response.responseData is! List) return;
    final data = List<dynamic>.from(response.responseData as List);
    await OfflineDatabaseService.saveCache('orders', data);
    orders.assignAll(
      data.whereType<Map>().map((entry) => Map<String, dynamic>.from(entry)),
    );
  }

  Future<bool> _mustSelectTableBeforePayment() async {
    if (activeOrderId.value != null) return false;

    if (!_isTableOptionsEnabled()) return false;

    if (_cachedTableCount() == 0) {
      AppHelperFunctions.showWarningSnackBar('No table found.');
    } else {
      AppHelperFunctions.showWarningSnackBar('Select a table first.');
    }
    return true;
  }

  bool _isTableOptionsEnabled() {
    final cached = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'feature_settings',
    );
    return _tableOptionsFromSettings(cached) ?? false;
  }

  bool? _tableOptionsFromSettings(Map<String, dynamic>? data) {
    final rawFeatures = data?['features'];
    if (rawFeatures is! List) return null;
    for (final raw in rawFeatures) {
      if (raw is! Map) continue;
      if (raw['key']?.toString() == 'table_options') {
        return raw['enabled'] == true;
      }
    }
    return null;
  }

  int _cachedTableCount() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      if (homeController.tableOrders.isNotEmpty) {
        return homeController.tableOrders.length;
      }
    }

    final cachedTables = OfflineDatabaseService.readCache<Map<String, dynamic>>(
      'tables',
    );
    final rawTables = cachedTables?['tables'];
    return rawTables is List ? rawTables.length : 0;
  }

  Future<void> _submitCheckout({
    bool sendToTable = false,
    bool saveOrder = false,
    String? tableId,
    String? tableName,
  }) async {
    if (cartItems.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('Add at least one item first.');
      return;
    }
    if (cartItems.any((item) => item.itemId == null)) {
      AppHelperFunctions.showWarningSnackBar(
        'Sync items from server before checkout.',
      );
      return;
    }
    final payload = _checkoutPayload(
      sendToTable: sendToTable,
      saveOrder: saveOrder,
      tableId: tableId,
      tableName: tableName,
    );

    isSubmittingCheckout.value = true;
    final online = Get.isRegistered<SyncService>()
        ? Get.find<SyncService>().isOnline.value
        : true;
    final currentOrderId = activeOrderId.value;
    final response = online
        ? currentOrderId != null && !sendToTable && !saveOrder
              ? await _networkCaller.postRequest(
                  ApiConstants.payCheckout(currentOrderId),
                  body: _paymentPayload(),
                )
              : await _networkCaller.postRequest(
                  ApiConstants.checkout,
                  body: payload,
                )
        : null;
    isSubmittingCheckout.value = false;

    if (response != null && response.isSuccess) {
      final order = response.responseData is Map
          ? Map<String, dynamic>.from(response.responseData as Map)
          : <String, dynamic>{};
      await fetchOrders();
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchTables();
      }
      if (!saveOrder && !sendToTable) {
        _openInvoice(order);
        clearOrder();
      } else if (sendToTable) {
        clearOrder();
      }
      AppHelperFunctions.showSuccessSnackBar(
        sendToTable
            ? 'Order sent to ${tableName ?? 'table'}.'
            : saveOrder
            ? 'Order saved.'
            : 'Checkout completed.',
      );
      return;
    }

    if (response != null &&
        response.statusCode != 0 &&
        response.statusCode != 408) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    await OfflineDatabaseService.enqueue(
      type: OfflineActionType.createCheckout,
      payload: payload,
    );
    AppHelperFunctions.showWarningSnackBar(
      'Saved offline. It will sync when internet is back.',
    );
  }

  Map<String, dynamic> _checkoutPayload({
    required bool sendToTable,
    required bool saveOrder,
    String? tableId,
    String? tableName,
  }) {
    return {
      'customerName': customerName,
      'items': cartItems
          .where((item) => item.itemId != null)
          .map(
            (item) => {
              'itemId': item.itemId,
              'quantity': item.quantity,
              if (item.bundle != null)
                'modifiers': [
                  {'name': item.bundle!.name, 'price': item.bundle!.price},
                ],
              if (item.bundle != null)
                'discountAmount': item.bundle!.discountAmount,
            },
          )
          .toList(),
      'taxAmount': _money(tax),
      'discountAmount': 0,
      'amountReceived': _money(amountReceived.value),
      'payment': {
        'cash': selectedPaymentMethod.value == 'cash',
        'card': selectedPaymentMethod.value == 'card',
        'due': selectedPaymentMethod.value == 'due',
        'installment': selectedPaymentMethod.value == 'installment',
      },
      'saveOrder': saveOrder,
      'sendToTable': sendToTable,
      if (sendToTable && tableId != null) 'tableId': tableId,
      if (sendToTable) 'tableName': tableName,
    };
  }

  Map<String, dynamic> _paymentPayload() {
    return {
      'amountReceived': _money(amountReceived.value),
      'payment': {
        'cash': selectedPaymentMethod.value == 'cash',
        'card': selectedPaymentMethod.value == 'card',
        'due': selectedPaymentMethod.value == 'due',
        'installment': selectedPaymentMethod.value == 'installment',
      },
    };
  }

  double _money(double value) => double.parse(value.toStringAsFixed(2));

  Future<void> loadOrderForCheckout(String orderId) async {
    final response = await _networkCaller.getRequest(
      ApiConstants.checkoutOrder(orderId),
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar('Unable to open table order.');
      return;
    }

    final order = Map<String, dynamic>.from(response.responseData as Map);
    activeOrderId.value = order['id']?.toString();
    activeOrderNumber.value = order['orderNumber']?.toString() ?? '';
    final items = order['items'] is List
        ? List<dynamic>.from(order['items'] as List)
        : <dynamic>[];
    cartItems.assignAll(
      items.whereType<Map>().map((entry) {
        final item = Map<String, dynamic>.from(entry);
        return CartItem(
          itemId: item['itemId']?.toString(),
          name: item['name']?.toString() ?? 'Item',
          price: double.tryParse(item['unitPrice']?.toString() ?? '') ?? 0,
          imageUrl: item['imageUrl']?.toString() ?? '',
          quantity: (double.tryParse(item['quantity']?.toString() ?? '') ?? 1)
              .round(),
        );
      }),
    );
    amountEditedManually.value = false;
    amountReceived.value =
        double.tryParse(order['totalAmount']?.toString() ?? '') ??
        amountReceived.value;
    amountReceivedController.text = AppHelperFunctions.getFormattedMoney(
      amountReceived.value,
    );
    Get.find<MainNavController>().changeTab(1);
  }

  void _syncAmountReceivedWithTotal({bool force = false}) {
    if (!force && amountEditedManually.value) return;
    final value = totalAmount < 0 ? 0.0 : totalAmount;
    amountReceived.value = value;
    amountReceivedController.text = AppHelperFunctions.getFormattedMoney(value);
  }

  void _openInvoice(Map<String, dynamic> order) {
    if (order.isEmpty) return;
    Get.find<InvoiceController>().loadFromOrder(order);
    Get.toNamed(AppRoute.getInvoiceScreen());
  }

  @override
  void onClose() {
    amountReceivedController.dispose();
    super.onClose();
  }
}

class _AvailableTableSheet extends StatelessWidget {
  final List<TableOrder> tables;

  const _AvailableTableSheet({required this.tables});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Table',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.authTextDark,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tables.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    title: Text(table.tableName),
                    subtitle: table.capacity == null
                        ? const Text('Available')
                        : Text('Available • ${table.capacity} seats'),
                    trailing: const Icon(Iconsax.arrow_right_3),
                    onTap: () => Get.back(result: table),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
