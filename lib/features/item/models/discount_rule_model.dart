class DiscountRuleModel {
  final String id;
  final String name;
  final String type;
  final double value;
  final String displayValue;
  final bool restrictedAccess;
  final int colorIndex;
  final String? storeId;
  final bool isActive;

  const DiscountRuleModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.displayValue,
    this.restrictedAccess = false,
    this.colorIndex = 0,
    this.storeId,
    this.isActive = true,
  });

  factory DiscountRuleModel.fromJson(Map<String, dynamic> json) =>
      DiscountRuleModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? 'percentage',
        value: double.tryParse(json['value']?.toString() ?? '') ?? 0,
        displayValue: json['displayValue']?.toString() ?? '',
        restrictedAccess: json['restrictedAccess'] == true,
        colorIndex: int.tryParse(json['colorIndex']?.toString() ?? '') ?? 0,
        storeId: json['storeId']?.toString(),
        isActive: json['isActive'] != false,
      );
}
