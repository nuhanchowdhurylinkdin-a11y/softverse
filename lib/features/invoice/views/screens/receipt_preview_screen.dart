import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../controller/invoice_controller.dart';
import '../../widgets/payment_type_badge.dart';

class ReceiptPreviewScreen extends GetView<InvoiceController> {
  const ReceiptPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
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
          'PDF Preview',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.openPrint,
            icon: Icon(Iconsax.printer, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(
          () => SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              color: AppColors.onboardingBackground,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Iconsax.document_text,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Softverse POS Receipt',
                                  style: getTextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.authTextDark,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  controller.invoiceNumber.value,
                                  style: getTextStyle(
                                    fontSize: 12.6,
                                    color: AppColors.chipInactiveText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PaymentTypeBadge(
                            paymentType: controller.paymentType.value,
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _InfoRow(label: 'Order', value: controller.orderId.value),
                      _InfoRow(
                        label: 'Customer',
                        value: controller.customerName.value,
                      ),
                      if ((controller.tableName.value ?? '').isNotEmpty)
                        _InfoRow(
                          label: 'Table',
                          value: controller.tableName.value!,
                        ),
                      SizedBox(height: 12.h),
                      const Divider(color: AppColors.cardBorder),
                      SizedBox(height: 8.h),
                      Text(
                        'Items',
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authTextDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...controller.items.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _ItemRow(
                            name: item.name,
                            quantity: item.quantity,
                            amount:
                                (item.bundle?.subtotal ?? item.price) *
                                item.quantity,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      const Divider(color: AppColors.cardBorder),
                      SizedBox(height: 10.h),
                      _AmountRow(label: 'Subtotal', value: controller.subtotal),
                      _AmountRow(label: 'Tax', value: controller.tax),
                      _AmountRow(
                        label: 'Total',
                        value: controller.totalAmount,
                        emphasize: true,
                      ),
                      _AmountRow(
                        label: 'Amount Received',
                        value: controller.amountReceived,
                      ),
                      _AmountRow(
                        label: 'Change',
                        value: controller.changeToReturn,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                if ((controller.localPdfPath.value ?? '').isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.tick_circle,
                          color: AppColors.stockBadgeText,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'PDF is ready for sharing or printing.',
                            style: getTextStyle(
                              fontSize: 12.8,
                              color: AppColors.authTextDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16.h),
                PrimaryButton(
                  label: 'Return Invoice',
                  onPressed: Get.back,
                  backgroundColor: AppColors.onboardingBackground,
                  textColor: Colors.white,
                  height: 51,
                  fontSize: 16,
                  borderRadius: 999,
                ),
                SizedBox(height: 12.h),
                PrimaryButton(
                  label: 'Return Home',
                  onPressed: controller.returnHome,
                  backgroundColor: Colors.white,
                  textColor: AppColors.onboardingBackground,
                  borderColor: AppColors.onboardingBackground,
                  height: 51,
                  fontSize: 16,
                  borderRadius: 999,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82.w,
            child: Text(
              label,
              style: getTextStyle(fontSize: 12.8, color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: getTextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w500,
                color: AppColors.authTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String name;
  final int quantity;
  final double amount;

  const _ItemRow({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$name x$quantity',
            style: getTextStyle(fontSize: 13.2, color: AppColors.authTextDark),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '\$${AppHelperFunctions.getFormattedMoney(amount)}',
          style: getTextStyle(
            fontSize: 13.2,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingBackground,
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasize;

  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontSize: emphasize ? 14.8 : 13.2,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.authTextDark,
            ),
          ),
          Text(
            '\$${AppHelperFunctions.getFormattedMoney(value)}',
            style: getTextStyle(
              fontSize: emphasize ? 15.8 : 13.2,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.authTextDark,
            ),
          ),
        ],
      ),
    );
  }
}
