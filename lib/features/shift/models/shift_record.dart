class ShiftRecord {
  final String id;
  final int shiftNumber;
  final String openedBy;
  final String status;
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
    this.id = '',
    required this.shiftNumber,
    required this.openedBy,
    this.status = 'open',
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

  factory ShiftRecord.fromApi(Map<String, dynamic> json) {
    return ShiftRecord(
      id: json['id']?.toString() ?? '',
      shiftNumber: int.tryParse(json['shiftNumber']?.toString() ?? '') ?? 0,
      openedBy: json['openedBy']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      startDate: json['startDate']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      closeTime: _clean(json['closeTime']),
      startingCash: _double(json['startingCash']),
      cashPayments: _double(json['cashPayments']),
      cashRefunds: _double(json['cashRefunds']),
      paidIn: _double(json['paidIn']),
      paidOut: _double(json['paidOut']),
      expectedCashAmount: _double(json['expectedCashAmount']),
      actualCashAmount: _nullableDouble(json['actualCashAmount']),
      difference: _nullableDouble(json['difference']),
      grossSales: _double(json['grossSales']),
      refunds: _double(json['refunds']),
      discounts: _double(json['discounts']),
      netSales: _double(json['netSales']),
      taxes: _double(json['taxes']),
      totalTendered: _double(json['totalTendered']),
      cash: _double(json['cash']),
      card: _nullableDouble(json['card']),
      duePayment: _nullableDouble(json['duePayment']),
      installment: _nullableDouble(json['installment']),
    );
  }

  static String? _clean(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  static double _double(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
