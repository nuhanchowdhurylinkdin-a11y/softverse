class Product {
  final String? id;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final double price;
  final bool trackStock;
  final int stockCount;
  final String imageUrl;

  const Product({
    this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.price,
    required this.trackStock,
    required this.stockCount,
    required this.imageUrl,
  });

  factory Product.fromApi(Map<String, dynamic> json) {
    final inventory = json['inventory'] is Map
        ? Map<String, dynamic>.from(json['inventory'] as Map)
        : <String, dynamic>{};
    final representation = json['representation'] is Map
        ? Map<String, dynamic>.from(json['representation'] as Map)
        : <String, dynamic>{};
    final imageUrl = representation['imageUrl']?.toString();
    return Product(
      id: json['id']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      name: json['name']?.toString() ?? 'Unnamed Item',
      price: double.tryParse('${json['price'] ?? 0}') ?? 0,
      trackStock: inventory['trackStock'] == true,
      stockCount: (double.tryParse('${inventory['inStock'] ?? 0}') ?? 0)
          .round(),
      imageUrl: imageUrl == null || imageUrl.isEmpty ? '' : imageUrl,
    );
  }
}
