import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/invoice_controller.dart';
import '../../widgets/invoice_item_card.dart';
import '../../widgets/order_summary_banner.dart';
import '../../widgets/payment_type_badge.dart';
import '../../widgets/read_only_bill_card.dart';

class RefundScreen extends GetView<InvoiceController> {
  const RefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 55.h,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
        title: Text(
          'Invoice : ${controller.refundInvoiceNumber}',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.openNotifications,
            icon: Icon(Iconsax.notification, color: Colors.white, size: 26.sp),
          ),
          IconButton(
            onPressed: controller.openMail,
            icon: Icon(Iconsax.sms, color: Colors.white, size: 26.sp),
          ),
          IconButton(
            onPressed: controller.openPrint,
            icon: Icon(Iconsax.printer, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => OrderSummaryBanner(
                  invoiceLabel: 'Invoice : ${controller.invoiceNumber.value}',
                  itemCount: 1,
                  price: controller.refundAmount,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Purchase Item',
                    style: getTextStyle(
                      fontSize: 16.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authTextDark,
                    ),
                  ),
                  Obx(
                    () => PaymentTypeBadge(
                      paymentType: controller.paymentType.value,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(controller.items.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: InvoiceItemCard(
                        item: controller.items[index],
                        selectable: true,
                        selected: controller.selectedRefundIndex.value == index,
                        onTap: () => controller.selectRefundItem(index),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Original Bill Amounts',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authTextDark,
                ),
              ),
              SizedBox(height: 12.h),
              ReadOnlyBillCard(
                subtotal: controller.subtotal,
                tax: controller.tax,
                taxRate: controller.taxRate,
                totalAmount: controller.totalAmount,
                amountReceived: controller.amountReceived,
                changeToReturn: controller.changeToReturn,
              ),
              SizedBox(height: 22.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    label: 'Cancel',
                    onPressed: controller.cancelRefund,
                    backgroundColor: Colors.white,
                    textColor: AppColors.completeBadgeEnd,
                    borderColor: AppColors.completeBadgeEnd,
                    width: 109.w,
                    height: 51,
                    fontSize: 16.4,
                    borderRadius: 999,
                  ),
                  SizedBox(width: 11.w),
                  PrimaryButton(
                    label: 'Pay Now',
                    onPressed: controller.confirmRefund,
                    backgroundColor: AppColors.dangerRed,
                    textColor: Colors.white,
                    width: 109.w,
                    height: 51,
                    fontSize: 16.4,
                    borderRadius: 999,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
