import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../models/shift_record.dart';
import 'shift_controller.dart';

class CloseShiftController extends GetxController {
  final ShiftController _shiftController = Get.find<ShiftController>();

  ShiftRecord get shift => _shiftController.currentShift;

  double get difference => 0;

  void closeShift() {
    final shift = _shiftController.currentShift;
    _shiftController.selectedReport.value = ShiftRecord(
      shiftNumber: shift.shiftNumber,
      openedBy: shift.openedBy,
      startDate: shift.startDate,
      startTime: shift.startTime,
      closeTime: '6.00 pm',
      startingCash: shift.startingCash,
      cashPayments: shift.cashPayments,
      cashRefunds: shift.cashRefunds,
      paidIn: shift.paidIn,
      paidOut: shift.paidOut,
      expectedCashAmount: shift.expectedCashAmount,
      actualCashAmount: shift.expectedCashAmount,
      difference: difference,
      grossSales: shift.grossSales,
      refunds: shift.refunds,
      discounts: shift.discounts,
      netSales: shift.netSales,
      taxes: shift.taxes,
      totalTendered: shift.totalTendered,
      cash: shift.cash,
      card: 400,
      duePayment: 400,
      installment: 400,
    );
    Get.offNamed(AppRoute.getOpenShiftScreen());
  }
}
