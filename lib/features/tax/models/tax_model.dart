String formatTaxRate(double rate) {
  return rate.truncateToDouble() == rate
      ? rate.toStringAsFixed(0)
      : rate.toStringAsFixed(1);
}

enum TaxType { includedInPrice, addedAtCheckout }

extension TaxTypeX on TaxType {
  String get label => switch (this) {
    TaxType.includedInPrice => 'Included in the price',
    TaxType.addedAtCheckout => 'Added at checkout',
  };

  String get apiValue => switch (this) {
    TaxType.includedInPrice => 'included_in_price',
    TaxType.addedAtCheckout => 'added_at_checkout',
  };

  static TaxType fromApi(String? value) => switch (value) {
    'included_in_price' => TaxType.includedInPrice,
    _ => TaxType.addedAtCheckout,
  };
}

class TaxModel {
  final String id;
  final String name;
  final double ratePercent;
  final TaxType type;
  final List<String> appliedItemIds;

  const TaxModel({
    required this.id,
    required this.name,
    required this.ratePercent,
    required this.type,
    this.appliedItemIds = const [],
  });

  factory TaxModel.fromApi(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ratePercent: double.tryParse('${json['ratePercent'] ?? 0}') ?? 0,
      type: TaxTypeX.fromApi(json['type']?.toString()),
      appliedItemIds: List<dynamic>.from(
        json['itemIds'] ?? [],
      ).map((id) => id.toString()).toList(),
    );
  }

  Map<String, dynamic> toApi() {
    return {
      'name': name,
      'ratePercent': ratePercent,
      'type': type.apiValue,
      'itemIds': appliedItemIds,
    };
  }

  int get itemCount => appliedItemIds.length;

  TaxModel copyWith({
    String? name,
    double? ratePercent,
    TaxType? type,
    List<String>? appliedItemIds,
  }) {
    return TaxModel(
      id: id,
      name: name ?? this.name,
      ratePercent: ratePercent ?? this.ratePercent,
      type: type ?? this.type,
      appliedItemIds: appliedItemIds ?? this.appliedItemIds,
    );
  }
}
