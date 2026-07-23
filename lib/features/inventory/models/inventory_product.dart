class InventoryProduct {
  final String name;
  final String sku;
  final double price;
  final double cost;
  final String barcode;
  final int inStock;
  final int lowStockThreshold;
  final String imageUrl;

  const InventoryProduct({
    required this.name,
    required this.sku,
    required this.price,
    required this.cost,
    required this.barcode,
    required this.inStock,
    required this.lowStockThreshold,
    required this.imageUrl,
  });

  bool get isOutOfStock => inStock <= 0;

  bool get isLowStock => !isOutOfStock && inStock <= lowStockThreshold;
}
