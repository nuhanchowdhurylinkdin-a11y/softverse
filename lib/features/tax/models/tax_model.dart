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
