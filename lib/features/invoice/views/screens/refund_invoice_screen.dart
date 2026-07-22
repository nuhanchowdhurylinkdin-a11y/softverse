import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/invoice_controller.dart';
import '../../widgets/invoice_header.dart';
import '../../widgets/order_summary_banner.dart';
import '../../widgets/payment_type_badge.dart';

class RefundInvoiceScreen extends GetView<InvoiceController> {
  const RefundInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refundedItem = controller.items
        .firstWhere((item) => item.bundle != null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InvoiceHeader(
              title: 'Invoice : ${controller.refundInvoiceNumber}',
              onNotificationTap: controller.openNotifications,
              onMailTap: controller.openMail,
              onPrintTap: controller.openPrint,
            ),
            Expanded(
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
                    _Row(
                      label: refundedItem.bundle!.name,
                      value: refundedItem.bundle!.price,
                    ),
                    SizedBox(height: 4.h),
                    _Row(
                      label: refundedItem.bundle!.discountLabel,
                      value: refundedItem.bundle!.discountAmount,
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
          ],
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
          '\$${value.toStringAsFixed(2)}',
          style: getTextStyle(fontSize: 14.6, color: AppColors.onboardingBackground),
        ),
      ],
    );
  }
}
