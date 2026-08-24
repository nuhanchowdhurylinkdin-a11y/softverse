import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/widgets/app_nav_drawer.dart';
import '../../../../core/common/widgets/floating_icon_button.dart';
import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../customer/controller/customer_controller.dart';
import '../../controller/checkout_controller.dart';
import '../../widgets/bill_summary_card.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/checkout_action_buttons.dart';
import '../../widgets/modifier_discount_toggle.dart';
import '../../widgets/payment_method_grid.dart';

class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppNavDrawer(),
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 58.h,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
            ),
          ),
        ),
        title: Obx(
          () => Text(
            controller.orderId,
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.closeCheckout,
            icon: Icon(Iconsax.close_circle, color: Colors.white, size: 26.sp),
          ),
          IconButton(
            onPressed: controller.openPendingOrders,
            icon: Icon(Iconsax.clock, color: Colors.white, size: 26.sp),
          ),
          SizedBox(width: 15.w),
          Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
          SizedBox(width: 15.w),
          Icon(Iconsax.more, color: Colors.white, size: 26.sp),
          SizedBox(width: 16.w),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 55.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Obx(() {
                            final customers = customerController.customers;
                            final selectedId =
                                customers.any(
                                  (customer) =>
                                      customer.id ==
                                      controller.selectedCustomerId.value,
                                )
                                ? controller.selectedCustomerId.value
                                : '';
                            final fallbackName =
                                controller.customerName.value.trim().isEmpty
                                ? 'Not Registered'
                                : controller.customerName.value.trim();
                            return DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedId,
                                isExpanded: true,
                                icon: Icon(
                                  Iconsax.arrow_down,
                                  size: 22.sp,
                                  color: AppColors.chipInactiveText,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                dropdownColor: Colors.white,
                                style: getTextStyle(
                                  fontSize: 16.4,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.chipInactiveText,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text(fallbackName),
                                  ),
                                  ...customers.map(
                                    (customer) => DropdownMenuItem(
                                      value: customer.id,
                                      child: Text(
                                        customer.name.trim().isEmpty
                                            ? 'Unnamed Customer'
                                            : customer.name.trim(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onTap: controller.loadCustomers,
                                onChanged: controller.selectCustomerById,
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: controller.addCustomer,
                        child: Container(
                          width: 55.w,
                          height: 55.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                            ),
                          ),
                          child: Icon(
                            Iconsax.user_add,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.forceSync,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                for (
                                  var i = 0;
                                  i < controller.cartItems.length;
                                  i++
                                ) ...[
                                  CartItemCard(
                                    item: controller.cartItems[i],
                                    onIncrement: () =>
                                        controller.incrementQuantity(i),
                                    onDecrement: () =>
                                        controller.decrementQuantity(i),
                                  ),
                                  if (i == 0) ...[
                                    SizedBox(height: 12.h),
                                    ModifierDiscountToggle(
                                      mode:
                                          controller.priceAdjustmentMode.value,
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
                              amountReceivedController:
                                  controller.amountReceivedController,
                              changeToReturn: controller.changeToReturn,
                              onAmountReceivedChanged:
                                  controller.setAmountReceived,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          Obx(
                            () => CheckoutActionButtons(
                              onSendToTable: controller.sendToTable,
                              onSaveOrder: controller.saveOrder,
                              onClearOrder: controller.clearOrder,
                              showSaveOrder: controller.isOpenOrderEnabled,
                              showSendToTable: controller.isTableOptionsEnabled,
                            ),
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
                          Obx(() {
                            final methods = controller.visiblePaymentMethods;
                            return PaymentMethodGrid(
                              methods: methods,
                              selectedKey:
                                  controller.selectedPaymentMethod.value,
                              onSelected: controller.selectPaymentMethod,
                            );
                          }),
                          SizedBox(height: 16.h),
                        ],
                      ),
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
