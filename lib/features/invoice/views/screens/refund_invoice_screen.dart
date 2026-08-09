import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/invoice_controller.dart';
import '../../widgets/order_summary_banner.dart';
import '../../widgets/payment_type_badge.dart';

class RefundInvoiceScreen extends GetView<InvoiceController> {
  const RefundInvoiceScreen({super.key});

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
                    'Refund Item',
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
                  children: controller.items
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _Row(
                            label: '${item.name} x${item.quantity}',
                            value: item.price * item.quantity,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: controller.viewOriginalInvoice,
                child: Text(
                  'View Original Invoice : ${controller.invoiceNumber.value}',
                  style: getTextStyle(
                    fontSize: 12.8,
                    color: AppColors.onboardingBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 14.6,
            fontWeight: FontWeight.w500,
            color: AppColors.authTextDark,
          ),
        ),
        Text(
          '\$${AppHelperFunctions.getFormattedMoney(value)}',
          style: getTextStyle(
            fontSize: 14.6,
            color: AppColors.onboardingBackground,
          ),
        ),
      ],
    );
  }
}
