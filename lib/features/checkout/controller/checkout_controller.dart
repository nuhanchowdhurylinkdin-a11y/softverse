import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/utils/constants/colors.dart';
import '../../../core/services/cds_cart_sender.dart';
import '../../../core/services/feature_settings.dart';
import '../../../core/services/kds_order_sender.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../customer/controller/customer_controller.dart';
import '../../customer/models/customer_model.dart';
import '../../home/controller/home_controller.dart';
import '../../home/models/table_order.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../../main_nav/controller/main_nav_controller.dart';
import '../../tax/controller/tax_controller.dart';
import '../../tax/models/tax_model.dart';
import '../../transaction/controller/transaction_controller.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

enum PriceAdjustmentMode { modifier, discount }

class CheckoutController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final KdsOrderSender _kdsOrderSender = KdsOrderSender();
  final CdsCartSender _cdsCartSender = CdsCartSender();
  final activeOrderId = RxnString();
  final activeOrderNumber = ''.obs;
  final selectedCustomerId = ''.obs;
  final customerName = 'Not Registered'.obs;

  final priceAdjustmentMode = PriceAdjustmentMode.modifier.obs;
  final amountReceived = 0.0.obs;
  final selectedPaymentMethod = 'cash'.obs;
  final isSubmittingCheckout = false.obs;
  final amountEditedManually = false.obs;
  final orders = <Map<String, dynamic>>[].obs;
  final pendingOrders = <Map<String, dynamic>>[].obs;
  final isLoadingPendingOrders = false.obs;
  late final amountReceivedController = TextEditingController(
    text: AppHelperFunctions.getFormattedMoney(amountReceived.value),
  );

  final cartItems = <CartItem>[].obs;

  String get orderId => activeOrderNumber.value.isEmpty
      ? 'POS-1 Order-1'
      : activeOrderNumber.value;

  static const _defaultPaymentMethods = [
    PaymentMethod(
      key: 'cash',
      label: 'Cash',
      icon: Iconsax.money,
      gradientStart: AppColors.completeBadgeStart,
      gradientEnd: AppColors.completeBadgeEnd,
    ),
    PaymentMethod(
      key: 'card',
      label: 'Card',
      icon: Iconsax.card,
      gradientStart: AppColors.ongoingBadgeStart,
      gradientEnd: AppColors.ongoingBadgeEnd,
    ),
    PaymentMethod(
      key: 'due',
      label: 'Due',
      icon: Iconsax.dollar_circle,
      gradientStart: AppColors.dueStart,
      gradientEnd: AppColors.dueEnd,
    ),
    PaymentMethod(
      key: 'installment',
      label: 'Installment',
      icon: Iconsax.truck,
      gradientStart: AppColors.installmentStart,
      gradientEnd: AppColors.installmentEnd,
    ),
  ];

  final paymentMethods = <PaymentMethod>[..._defaultPaymentMethods].obs;

  List<PaymentMethod> get visiblePaymentMethods => paymentMethods
      .where((method) => _isPaymentMethodEnabled(method.key))
      .toList();

  bool _isPaymentMethodEnabled(String key) => switch (key) {
    'due' => FeatureSettings.isEnabled('credit_sales'),
    'installment' => FeatureSettings.isEnabled('payment_in_installments'),
    _ => true,
  };

  @override
  void onInit() {
    super.onInit();
    fetchPaymentTypes();
    fetchOrders();
    loadCustomers();
    if (Get.isRegistered<TaxController>()) {
      Get.find<TaxController>().fetchTaxes();
    }
  }

  double get subtotal {
    double total = 0;
    for (final item in cartItems) {
      total += (item.bundle?.subtotal ?? item.price) * item.quantity;
    }
    return total;
  }

  double get tax {
    if (!Get.isRegistered<TaxController>()) return 0;
    final taxes = Get.find<TaxController>().taxes;
    return cartItems.fold(0.0, (sum, item) {
      final itemId = item.itemId;
      if (itemId == null) return sum;
      final rate = taxes
          .where(
            (tax) =>
                tax.type == TaxType.addedAtCheckout &&
                tax.appliedItemIds.contains(itemId),
          )
          .fold(0.0, (total, tax) => total + tax.ratePercent);
      return sum + (item.lineSubtotal * rate / 100);
    });
  }

  double get taxRate => subtotal == 0 ? 0 : tax / subtotal;

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
    _syncCds();
  }

  void incrementQuantity(int index) {
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity + 1,
    );
    _syncAmountReceivedWithTotal();
    _syncCds();
  }

  void decrementQuantity(int index) {
    if (cartItems[index].quantity <= 1) return;
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity - 1,
    );
    _syncAmountReceivedWithTotal();
    _syncCds();
  }

  void selectModifier() =>
      priceAdjustmentMode.value = PriceAdjustmentMode.modifier;

  void selectDiscount() =>
      priceAdjustmentMode.value = PriceAdjustmentMode.discount;

  void setAmountReceived(String value) {
    amountEditedManually.value = true;
    final normalized = value.replaceAll(',', '').replaceAll('\$', '');
    amountReceived.value = double.tryParse(normalized) ?? amountReceived.value;
    _syncCds();
  }

  void addCustomer() => Get.toNamed(AppRoute.getAddCustomerScreen());

  Future<void> loadCustomers() async {
    await Get.find<CustomerController>().fetchCustomers();
  }

  void selectCustomerById(String? id) {
    selectedCustomerId.value = id ?? '';
    if (selectedCustomerId.value.isEmpty) {
      customerName.value = 'Not Registered';
      _syncCds();
      return;
    }

    final customerController = Get.find<CustomerController>();
    CustomerModel? selected;
    for (final customer in customerController.customers) {
      if (customer.id == selectedCustomerId.value) {
        selected = customer;
        break;
      }
    }
    if (selected == null) return;
    customerController.selectCustomer(selected);
    customerName.value = selected.name.trim().isEmpty
        ? 'Not Registered'
        : selected.name.trim();
    _syncCds();
  }

  Future<void> sendToTable() async {
    if (!isTableOptionsEnabled) return;
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

  /// [silent] skips notifying the customer display — used right after a
  /// successful checkout, where the display should keep showing the final
  /// receipt (via [_cdsCartSender.complete]) instead of snapping to empty.
  void clearOrder({bool silent = false}) {
    cartItems.clear();
    activeOrderId.value = null;
    activeOrderNumber.value = '';
    selectedCustomerId.value = '';
    customerName.value = 'Not Registered';
    amountEditedManually.value = false;
    _syncAmountReceivedWithTotal(force: true);
    if (!silent && FeatureSettings.isEnabled('customer_displays')) {
      _cdsCartSender.clear();
    }
  }

  Future<void> selectPaymentMethod(PaymentMethod method) async {
    if (!_isPaymentMethodEnabled(method.key)) return;
    if (await _mustSelectTableBeforePayment()) return;

    selectedPaymentMethod.value = method.key;
    if (method.key != 'due') {
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

  Future<void> openSearch() => Get.find<HomeController>().openSearch();

  Future<void> openScan() => Get.find<HomeController>().openScan();

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

  Future<void> fetchPaymentTypes() async {
    final response = await _networkCaller.getRequest(ApiConstants.paymentTypes);
    if (!response.isSuccess || response.responseData is! List) return;

    final methods = List<dynamic>.from(response.responseData as List)
        .whereType<Map>()
        .where((entry) => entry['available'] == true)
        .map(_paymentMethodFromJson)
        .whereType<PaymentMethod>()
        .toList();
    if (methods.isNotEmpty) {
      paymentMethods.assignAll(methods);
      if (!methods.any((method) => method.key == selectedPaymentMethod.value)) {
        selectedPaymentMethod.value = methods.first.key;
      }
    }
  }

  Future<void> fetchPendingOrders() async {
    isLoadingPendingOrders.value = true;
    final response = await _networkCaller.getRequest(
      ApiConstants.pendingCheckout,
    );
    isLoadingPendingOrders.value = false;
    if (!response.isSuccess || response.responseData is! List) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    pendingOrders.assignAll(
      List<dynamic>.from(
        response.responseData as List,
      ).whereType<Map>().map((entry) => Map<String, dynamic>.from(entry)),
    );
  }

  void openPendingOrders() {
    if (!isOpenOrderEnabled) return;
    fetchPendingOrders();
    Get.toNamed(AppRoute.getPendingOrdersScreen());
  }

  bool get isOpenOrderEnabled => FeatureSettings.isEnabled('open_order');

  bool get isTableOptionsEnabled => FeatureSettings.isEnabled('table_options');

  Future<bool> _mustSelectTableBeforePayment() async {
    if (activeOrderId.value != null) return false;

    if (!FeatureSettings.isEnabled('table_options')) return false;

    if (_cachedTableCount() == 0) {
      AppHelperFunctions.showWarningSnackBar('No table found.');
    } else {
      AppHelperFunctions.showWarningSnackBar('Select a table first.');
    }
    return true;
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

  Future<void> _sendToKdsIfEnabled({
    required Map<String, dynamic> order,
    required bool saveOrder,
    required bool sendToTable,
    String? tableId,
    String? tableName,
  }) async {
    if (!FeatureSettings.isEnabled('kitchen_printers')) return;

    try {
      final sent = await _kdsOrderSender.send({
        'id': order['id']?.toString() ?? activeOrderId.value ?? orderId,
        'tableId': tableId,
        'orderId':
            order['orderNumber']?.toString() ??
            (activeOrderNumber.value.isEmpty
                ? orderId
                : activeOrderNumber.value),
        'customerName': customerName.value,
        'tableName': tableName ?? order['tableName']?.toString() ?? 'No Table',
        'status': sendToTable
            ? 'ongoing'
            : saveOrder
            ? 'saved'
            : 'paid',
        'createdAt': DateTime.now().toIso8601String(),
        'items': cartItems
            .map((item) => {'name': item.name, 'quantity': item.quantity})
            .toList(),
      });
      if (!sent) {
        AppHelperFunctions.showWarningSnackBar('KDS is not configured.');
      }
    } catch (_) {
      AppHelperFunctions.showWarningSnackBar('KDS not reachable on WiFi.');
    }
  }

  void _syncCds() {
    if (!FeatureSettings.isEnabled('customer_displays')) return;
    _cdsCartSender.update(_cdsCartSnapshot());
  }

  /// Product images can be a local file path on this POS device (never
  /// uploaded) or a server-relative upload path — neither loads as-is on
  /// the CDS device, so resolve to a full URL (or drop local-only images).
  String _resolveCdsImageUrl(String imageUrl) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return '';
    if (File(trimmed).existsSync()) return '';
    return ApiConstants.resolveAssetUrl(trimmed);
  }

  Map<String, dynamic> _cdsCartSnapshot({bool paid = false}) {
    return {
      'status': paid ? 'paid' : 'building',
      'orderNumber': activeOrderNumber.value.isEmpty
          ? null
          : activeOrderNumber.value,
      'customerName': customerName.value,
      'items': cartItems
          .map(
            (item) => {
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'imageUrl': _resolveCdsImageUrl(item.imageUrl),
              if (item.bundle != null)
                'bundle': {
                  'name': item.bundle!.name,
                  'price': item.bundle!.price,
                  'discountLabel': item.bundle!.discountLabel,
                  'discountAmount': item.bundle!.discountAmount,
                  'subtotal': item.bundle!.subtotal,
                },
            },
          )
          .toList(),
      'subtotal': subtotal,
      'tax': tax,
      'taxRatePercent': taxRate * 100,
      'totalAmount': totalAmount,
      'amountReceived': amountReceived.value,
      'changeToReturn': changeToReturn,
    };
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
      if (Get.isRegistered<TransactionController>()) {
        await Get.find<TransactionController>().fetchTransactions();
      }
      await _sendToKdsIfEnabled(
        order: order,
        saveOrder: saveOrder,
        sendToTable: sendToTable,
        tableId: tableId,
        tableName: tableName,
      );
      if (!saveOrder && !sendToTable) {
        if (FeatureSettings.isEnabled('customer_displays')) {
          _cdsCartSender.complete(_cdsCartSnapshot(paid: true));
        }
        _openInvoice(order);
        clearOrder(silent: true);
      } else if (sendToTable) {
        // Keep the cart open on this same order instead of wiping it — the
        // customer may be paying right now. `activeOrderId` makes the next
        // payment tap hit payCheckout(id) instead of creating a duplicate
        // order. Cashiers starting a fresh walk-in sale should tap
        // "Clear Order" first.
        activeOrderId.value = order['id']?.toString() ?? activeOrderId.value;
        activeOrderNumber.value =
            order['orderNumber']?.toString() ?? activeOrderNumber.value;
        _syncCds();
      } else if (saveOrder) {
        clearOrder();
        openPendingOrders();
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
      'customerName': customerName.value == 'Not Registered'
          ? null
          : customerName.value,
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

  PaymentMethod? _paymentMethodFromJson(Map<dynamic, dynamic> json) {
    final key = json['method']?.toString();
    final label = json['label']?.toString();
    final fallback = _defaultPaymentMethods.firstWhereOrNull(
      (method) => method.key == key,
    );
    if (key == null || label == null || fallback == null) return null;
    return PaymentMethod(
      key: key,
      label: label,
      icon: fallback.icon,
      gradientStart: fallback.gradientStart,
      gradientEnd: fallback.gradientEnd,
    );
  }

  Future<bool> loadOrderForCheckout(String orderId) async {
    final response = await _networkCaller.getRequest(
      ApiConstants.checkoutOrder(orderId),
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar('Unable to open order.');
      return false;
    }

    final order = Map<String, dynamic>.from(response.responseData as Map);
    activeOrderId.value = order['id']?.toString();
    activeOrderNumber.value = order['orderNumber']?.toString() ?? '';
    selectedCustomerId.value = '';
    final savedCustomerName = order['customerName']?.toString().trim() ?? '';
    customerName.value = savedCustomerName.isEmpty
        ? 'Not Registered'
        : savedCustomerName;
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
    _syncCds();
    return true;
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
