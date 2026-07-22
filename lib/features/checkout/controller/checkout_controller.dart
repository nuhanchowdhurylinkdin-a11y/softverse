import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/utils/constants/colors.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

enum PriceAdjustmentMode { modifier, discount }

class CheckoutController extends GetxController {
  final orderId = 'POS-1 Order-1';
  final customerName = 'Abs Corporation';

  final priceAdjustmentMode = PriceAdjustmentMode.modifier.obs;
  final amountReceived = 2200.0.obs;
  late final amountReceivedController = TextEditingController(
    text: amountReceived.value.toStringAsFixed(2),
  );

  final taxRate = 0.075;

  final cartItems = <CartItem>[
    const CartItem(
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
    const CartItem(name: 'A4Ttech Mouse', price: 400, icon: Icons.mouse, quantity: 1),
    const CartItem(name: 'HP Monitor', price: 18000, icon: Iconsax.monitor, quantity: 1),
  ].obs;

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

  void incrementQuantity(int index) {
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity + 1,
    );
  }

  void decrementQuantity(int index) {
    if (cartItems[index].quantity <= 1) return;
    cartItems[index] = cartItems[index].copyWith(
      quantity: cartItems[index].quantity - 1,
    );
  }

  void selectModifier() => priceAdjustmentMode.value = PriceAdjustmentMode.modifier;

  void selectDiscount() => priceAdjustmentMode.value = PriceAdjustmentMode.discount;

  void setAmountReceived(String value) {
    amountReceived.value = double.tryParse(value) ?? amountReceived.value;
  }

  void addCustomer() {}

  void sendToTable() {}

  void saveOrder() {}

  void clearOrder() {}

  void selectPaymentMethod(PaymentMethod method) {}

  void openSearch() {}

  void openScan() {}

  @override
  void onClose() {
    amountReceivedController.dispose();
    super.onClose();
  }
}
