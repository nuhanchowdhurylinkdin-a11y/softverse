import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../checkout/models/cart_item.dart';
import '../../transaction/models/transaction_record.dart';
import '../../../routes/app_routes.dart';

class InvoiceController extends GetxController {
  final invoiceNumber = 'INV 00012'.obs;
  final refundInvoiceNumber = 'RINV 00001';
  final paymentType = PaymentType.cash.obs;

  final taxRate = 0.075;
  final amountReceived = 2200.0;
  final refundAmount = 10840.0;

  final selectedRefundIndex = Rx<int?>(1);

  final items = const [
    CartItem(
      name: 'A4Ttech Keyboard',
      price: 800,
      icon: Iconsax.keyboard,
      quantity: 1,
      bundle: BundleInfo(
        name: 'Mouse + Keyboard',
        price: 1100,
        discountLabel: '20% Discount',
        discountAmount: 160,
        subtotal: 1740,
      ),
    ),
    CartItem(name: 'A4Ttech Mouse', price: 400, icon: Icons.mouse, quantity: 1),
    CartItem(name: 'HP Monitor', price: 18000, icon: Iconsax.monitor, quantity: 1),
  ];

  double get subtotal {
    double total = 0;
    for (final item in items) {
      total += (item.bundle?.subtotal ?? item.price) * item.quantity;
    }
    return total;
  }

  double get tax => subtotal * taxRate;

  double get totalAmount => subtotal + tax;

  double get changeToReturn => amountReceived - totalAmount;

  void selectRefundItem(int index) => selectedRefundIndex.value = index;

  void goToRefund() => Get.toNamed(AppRoute.getRefundScreen());

  void cancelRefund() => Get.back();

  void confirmRefund() => Get.offNamed(AppRoute.getRefundInvoiceScreen());

  void viewOriginalInvoice() {
    paymentType.value = PaymentType.cash;
    Get.toNamed(AppRoute.getInvoiceScreen());
  }

  void openNotifications() {}

  void openMail() {}

  void openPrint() {}
}
