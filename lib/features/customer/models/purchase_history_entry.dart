class PurchaseHistoryEntry {
  final String checkoutOrderId;
  final String orderNumber;
  final DateTime? date;
  final String status;
  final int itemCount;
  final double totalAmount;

  const PurchaseHistoryEntry({
    required this.checkoutOrderId,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.itemCount,
    required this.totalAmount,
  });

  factory PurchaseHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryEntry(
      checkoutOrderId: json['checkoutOrderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      itemCount: int.tryParse(json['itemCount']?.toString() ?? '') ?? 0,
      totalAmount:
          double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
    );
  }
}
