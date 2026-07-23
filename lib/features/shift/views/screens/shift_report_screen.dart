import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/shift_controller.dart';
import '../../widgets/cash_drawer_card.dart';
import '../../widgets/sales_summary_card.dart';
import '../../widgets/shift_header.dart';
import '../../widgets/shift_info_card.dart';

class ShiftReportScreen extends GetView<ShiftController> {
  const ShiftReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ShiftHeader(title: 'Shift report'),
            Expanded(
              child: Obx(() {
                final shift = controller.selectedReport.value;
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
          ],
        ),
      ),
    );
  }
}
