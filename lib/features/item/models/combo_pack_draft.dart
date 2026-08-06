import '../../inventory/models/modifier_group.dart';

class ComboPackDraft {
  final String id;
  final String label;
  final List<ModifierProduct> products;
  final bool selected;

  const ComboPackDraft({
    required this.id,
    required this.label,
    required this.products,
    this.selected = true,
  });

  ComboPackDraft copyWith({
    String? id,
    String? label,
    List<ModifierProduct>? products,
    bool? selected,
  }) {
    return ComboPackDraft(
      id: id ?? this.id,
      label: label ?? this.label,
      products: products ?? this.products,
      selected: selected ?? this.selected,
    );
  }
}
