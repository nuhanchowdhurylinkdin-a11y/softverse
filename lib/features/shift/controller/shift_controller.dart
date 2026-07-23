import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../models/shift_record.dart';

class ShiftController extends GetxController {
  final currentShift = const ShiftRecord(
    shiftNumber: 2,
    openedBy: 'Liam Macey',
    startDate: '27/06/2026',
    startTime: '10.00 am',
    startingCash: 100000,
    cashPayments: 7560,
    cashRefunds: 800,
    paidIn: 0,
    paidOut: 0,
    expectedCashAmount: 126760,
    grossSales: 100000,
    refunds: 800,
    discounts: 0,
    netSales: 100000,
    taxes: 0,
    totalTendered: 126760,
    cash: 26760,
  );

  final shiftHistory = const [
    ShiftRecord(
      shiftNumber: 1,
      openedBy: 'Liam Macey',
      startDate: '27/06/2026',
      startTime: '10.00 am',
      closeTime: '6.00 pm',
      startingCash: 100000,
      cashPayments: 7560,
      cashRefunds: 800,
      paidIn: 0,
      paidOut: 0,
      expectedCashAmount: 126760,
      actualCashAmount: 126760,
      difference: 0,
      grossSales: 100000,
      refunds: 800,
      discounts: 0,
      netSales: 100000,
      taxes: 0,
      totalTendered: 126760,
      cash: 26760,
      card: 400,
      duePayment: 400,
      installment: 400,
    ),
    ShiftRecord(
      shiftNumber: 2,
      openedBy: 'Liam Macey',
      startDate: '27/06/2026',
      startTime: '10.00 am',
      closeTime: '6.00 pm',
      startingCash: 100000,
      cashPayments: 7560,
      cashRefunds: 800,
      paidIn: 0,
      paidOut: 0,
      expectedCashAmount: 126760,
      actualCashAmount: 126760,
      difference: 0,
      grossSales: 100000,
      refunds: 800,
      discounts: 0,
      netSales: 100000,
      taxes: 0,
      totalTendered: 126760,
      cash: 26760,
      card: 400,
      duePayment: 400,
      installment: 400,
    ),
    ShiftRecord(
      shiftNumber: 2,
      openedBy: 'Liam Macey',
      startDate: '27/06/2026',
      startTime: '10.00 am',
      closeTime: '6.00 pm',
      startingCash: 100000,
      cashPayments: 7560,
      cashRefunds: 800,
      paidIn: 0,
      paidOut: 0,
      expectedCashAmount: 126760,
      actualCashAmount: 126760,
      difference: 0,
      grossSales: 100000,
      refunds: 800,
      discounts: 0,
      netSales: 100000,
      taxes: 0,
      totalTendered: 126760,
      cash: 26760,
      card: 400,
      duePayment: 400,
      installment: 400,
    ),
  ];

  late final selectedReport = Rx<ShiftRecord>(shiftHistory.first);

  void openCashManagement() => Get.toNamed(AppRoute.getCashManagementScreen());

  void openCloseShift() => Get.toNamed(AppRoute.getCloseShiftScreen());

  void openShiftHistory() => Get.toNamed(AppRoute.getShiftListScreen());

  void openShiftReport(ShiftRecord record) {
    selectedReport.value = record;
    Get.toNamed(AppRoute.getShiftReportScreen());
  }
}
