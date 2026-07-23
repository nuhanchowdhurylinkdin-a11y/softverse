class ModifierProduct {
  final String name;
  final double price;

  const ModifierProduct({required this.name, required this.price});
}

class ModifierOption {
  final String label;
  final List<ModifierProduct> products;

  const ModifierOption({required this.label, required this.products});
}

class ModifierGroup {
  final List<ModifierOption> options;

  const ModifierGroup({required this.options});
}
