class CustomerDueModel {
  final String? customerId;
  final String customerName;
  final String? phone;
  final double amountDue;
  final int dueOrderCount;
  final DateTime? lastOrderAt;

  const CustomerDueModel({
    this.customerId,
    required this.customerName,
    this.phone,
    this.amountDue = 0,
    this.dueOrderCount = 0,
    this.lastOrderAt,
  });

  factory CustomerDueModel.fromJson(Map<String, dynamic> json) =>
      CustomerDueModel(
        customerId: json['customerId']?.toString(),
        customerName: json['customerName']?.toString() ?? 'Walk-in Customer',
        phone: json['phone']?.toString(),
        amountDue: double.tryParse(json['amountDue']?.toString() ?? '') ?? 0,
        dueOrderCount:
            int.tryParse(json['dueOrderCount']?.toString() ?? '') ?? 0,
        lastOrderAt: DateTime.tryParse(json['lastOrderAt']?.toString() ?? ''),
      );
}
