class Product {
  final String? id;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final double price;
  final bool trackStock;
  final int stockCount;
  final int lowStockThreshold;
  final String imageUrl;

  const Product({
    this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.price,
    required this.trackStock,
    required this.stockCount,
    this.lowStockThreshold = 0,
    required this.imageUrl,
  });

  int get displayStockCount => stockCount < 0 ? 0 : stockCount;

  bool get isOutOfStock => trackStock && stockCount <= 0;

  bool get isLowStock =>
      trackStock &&
      !isOutOfStock &&
      lowStockThreshold > 0 &&
      stockCount <= lowStockThreshold;

  String get stockLabel {
    if (!trackStock) return '';
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return '$displayStockCount In Stock';
  }

  factory Product.fromApi(Map<String, dynamic> json) {
    final inventory = json['inventory'] is Map
        ? Map<String, dynamic>.from(json['inventory'] as Map)
        : <String, dynamic>{};
    final representation = json['representation'] is Map
        ? Map<String, dynamic>.from(json['representation'] as Map)
        : <String, dynamic>{};
    final imageUrl = (json['imageUrl'] ?? representation['imageUrl'])
        ?.toString();
    final trackStock = json.containsKey('trackStock')
        ? json['trackStock'] == true
        : inventory['trackStock'] == true;
    return Product(
      id: json['id']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      name: json['name']?.toString() ?? 'Unnamed Item',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
      trackStock: trackStock,
      stockCount: _intFrom(json['inStock'] ?? inventory['inStock']),
      lowStockThreshold: _intFrom(json['lowStock'] ?? inventory['lowStock']),
      imageUrl: imageUrl == null || imageUrl.isEmpty ? '' : imageUrl,
    );
  }

  static int _intFrom(dynamic value) =>
      (double.tryParse('${value ?? 0}') ?? 0).round();
}
