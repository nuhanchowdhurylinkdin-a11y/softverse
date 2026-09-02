import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/features/inventory/models/modifier_group.dart';
import 'package:softverse/features/item/controller/create_item_controller.dart';
import 'package:softverse/features/item/models/combo_pack_draft.dart';

void main() {
  test('create item payload implements the complete API contract', () {
    final controller = CreateItemController();
    controller.nameController.text = 'Complete Item';
    controller.descriptionController.text = 'All API fields';
    controller.selectedCategoryId.value = 'category-id';
    controller.categoryController.text = 'Food';
    controller.soldBy.value = SoldBy.weight;
    controller.priceController.text = '20.50';
    controller.costController.text = '8.25';
    controller.skuController.text = 'SKU-1';
    controller.barcodeController.text = 'BAR-1';
    controller.trackStock.value = true;
    controller.inStockController.text = '100';
    controller.lowStockController.text = '10';

    final store = StoreInventoryDraft(storeId: 'store-id', name: 'Main');
    store.selected.value = true;
    store.inStockController.text = '50';
    store.lowStockController.text = '5';
    controller.stores.add(store);

    controller.trackDate.value = true;
    controller.manufacturingDate.value = '2026-01-01';
    controller.expireDate.value = '2027-01-01';
    controller.expirationAlertQuantityController.text = '7';
    controller.modifierEnabled.value = true;
    controller.comboPacks.add(
      const ComboPackDraft(
        id: 'combo-1',
        label: 'Sauce',
        products: [ModifierProduct(name: 'Hot', price: 1.5)],
      ),
    );

    controller.compositeItem.value = true;
    final component = CompositeComponentDraft();
    component.itemIdController.text = '8d25f0fe-f861-497e-a0ea-336b23e40614';
    component.nameController.text = 'Component';
    component.quantityController.text = '2';
    component.costController.text = '3';
    controller.compositeComponents.add(component);

    final option = VariantOptionDraft();
    option.optionNameController.text = 'Size';
    option.optionValuesController.text = 'Small, Large';
    controller.variantOptions.add(option);

    final variant = ItemVariantDraft();
    variant.nameController.text = 'Large Red';
    variant.sizeController.text = 'Large';
    variant.colorController.text = 'Red';
    variant.availableForSale.value = false;
    variant.priceController.text = '22';
    variant.costController.text = '9';
    variant.skuController.text = 'SKU-L';
    variant.barcodeController.text = 'BAR-L';
    controller.variants.add(variant);

    controller.representation.value = ItemRepresentation.image;
    controller.imageUrlController.text = 'https://example.com/item.jpg';

    final payload = controller.buildPayload()!;

    expect(payload.keys.toSet(), {
      'name',
      'description',
      'categoryId',
      'soldBy',
      'price',
      'cost',
      'sku',
      'barcode',
      'trackStock',
      'inStock',
      'lowStock',
      'stores',
      'trackExpiration',
      'manufacturingDate',
      'expirationDate',
      'expirationAlertQuantity',
      'modifierEnabled',
      'modifierGroups',
      'compositeItem',
      'compositeComponents',
      'variantOption',
      'variants',
      'representation',
      'imageUrl',
    });
    expect(payload['stores'], [
      {'storeId': 'store-id', 'inStock': 50, 'lowStock': 5},
    ]);
    expect(payload['modifierGroups'], [
      {
        'label': 'Sauce',
        'products': [
          {'name': 'Hot', 'price': 1.5},
        ],
      },
    ]);
    expect(payload['compositeComponents'], [
      {
        'itemId': '8d25f0fe-f861-497e-a0ea-336b23e40614',
        'name': 'Component',
        'quantity': 2,
        'cost': 3,
      },
    ]);
    expect(payload['variantOption'], [
      {
        'optionName': 'Size',
        'optionValue': ['Small', 'Large'],
      },
    ]);
    expect(payload['variants'], [
      {
        'name': 'Large Red',
        'size': 'Large',
        'color': 'Red',
        'availableForSale': false,
        'price': 22,
        'cost': 9,
        'sku': 'SKU-L',
        'barcode': 'BAR-L',
      },
    ]);
  });

  test('No Category omits both category id and legacy free-text name', () {
    final controller = CreateItemController();
    controller.nameController.text = 'Uncategorized item';
    controller.categoryController.text = 'Stale category text';
    controller.selectedCategoryId.value = null;

    final payload = controller.buildPayload()!;

    expect(payload.containsKey('categoryId'), isFalse);
    expect(payload.containsKey('categoryName'), isFalse);
  });

  test('untracked item omits quantities but keeps store availability', () {
    final controller = CreateItemController();
    controller.nameController.text = 'Consulting';
    controller.trackStock.value = false;
    controller.inStockController.text = '10';
    controller.lowStockController.text = '20';
    final store = StoreInventoryDraft(storeId: 'store-id', name: 'Main');
    store.selected.value = true;
    store.inStockController.text = '10';
    store.lowStockController.text = '20';
    controller.stores.add(store);

    final payload = controller.buildPayload()!;

    expect(payload['trackStock'], isFalse);
    expect(payload.containsKey('inStock'), isFalse);
    expect(payload.containsKey('lowStock'), isFalse);
    expect(payload['stores'], [
      {'storeId': 'store-id', 'inStock': 10, 'lowStock': 20},
    ]);
  });

  test('low stock threshold may be higher than the current quantity', () {
    final controller = CreateItemController();
    controller.nameController.text = 'Nearly empty item';
    controller.trackStock.value = true;
    controller.inStockController.text = '2';
    controller.lowStockController.text = '5';

    final payload = controller.buildPayload()!;

    expect(payload['inStock'], 2);
    expect(payload['lowStock'], 5);
  });

  test('color and shape representation uses the create item API fields', () {
    final controller = CreateItemController();
    controller.nameController.text = 'Blue star item';
    controller.representation.value = ItemRepresentation.colorAndShape;
    controller.selectColor(6);
    controller.selectShape(2);

    final payload = controller.buildPayload()!;

    expect(payload['representation'], 'color_and_shape');
    expect(payload['posColorIndex'], 6);
    expect(payload['posShape'], 'star');
    expect(payload.containsKey('imageUrl'), isFalse);
  });
}
