import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/features/inventory/models/inventory_product.dart';

void main() {
  InventoryProduct product({
    required bool trackStock,
    required int inStock,
    int lowStock = 5,
  }) {
    return InventoryProduct(
      name: 'Item',
      sku: 'SKU',
      price: 10,
      cost: 5,
      barcode: 'BAR',
      trackStock: trackStock,
      inStock: inStock,
      lowStockThreshold: lowStock,
      imageUrl: '',
    );
  }

  test('untracked item has no stock status', () {
    final item = product(trackStock: false, inStock: 0);

    expect(item.stockLabel, isEmpty);
    expect(item.isOutOfStock, isFalse);
    expect(item.isLowStock, isFalse);
  });

  test('tracked item exposes in, low, and out statuses', () {
    expect(product(trackStock: true, inStock: 8).stockLabel, '8 In Stock');
    expect(product(trackStock: true, inStock: 5).stockLabel, 'Low Stock');
    expect(product(trackStock: true, inStock: 0).stockLabel, 'Out of Stock');
  });
}
