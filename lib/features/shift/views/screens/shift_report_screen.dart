import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/shift_controller.dart';
import '../../widgets/cash_drawer_card.dart';
import '../../widgets/sales_summary_card.dart';
import '../../widgets/shift_info_card.dart';

class ShiftReportScreen extends GetView<ShiftController> {
  const ShiftReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 69.h,
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
          'Shift report',
          style: getTextStyle(
            fontSize: 21.9,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final shift = controller.selectedReport.value;
          if (shift == null) {
            return Center(
              child: Text(
                'No shift report selected.',
                style: getTextStyle(
                  fontSize: 16.4,
                  color: AppColors.onboardingBackground,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShiftInfoCard(shift: shift),
                SizedBox(height: 24.h),
                CashDrawerCard(
                  startingCash: shift.startingCash,
                  cashPayments: shift.cashPayments,
                  cashRefunds: shift.cashRefunds,
                  paidIn: shift.paidIn,
                  paidOut: shift.paidOut,
                  expectedCashAmount: shift.expectedCashAmount,
                  actualCashAmount: shift.actualCashAmount,
                  difference: shift.difference,
                ),
                SizedBox(height: 24.h),
                SalesSummaryCard(
                  grossSales: shift.grossSales,
                  refunds: shift.refunds,
                  discounts: shift.discounts,
                  netSales: shift.netSales,
                  taxes: shift.taxes,
                  totalTendered: shift.totalTendered,
                  cash: shift.cash,
                  card: shift.card,
                  duePayment: shift.duePayment,
                  installment: shift.installment,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
