import 'dart:async';
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
import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../store/controller/store_controller.dart';
import '../../customer/controller/customer_controller.dart';
import '../../customer/models/customer_model.dart';
import '../../home/controller/home_controller.dart';
import '../../home/models/product.dart';
import '../../home/models/table_order.dart';
import '../../invoice/controller/invoice_controller.dart';
import '../../main_nav/controller/main_nav_controller.dart';
import '../../printer/controller/printer_controller.dart';
import '../../tax/controller/tax_controller.dart';
import '../../tax/models/tax_model.dart';
import '../../transaction/controller/transaction_controller.dart';
import '../../../core/services/permission_service.dart';
import '../../item/data/discount_repository.dart';
import '../../item/models/discount_rule_model.dart';
import '../models/cart_item.dart';
import '../widgets/discount_picker_sheet.dart';
import '../models/payment_method.dart';

enum PriceAdjustmentMode { modifier, discount }

class CheckoutController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final DiscountRepository _discountRepository = HttpDiscountRepository();
  final KdsOrderSender _kdsOrderSender = KdsOrderSender();
  final CdsCartSender _cdsCartSender = CdsCartSender();
  final activeOrderId = RxnString();
  final activeOrderNumber = ''.obs;
  final activeTableId = RxnString();
  final activeTableName = RxnString();
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

  String get orderId =>
      activeOrderNumber.value.isEmpty ? 'New order' : activeOrderNumber.value;

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
                tax.type == TaxType.addedAtCheckout && tax.appliesTo(itemId),
          )
          .fold(0.0, (total, tax) => total + tax.ratePercent);
      return sum + (item.lineSubtotal * rate / 100);
    });
  }

  double get taxRate => subtotal == 0 ? 0 : tax / subtotal;

  /// Order-level discount picked from the business's discount catalog.
  final appliedDiscount = Rxn<DiscountRuleModel>();

  /// Value typed at the till for a catalog discount created without a fixed
  /// amount ("seller decides at the time of sale").
  final appliedDiscountValue = 0.0.obs;

  double get discountAmount {
    final discount = appliedDiscount.value;
    if (discount == null || subtotal <= 0) return 0;
    final value = appliedDiscountValue.value;
    final raw = discount.type == 'amount' ? value : subtotal * value / 100;
    return double.parse(raw.clamp(0, subtotal).toStringAsFixed(2));
  }

  /// Loyalty points the customer spends on this sale (1 point = 1 unit).
  final pointsToUse = 0.0.obs;

  /// Points of the selected customer; usable only on a sale paid now, not
  /// on paying an order that was saved/sent to a table earlier.
  double get availablePoints {
    if (selectedCustomerId.value.isEmpty || activeOrderId.value != null) {
      return 0;
    }
    if (!Get.isRegistered<CustomerController>()) return 0;
    return Get.find<CustomerController>().customers
            .firstWhereOrNull((c) => c.id == selectedCustomerId.value)
            ?.pointsBalance ??
        0;
  }

  double get loyaltyDiscount {
    final room = subtotal - discountAmount;
    if (room <= 0) return 0;
    final used = pointsToUse.value.clamp(0, availablePoints).clamp(0, room);
    return double.parse(used.toStringAsFixed(2));
  }

  void toggleUsePoints() {
    pointsToUse.value = pointsToUse.value > 0
        ? 0
        : (subtotal - discountAmount).clamp(0, availablePoints).toDouble();
  }

  double get totalAmount => subtotal - discountAmount - loyaltyDiscount + tax;

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
    if (cartItems[index].quantity <= 1) {
      // Decrementing an item already at 1 means "take it out of the cart" -
      // there was previously no way to remove a line item at all once added.
      cartItems.removeAt(index);
      _syncAmountReceivedWithTotal();
      _syncCds();
      return;
    }
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity - 1,
    );
    _syncAmountReceivedWithTotal();
    _syncCds();
  }

  void selectModifier() =>
      priceAdjustmentMode.value = PriceAdjustmentMode.modifier;

  void selectDiscount() {
    priceAdjustmentMode.value = PriceAdjustmentMode.discount;
    _openDiscountPicker();
  }

  Future<void> _openDiscountPicker() async {
    final response = await _discountRepository.fetchDiscountRules();
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    final raw = (response.responseData as Map)['discounts'];
    final storeId = StorageService.storeId;
    final discounts = (raw is List ? raw : const [])
        .whereType<Map>()
        .map(
          (json) => DiscountRuleModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .where(
          (d) =>
              d.isActive &&
              (d.storeId == null || storeId == null || d.storeId == storeId),
        )
        .toList();

    final picked = await Get.bottomSheet<DiscountRuleModel>(
      DiscountPickerSheet(
        discounts: discounts,
        appliedId: appliedDiscount.value?.id,
        onRemove: () {
          removeDiscount();
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
    if (picked != null) await _applyDiscount(picked);
  }

  void removeDiscount() {
    appliedDiscount.value = null;
    appliedDiscountValue.value = 0;
    pointsToUse.value = 0;
    _syncAmountReceivedWithTotal();
    _syncCds();
  }

  Future<void> _applyDiscount(DiscountRuleModel discount) async {
    if (discount.restrictedAccess &&
        !PermissionService.has(AppPermission.giveDiscount)) {
      AppHelperFunctions.showErrorSnackBar(
        'You are not allowed to apply this discount.',
      );
      return;
    }
    var value = discount.value;
    if (value <= 0) {
      final entered = await _askDiscountValue(discount);
      if (entered == null || entered <= 0) return;
      value = entered;
    }
    appliedDiscount.value = discount;
    appliedDiscountValue.value = value;
    _syncAmountReceivedWithTotal();
    _syncCds();
  }

  Future<double?> _askDiscountValue(DiscountRuleModel discount) async {
    final input = TextEditingController();
    final result = await Get.dialog<double>(
      AlertDialog(
        title: Text(discount.name),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: discount.type == 'amount' ? 'Amount' : 'Percentage',
            suffixText: discount.type == 'amount' ? null : '%',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(
              result: double.tryParse(input.text.trim().replaceAll(',', '')),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    input.dispose();
    if (result != null && discount.type != 'amount' && result > 100) {
      AppHelperFunctions.showWarningSnackBar('Percentage cannot exceed 100.');
      return null;
    }
    return result;
  }

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
    pointsToUse.value = 0;
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
    activeTableId.value = null;
    activeTableName.value = null;
    selectedCustomerId.value = '';
    customerName.value = 'Not Registered';
    amountEditedManually.value = false;
    appliedDiscount.value = null;
    appliedDiscountValue.value = 0;
    _syncAmountReceivedWithTotal(force: true);
    if (!silent && FeatureSettings.isEnabled('customer_displays')) {
      _cdsCartSender.clear();
    }
  }

  /// The "Clear Order" button's handler. Unlike [clearOrder] (used
  /// internally after a checkout already succeeded), this is the
  /// user explicitly abandoning whatever order is currently loaded - if
  /// that order already exists on the server (reopened via
  /// [loadOrderForCheckout], or sent to a table earlier in this session),
  /// delete it there too instead of just resetting local state and leaving
  /// it (and the table it occupies) stuck forever.
  Future<void> discardActiveOrder() async {
    final id = activeOrderId.value;
    if (id != null) {
      final response = await _networkCaller.deleteRequest(
        ApiConstants.checkoutOrder(id),
      );
      if (!response.isSuccess) {
        AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      } else if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchTables();
      }
    }
    clearOrder();
  }

  Future<void> selectPaymentMethod(PaymentMethod method) async {
    if (!_isPaymentMethodEnabled(method.key)) return;

    TableOrder? paymentTable;
    if (isTableOptionsEnabled && activeTableId.value == null) {
      paymentTable = await _selectAvailableTable();
      if (paymentTable == null) return;
    }

    selectedPaymentMethod.value = method.key;
    if (method.key != 'due') {
      await _submitCheckout(
        tableId: paymentTable?.tableId ?? activeTableId.value,
        tableName: paymentTable?.tableName ?? activeTableName.value,
      );
      return;
    }

    final customer = Get.find<CustomerController>().customer.value;
    if (totalAmount > customer.creditLimit) {
      AppHelperFunctions.showErrorSnackBar(
        'Credit sale denied. ${customer.name} has a ${AppHelperFunctions.formatCurrency(customer.creditLimit)} credit limit.',
      );
      return;
    }

    AppHelperFunctions.showSuccessSnackBar('Credit sale is within limit.');
    await _submitCheckout(
      tableId: paymentTable?.tableId ?? activeTableId.value,
      tableName: paymentTable?.tableName ?? activeTableName.value,
    );
  }

  Future<void> openSearch() => Get.find<HomeController>().openSearch();

  Future<void> openScan() => Get.find<HomeController>().openScan();

  void closeCheckout() => Get.find<MainNavController>().changeTab(0);

  Future<void> printEstimate() async {
    if (cartItems.isEmpty) {
      AppHelperFunctions.showWarningSnackBar(
        'Add items before printing an estimate.',
      );
      return;
    }
    await Get.find<PrinterController>().printEstimate(
      orderId: orderId,
      customerName: customerName.value,
      items: cartItems.toList(),
      subtotal: subtotal,
      tax: tax,
      totalAmount: totalAmount,
    );
  }

  Future<void> forceSync() async {
    if (Get.isRegistered<SyncService>()) {
      await Get.find<SyncService>().syncPendingActions();
    }
    await fetchOrders();
    AppHelperFunctions.showSuccessSnackBar('Synced');
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

  Future<TableOrder?> _selectAvailableTable() async {
    final homeController = Get.find<HomeController>();
    await homeController.fetchTables();
    final availableTables = homeController.availableTables;
    if (availableTables.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('No available table found.');
      return null;
    }
    return Get.bottomSheet<TableOrder>(
      _AvailableTableSheet(tables: availableTables),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
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

  Future<void> _printKitchenTicketsIfEnabled({
    required Map<String, dynamic> order,
    String? tableName,
  }) async {
    if (!FeatureSettings.isEnabled('kitchen_printers')) return;
    if (!Get.isRegistered<PrinterController>()) return;
    final products = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().products
        : const <Product>[];
    final categoryById = <String?, String?>{
      for (final product in products) product.id: product.categoryId,
    };
    await Get.find<PrinterController>().printKitchenTickets(
      orderLabel:
          order['orderNumber']?.toString() ??
          (activeOrderNumber.value.isEmpty ? orderId : activeOrderNumber.value),
      tableName: tableName ?? order['tableName']?.toString() ?? 'No table',
      customerName: customerName.value,
      items: cartItems.toList(),
      categoryOf: (itemId) => categoryById[itemId],
    );
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
                  body: _paymentPayload(tableId: tableId, tableName: tableName),
                )
              : currentOrderId != null && saveOrder
              ? await _networkCaller.patchRequest(
                  ApiConstants.checkoutOrder(currentOrderId),
                  body: _updateCheckoutPayload(),
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
      // Points earned/used on this sale show on the customer right away.
      if (selectedCustomerId.value.isNotEmpty &&
          Get.isRegistered<CustomerController>()) {
        unawaited(Get.find<CustomerController>().fetchCustomers());
      }
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
      // Kitchen tickets go out once per order: when it's sent to a table,
      // or when a new counter sale is paid straight away. Paying an order
      // that was already sent must not re-print it.
      if (sendToTable || (!saveOrder && currentOrderId == null)) {
        await _printKitchenTicketsIfEnabled(order: order, tableName: tableName);
      }
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
      if (response.errorMessage.contains('storeId is required')) {
        // The business now has several stores - ask which one this till
        // sells from instead of leaving every sale stuck on this error.
        AppHelperFunctions.showWarningSnackBar('Choose a store first.');
        await Get.find<StoreController>().ensureSelected(forcePicker: true);
        return;
      }
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

  List<Map<String, dynamic>> _cartItemsPayload() {
    return cartItems
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
        .toList();
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
      'items': _cartItemsPayload(),
      'taxAmount': _money(tax),
      'discountAmount': _money(discountAmount),
      if (!saveOrder && !sendToTable && loyaltyDiscount > 0)
        'loyaltyPointsRedeemed': _money(loyaltyDiscount),
      'amountReceived': _money(amountReceived.value),
      'storeId': ?StorageService.storeId,
      'posDeviceId': ?StorageService.posDeviceId,
      'payment': {
        'cash': selectedPaymentMethod.value == 'cash',
        'card': selectedPaymentMethod.value == 'card',
        'due': selectedPaymentMethod.value == 'due',
        'installment': selectedPaymentMethod.value == 'installment',
      },
      'saveOrder': saveOrder,
      'sendToTable': sendToTable,
      'tableId': ?tableId,
      'tableName': ?tableName,
    };
  }

  /// Body for `PATCH /checkout/:id` - updating an already-saved or
  /// sent-to-table order's contents in place. Deliberately narrower than
  /// [_checkoutPayload]: the backend's UpdateCheckoutDto only accepts these
  /// three fields (payment/table/status don't change on a content edit),
  /// and the global ValidationPipe rejects any extra property outright.
  Map<String, dynamic> _updateCheckoutPayload() {
    return {
      'customerName': customerName.value == 'Not Registered'
          ? null
          : customerName.value,
      'items': _cartItemsPayload(),
      'discountAmount': _money(discountAmount),
    };
  }

  Map<String, dynamic> _paymentPayload({String? tableId, String? tableName}) {
    return {
      'amountReceived': _money(amountReceived.value),
      'storeId': ?StorageService.storeId,
      'posDeviceId': ?StorageService.posDeviceId,
      'payment': {
        'cash': selectedPaymentMethod.value == 'cash',
        'card': selectedPaymentMethod.value == 'card',
        'due': selectedPaymentMethod.value == 'due',
        'installment': selectedPaymentMethod.value == 'installment',
      },
      'tableId': ?tableId,
      'tableName': ?tableName,
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
    activeTableId.value = order['tableId']?.toString();
    activeTableName.value = order['tableName']?.toString();
    selectedCustomerId.value = '';
    final savedCustomerName = order['customerName']?.toString().trim() ?? '';
    customerName.value = savedCustomerName.isEmpty
        ? 'Not Registered'
        : savedCustomerName;
    cartItems.assignAll(_cartItemsFromOrderJson(order));
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

  List<CartItem> _cartItemsFromOrderJson(Map<String, dynamic> order) {
    final items = order['items'] is List
        ? List<dynamic>.from(order['items'] as List)
        : <dynamic>[];
    return items.whereType<Map>().map((entry) {
      final item = Map<String, dynamic>.from(entry);
      return CartItem(
        itemId: item['itemId']?.toString(),
        name: item['name']?.toString() ?? 'Item',
        price: double.tryParse(item['unitPrice']?.toString() ?? '') ?? 0,
        imageUrl: item['imageUrl']?.toString() ?? '',
        quantity: (double.tryParse(item['quantity']?.toString() ?? '') ?? 1)
            .round(),
      );
    }).toList();
  }

  Future<void> printPendingOrder(String orderId) async {
    final response = await _networkCaller.getRequest(
      ApiConstants.checkoutOrder(orderId),
    );
    if (!response.isSuccess || response.responseData is! Map) {
      AppHelperFunctions.showErrorSnackBar('Unable to load order.');
      return;
    }

    final order = Map<String, dynamic>.from(response.responseData as Map);
    final rawCustomerName = order['customerName']?.toString().trim() ?? '';
    await Get.find<PrinterController>().printEstimate(
      orderId: order['orderNumber']?.toString() ?? orderId,
      customerName: rawCustomerName.isEmpty
          ? 'Not Registered'
          : rawCustomerName,
      items: _cartItemsFromOrderJson(order),
      subtotal: double.tryParse(order['subtotal']?.toString() ?? '') ?? 0,
      tax: double.tryParse(order['taxAmount']?.toString() ?? '') ?? 0,
      totalAmount: double.tryParse(order['totalAmount']?.toString() ?? '') ?? 0,
    );
  }

  Future<void> deletePendingOrder(String orderId) async {
    final response = await _networkCaller.deleteRequest(
      ApiConstants.checkoutOrder(orderId),
    );
    if (!response.isSuccess) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }
    pendingOrders.removeWhere((order) => order['id']?.toString() == orderId);
    AppHelperFunctions.showSuccessSnackBar('Order deleted.');
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
