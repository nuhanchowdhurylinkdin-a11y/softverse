class InventoryProduct {
  final String? id;
  final String? categoryName;
  final String name;
  final String sku;
  final double price;
  final double cost;
  final String barcode;
  final bool trackStock;
  final int inStock;
  final int lowStockThreshold;
  final String imageUrl;

  const InventoryProduct({
    this.id,
    this.categoryName,
    required this.name,
    required this.sku,
    required this.price,
    required this.cost,
    required this.barcode,
    this.trackStock = true,
    required this.inStock,
    required this.lowStockThreshold,
    required this.imageUrl,
  });

  int get displayInStock => inStock < 0 ? 0 : inStock;

  bool get isOutOfStock => trackStock && inStock <= 0;

  bool get isLowStock =>
      trackStock &&
      !isOutOfStock &&
      lowStockThreshold > 0 &&
      inStock <= lowStockThreshold;

  String get stockLabel {
    if (!trackStock) return 'Stock Off';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return '$displayInStock In Stock';
  }

  factory InventoryProduct.fromApi(Map<String, dynamic> json) {
    return InventoryProduct(
      id: json['id']?.toString(),
      categoryName: json['categoryName']?.toString(),
      name: json['name']?.toString() ?? 'Unnamed Item',
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
      cost: double.tryParse('${json['cost'] ?? 0}') ?? 0,
      barcode: json['barcode']?.toString() ?? '',
      trackStock: json['trackStock'] == true,
      inStock: _intFrom(json['inStock']),
      lowStockThreshold: _intFrom(json['lowStock']),
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  static int _intFrom(dynamic value) =>
      (double.tryParse('${value ?? 0}') ?? 0).round();
}
