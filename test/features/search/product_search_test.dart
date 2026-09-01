import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softverse/core/common/widgets/catalog_search_sheet.dart';
import 'package:softverse/features/home/controller/home_controller.dart';
import 'package:softverse/features/home/models/product.dart';
import 'package:softverse/features/inventory/controller/inventory_controller.dart';
import 'package:softverse/features/inventory/models/inventory_product.dart';

void main() {
  test('catalog search matches name, SKU, and barcode', () {
    const entry = CatalogSearchEntry(
      key: '1',
      name: 'Chicken Fry',
      sku: 'SKU-100',
      barcode: 'BAR-200',
    );

    expect(entry.matches('chicken'), isTrue);
    expect(entry.matches('sku-100'), isTrue);
    expect(entry.matches('bar-200'), isTrue);
    expect(entry.matches('missing'), isFalse);
  });

  test('home barcode lookup resolves the sellable catalog item', () {
    final controller = HomeController();
    controller.products.assignAll([
      const Product(
        id: 'item-1',
        name: 'Chicken Fry',
        sku: 'SKU-100',
        barcode: 'BAR-200',
        price: 10,
        trackStock: true,
        stockCount: 5,
        imageUrl: '',
      ),
    ]);

    expect(controller.findProductByBarcode(' bar-200 ')?.id, 'item-1');
    expect(controller.findProductByBarcode('unknown'), isNull);
  });

  test('inventory barcode lookup resolves the inventory item', () {
    final controller = InventoryController();
    controller.products.assignAll([
      const InventoryProduct(
        id: 'item-1',
        name: 'Chicken Fry',
        sku: 'SKU-100',
        barcode: 'BAR-200',
        price: 10,
        cost: 5,
        inStock: 5,
        lowStockThreshold: 2,
        imageUrl: '',
      ),
    ]);

    expect(controller.findProductByBarcode('BAR-200')?.id, 'item-1');
    expect(controller.findProductByBarcode('unknown'), isNull);
  });
}
