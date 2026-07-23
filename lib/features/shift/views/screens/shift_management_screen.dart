import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../controller/shift_controller.dart';
import '../../widgets/cash_drawer_card.dart';
import '../../widgets/sales_summary_card.dart';
import '../../widgets/shift_action_button.dart';
import '../../widgets/shift_header.dart';
import '../../widgets/shift_info_card.dart';

class ShiftManagementScreen extends GetView<ShiftController> {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shift = controller.currentShift;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ShiftHeader(
              title: 'Shift Management',
              onClockTap: controller.openShiftHistory,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShiftActionButton(
                      icon: Iconsax.clock,
                      label: 'CASH MANAGEMENT',
                      filled: true,
                      onTap: controller.openCashManagement,
                    ),
                    SizedBox(height: 16.h),
                    ShiftActionButton(
                      icon: Iconsax.clock,
                      label: 'CLOSE SHIFT',
                      onTap: controller.openCloseShift,
                    ),
                    SizedBox(height: 24.h),
                    ShiftInfoCard(shift: shift),
                    SizedBox(height: 24.h),
                    CashDrawerCard(
                      startingCash: shift.startingCash,
                      cashPayments: shift.cashPayments,
                      cashRefunds: shift.cashRefunds,
                      paidIn: shift.paidIn,
                      paidOut: shift.paidOut,
                      expectedCashAmount: shift.expectedCashAmount,
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
