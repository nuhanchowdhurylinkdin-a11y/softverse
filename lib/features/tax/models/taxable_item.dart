import '../../../core/utils/constants/product_images.dart';

class TaxableItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String imageUrl;

  const TaxableItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.imageUrl,
  });

  factory TaxableItem.fromApi(Map<String, dynamic> json) {
    return TaxableItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Item',
      sku: json['sku']?.toString() ?? '',
      category: json['category']?.toString() ?? 'No Category',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}

const taxItemCategories = [
  'All Item',
  'PC Components',
  'Monitor & Display',
  'Input Devices',
];

const taxableItemCatalog = [
  TaxableItem(
    id: 'item-0',
    name: 'A4Ttech Keyboard',
    sku: 'SKU-10012',
    category: 'Input Devices',
    imageUrl: ProductImages.keyboard,
  ),
  TaxableItem(
    id: 'item-1',
    name: 'A4Ttech Mouse',
    sku: 'SKU-10013',
    category: 'Input Devices',
    imageUrl: ProductImages.mouse,
  ),
  TaxableItem(
    id: 'item-2',
    name: 'HP Monitor',
    sku: 'SKU-10014',
    category: 'Monitor & Display',
    imageUrl: ProductImages.monitor,
  ),
  TaxableItem(
    id: 'item-3',
    name: 'Logitech Keyboard',
    sku: 'SKU-10015',
    category: 'Input Devices',
    imageUrl: ProductImages.keyboard,
  ),
  TaxableItem(
    id: 'item-4',
    name: 'Logitech Mouse',
    sku: 'SKU-10016',
    category: 'Input Devices',
    imageUrl: ProductImages.mouse,
  ),
  TaxableItem(
    id: 'item-5',
    name: 'Dell Monitor',
    sku: 'SKU-10017',
    category: 'Monitor & Display',
    imageUrl: ProductImages.monitor,
  ),
  TaxableItem(
    id: 'item-6',
    name: 'Mechanical Keyboard',
    sku: 'SKU-10018',
    category: 'PC Components',
    imageUrl: ProductImages.keyboard,
  ),
  TaxableItem(
    id: 'item-7',
    name: 'Wireless Mouse',
    sku: 'SKU-10019',
    category: 'PC Components',
    imageUrl: ProductImages.mouse,
  ),
];
