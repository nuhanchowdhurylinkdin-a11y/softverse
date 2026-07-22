import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/widgets/floating_icon_button.dart';
import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/checkout_controller.dart';
import '../../widgets/bill_summary_card.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/checkout_action_buttons.dart';
import '../../widgets/checkout_header.dart';
import '../../widgets/modifier_discount_toggle.dart';
import '../../widgets/payment_method_grid.dart';

class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CheckoutHeader(
                  orderId: controller.orderId,
                  customerName: controller.customerName,
                  onAddCustomer: controller.addCustomer,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Purchase Item',
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.authTextDark,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < controller.cartItems.length; i++) ...[
                                CartItemCard(
                                  item: controller.cartItems[i],
                                  onIncrement: () => controller.incrementQuantity(i),
                                  onDecrement: () => controller.decrementQuantity(i),
                                ),
                                if (i == 0) ...[
                                  SizedBox(height: 12.h),
                                  ModifierDiscountToggle(
                                    mode: controller.priceAdjustmentMode.value,
                                    onModifierTap: controller.selectModifier,
                                    onDiscountTap: controller.selectDiscount,
                                  ),
                                ],
                                SizedBox(height: 22.h),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          'Bill Amounts',
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.authTextDark,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Obx(
                          () => BillSummaryCard(
                            subtotal: controller.subtotal,
                            tax: controller.tax,
                            taxRate: controller.taxRate,
                            totalAmount: controller.totalAmount,
                            amountReceivedController: controller.amountReceivedController,
                            changeToReturn: controller.changeToReturn,
                            onAmountReceivedChanged: controller.setAmountReceived,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        CheckoutActionButtons(
                          onSendToTable: controller.sendToTable,
                          onSaveOrder: controller.saveOrder,
                          onClearOrder: controller.clearOrder,
                        ),
                        SizedBox(height: 22.h),
                        Text(
                          'Payment Method',
                          style: getTextStyle(
                            fontSize: 16.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.authTextDark,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        PaymentMethodGrid(
                          methods: controller.paymentMethods,
                          onSelected: controller.selectPaymentMethod,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: Column(
                children: [
                  FloatingIconButton(
                    icon: Iconsax.search_normal,
                    backgroundColor: AppColors.chipBackground,
                    iconColor: AppColors.onboardingBackground,
                    onTap: controller.openSearch,
                  ),
                  SizedBox(height: 15.h),
                  FloatingIconButton(
                    icon: Iconsax.scan,
                    backgroundColor: AppColors.onboardingBackground,
                    iconColor: Colors.white,
                    onTap: controller.openScan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
