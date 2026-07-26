import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/invoice_controller.dart';
import '../../widgets/invoice_item_card.dart';
import '../../widgets/payment_type_badge.dart';
import '../../widgets/read_only_bill_card.dart';

class InvoiceScreen extends GetView<InvoiceController> {
  const InvoiceScreen({super.key});

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
        title: Obx(
          () => Text(
            'Invoice : ${controller.invoiceNumber.value}',
            style: getTextStyle(
              fontSize: 16.4,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
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
              ...controller.items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InvoiceItemCard(item: item),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bill Amounts',
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
              Center(
                child: PrimaryButton(
                  label: 'Refund',
                  onPressed: controller.goToRefund,
                  backgroundColor: Colors.white,
                  textColor: AppColors.dangerRed,
                  borderColor: AppColors.dangerRed,
                  width: 109.w,
                  height: 51,
                  fontSize: 16.4,
                  borderRadius: 999,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
