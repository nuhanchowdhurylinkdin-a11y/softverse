class DueOrderModel {
  final String checkoutOrderId;
  final String orderNumber;
  final DateTime? date;
  final double totalAmount;
  final double amountReceived;
  final double amountDue;

  const DueOrderModel({
    required this.checkoutOrderId,
    required this.orderNumber,
    this.date,
    this.totalAmount = 0,
    this.amountReceived = 0,
    this.amountDue = 0,
  });

  factory DueOrderModel.fromJson(Map<String, dynamic> json) => DueOrderModel(
    checkoutOrderId: json['checkoutOrderId']?.toString() ?? '',
    orderNumber: json['orderNumber']?.toString() ?? '',
    date: DateTime.tryParse(json['date']?.toString() ?? ''),
    totalAmount: _toDouble(json['totalAmount']),
    amountReceived: _toDouble(json['amountReceived']),
    amountDue: _toDouble(json['amountDue']),
  );

  static double _toDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
}
