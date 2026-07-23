class ShiftRecord {
  final int shiftNumber;
  final String openedBy;
  final String startDate;
  final String startTime;
  final String? closeTime;

  final double startingCash;
  final double cashPayments;
  final double cashRefunds;
  final double paidIn;
  final double paidOut;
  final double expectedCashAmount;
  final double? actualCashAmount;
  final double? difference;

  final double grossSales;
  final double refunds;
  final double discounts;
  final double netSales;
  final double taxes;
  final double totalTendered;
  final double cash;
  final double? card;
  final double? duePayment;
  final double? installment;

  const ShiftRecord({
    required this.shiftNumber,
    required this.openedBy,
    required this.startDate,
    required this.startTime,
    this.closeTime,
    required this.startingCash,
    required this.cashPayments,
    required this.cashRefunds,
    required this.paidIn,
    required this.paidOut,
    required this.expectedCashAmount,
    this.actualCashAmount,
    this.difference,
    required this.grossSales,
    required this.refunds,
    required this.discounts,
    required this.netSales,
    required this.taxes,
    required this.totalTendered,
    required this.cash,
    this.card,
    this.duePayment,
    this.installment,
  });
}
