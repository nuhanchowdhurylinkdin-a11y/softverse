import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/services/offline_database_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../routes/app_routes.dart';
import '../../inventory/models/modifier_group.dart';
import '../../home/controller/home_controller.dart';
import '../models/combo_pack_draft.dart';
import '../data/category_repository.dart';

enum SoldBy { pcs, weight }

enum ItemRepresentation { colorAndShape, image }

class CreateItemController extends GetxController {
  final NetworkCaller _networkCaller;
  final CategoryRepository _categoryRepository;
  final ImagePicker _imagePicker = ImagePicker();

  CreateItemController({
    NetworkCaller? networkCaller,
    CategoryRepository? categoryRepository,
  }) : _networkCaller = networkCaller ?? NetworkCaller(),
       _categoryRepository = categoryRepository ?? HttpCategoryRepository();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final costController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final inStockController = TextEditingController();
  final lowStockController = TextEditingController();
  final expirationAlertQuantityController = TextEditingController();
  final imageUrlController = TextEditingController();

  final soldBy = Rx<SoldBy?>(SoldBy.pcs);
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnString();

  final trackStock = false.obs;
  final stores = <StoreInventoryDraft>[].obs;
  final isLoadingStores = false.obs;
  final storeLoadFailed = false.obs;
  final trackDate = false.obs;
  final manufacturingDate = '2025-02-01'.obs;
  final expireDate = '2028-02-01'.obs;

  final modifierEnabled = false.obs;
  final comboPacks = <ComboPackDraft>[].obs;

  final compositeItem = false.obs;
  final compositeComponents = <CompositeComponentDraft>[].obs;
  final variantOptions = <VariantOptionDraft>[].obs;
  final variants = <ItemVariantDraft>[].obs;

  final representation = ItemRepresentation.colorAndShape.obs;
  final selectedColorIndex = 0.obs;
  final selectedShapeIndex = 0.obs;
  final selectedImage = Rxn<File>();
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchStores();
  }

  void selectSoldBy(SoldBy value) => soldBy.value = value;

  void toggleTrackStock() => trackStock.value = !trackStock.value;

  void toggleTrackDate() => trackDate.value = !trackDate.value;

  void toggleModifier() => modifierEnabled.value = !modifierEnabled.value;

  void toggleCompositeItem() => compositeItem.toggle();

  void addCompositeComponent() =>
      compositeComponents.add(CompositeComponentDraft());

  void removeCompositeComponent(int index) {
    compositeComponents.removeAt(index).dispose();
  }

  void addVariantOption() => variantOptions.add(VariantOptionDraft());

  void removeVariantOption(int index) {
    variantOptions.removeAt(index).dispose();
  }

  void addVariant() => variants.add(ItemVariantDraft());

  void removeVariant(int index) {
    variants.removeAt(index).dispose();
  }

  void toggleComboPackSelection(int index) {
    comboPacks[index] = comboPacks[index].copyWith(
      selected: !comboPacks[index].selected,
    );
  }

  Future<void> openComboPackEditor({int? index}) async {
    final existing = index == null ? null : comboPacks[index];

    await Get.bottomSheet(
      _ComboPackEditorSheet(
        existing: existing,
        isEditing: index != null,
        onSave: (draft) {
          if (index == null) {
            comboPacks.add(draft);
          } else {
            comboPacks[index] = draft;
          }
        },
      ),
      isScrollControlled: true,
    );
  }

  void removeComboPack(int index) {
    comboPacks.removeAt(index);
  }

  void selectRepresentation(ItemRepresentation value) =>
      representation.value = value;

  void selectColor(int index) => selectedColorIndex.value = index;

  void selectShape(int index) => selectedShapeIndex.value = index;

  Future<void> fetchCategories() async {
    final cached = OfflineDatabaseService.readCache<List<dynamic>>(
      'categories',
    );
    if (cached != null) _applyCategories(cached);
    final response = await _categoryRepository.fetchCategories();
    if (!response.isSuccess || response.responseData is! List) return;
    final data = List<dynamic>.from(response.responseData as List);
    await OfflineDatabaseService.saveCache('categories', data);
    _applyCategories(data);
  }

  Future<void> fetchStores() async {
    isLoadingStores.value = true;
    storeLoadFailed.value = false;
    final response = await _networkCaller.getRequest(
      ApiConstants.itemAdminFilters,
    );
    isLoadingStores.value = false;
    if (!response.isSuccess || response.responseData is! Map) {
      storeLoadFailed.value = true;
      return;
    }
    final rawStores = (response.responseData as Map)['stores'];
    if (rawStores is! List) {
      storeLoadFailed.value = true;
      return;
    }
    for (final draft in stores) {
      draft.dispose();
    }
    stores.assignAll(
      rawStores.whereType<Map>().map(
        (entry) => StoreInventoryDraft(
          storeId: entry['id']?.toString() ?? '',
          name: entry['name']?.toString() ?? 'Store',
        ),
      ),
    );
  }

  void openCategoryPicker() {
    if (categories.isEmpty) {
      AppHelperFunctions.showWarningSnackBar('No categories found.');
      return;
    }
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: categories
                .map(
                  (category) => ListTile(
                    title: Text(category['name']?.toString() ?? 'Category'),
                    onTap: () {
                      selectedCategoryId.value = category['id']?.toString();
                      categoryController.text =
                          category['name']?.toString() ?? '';
                      Get.back();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> pickManufacturingDate() async {
    final picked = await _pickDate(manufacturingDate.value);
    if (picked != null) manufacturingDate.value = picked;
  }

  Future<void> pickExpireDate() async {
    final picked = await _pickDate(expireDate.value);
    if (picked != null) expireDate.value = picked;
  }

  Future<void> openScanBarcode() async {
    final result = await Get.toNamed(AppRoute.getScanBarcodeScreen());
    if (result is String && result.isNotEmpty) {
      barcodeController.text = result;
    }
  }

  Future<void> choosePhoto() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage.value = File(image.path);
  }

  Future<void> takePhoto() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) selectedImage.value = File(image.path);
  }

  Future<void> save() async {
    final payload = buildPayload();
    if (payload == null) return;

    isSaving.value = true;
    final online = Get.isRegistered<SyncService>()
        ? Get.find<SyncService>().isOnline.value
        : true;
    final response = online ? await _sendCreateItem(payload) : null;
    isSaving.value = false;

    if (response != null && response.isSuccess) {
      AppHelperFunctions.showSuccessSnackBar('Item created.');
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().forceSync(showMessage: false);
      }
      Get.back();
      return;
    }

    if (response != null &&
        response.statusCode != 0 &&
        response.statusCode != 408) {
      AppHelperFunctions.showErrorSnackBar(response.errorMessage);
      return;
    }

    await OfflineDatabaseService.enqueue(
      type: OfflineActionType.createItem,
      payload: {
        ...payload,
        if (selectedImage.value != null) 'imagePath': selectedImage.value!.path,
      },
    );
    AppHelperFunctions.showWarningSnackBar(
      'Item saved locally. It will sync when the server is reachable.',
    );
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().addLocalItem(_localItemPayload(payload));
    }
    if (Get.isRegistered<SyncService>() &&
        Get.find<SyncService>().isOnline.value) {
      unawaited(Get.find<SyncService>().syncPendingActions());
    }
    Get.back();
  }

  Future<dynamic> _sendCreateItem(Map<String, dynamic> payload) {
    if (selectedImage.value != null &&
        representation.value == ItemRepresentation.image) {
      return _networkCaller.multipartRequest(
        ApiConstants.items,
        fields: payload.map(
          (key, value) => MapEntry(
            key,
            value is List || value is Map ? jsonEncode(value) : '$value',
          ),
        ),
        file: selectedImage.value,
      );
    }
    return _networkCaller.postRequest(ApiConstants.items, body: payload);
  }

  Map<String, dynamic>? buildPayload() {
    if (nameController.text.trim().isEmpty) {
      AppHelperFunctions.showErrorSnackBar('Item name is required.');
      return null;
    }
    if (soldBy.value == null) {
      AppHelperFunctions.showErrorSnackBar('Select sold by option.');
      return null;
    }
    if (representation.value == ItemRepresentation.image &&
        selectedImage.value == null &&
        imageUrlController.text.trim().isEmpty) {
      AppHelperFunctions.showErrorSnackBar(
        'Select an item image or provide an image URL.',
      );
      return null;
    }
    final inStock = _number(inStockController.text) ?? 0;
    final lowStock = _number(lowStockController.text) ?? 0;
    if (trackDate.value &&
        DateTime.parse(
          manufacturingDate.value,
        ).isAfter(DateTime.parse(expireDate.value))) {
      AppHelperFunctions.showErrorSnackBar(
        'Manufacturing date cannot be after expiration date.',
      );
      return null;
    }
    if (compositeItem.value &&
        compositeComponents.any(
          (entry) =>
              entry.itemIdController.text.trim().isEmpty ||
              (_number(entry.quantityController.text) ?? 0) <= 0,
        )) {
      AppHelperFunctions.showErrorSnackBar(
        'Every composite component needs an item ID and quantity.',
      );
      return null;
    }
    if (variantOptions.any((entry) {
      final payload = entry.toPayload();
      return (payload['optionName'] as String).isEmpty ||
          (payload['optionValue'] as List).isEmpty;
    })) {
      AppHelperFunctions.showErrorSnackBar(
        'Every variant option needs a name and at least one value.',
      );
      return null;
    }

    return {
      'name': nameController.text.trim(),
      if (descriptionController.text.trim().isNotEmpty)
        'description': descriptionController.text.trim(),
      if (selectedCategoryId.value != null)
        'categoryId': selectedCategoryId.value,
      if (categoryController.text.trim().isNotEmpty)
        'categoryName': categoryController.text.trim(),
      'soldBy': soldBy.value == SoldBy.weight ? 'weight' : 'pcs',
      if (_number(priceController.text) != null)
        'price': _number(priceController.text),
      if (_number(costController.text) != null)
        'cost': _number(costController.text),
      if (skuController.text.trim().isNotEmpty)
        'sku': skuController.text.trim(),
      if (barcodeController.text.trim().isNotEmpty)
        'barcode': barcodeController.text.trim(),
      'trackStock': trackStock.value,
      if (trackStock.value) 'inStock': inStock,
      if (trackStock.value) 'lowStock': lowStock,
      if (stores.any((store) => store.selected.value))
        'stores': stores
            .where((store) => store.selected.value)
            .map((store) => store.toPayload(_number))
            .toList(),
      'trackExpiration': trackDate.value,
      if (trackDate.value) 'manufacturingDate': manufacturingDate.value,
      if (trackDate.value) 'expirationDate': expireDate.value,
      if (trackDate.value &&
          _number(expirationAlertQuantityController.text) != null)
        'expirationAlertQuantity': _number(
          expirationAlertQuantityController.text,
        ),
      'modifierEnabled': modifierEnabled.value,
      if (modifierEnabled.value)
        'modifierGroups': comboPacks
            .where((comboPack) => comboPack.selected)
            .map(
              (comboPack) => {
                'label': comboPack.label,
                'products': comboPack.products
                    .map(
                      (product) => {
                        'name': product.name,
                        'price': product.price,
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      'compositeItem': compositeItem.value,
      if (compositeItem.value)
        'compositeComponents': compositeComponents
            .map((component) => component.toPayload(_number))
            .toList(),
      if (variantOptions.isNotEmpty)
        'variantOption': variantOptions
            .map((option) => option.toPayload())
            .where((option) => (option['optionName'] as String).isNotEmpty)
            .toList(),
      if (variants.isNotEmpty)
        'variants': variants
            .map((variant) => variant.toPayload(_number))
            .toList(),
      'representation': representation.value == ItemRepresentation.image
          ? 'image'
          : 'color_and_shape',
      if (representation.value == ItemRepresentation.colorAndShape)
        'posColorIndex': selectedColorIndex.value,
      if (representation.value == ItemRepresentation.colorAndShape)
        'posShape': _shapeValue(selectedShapeIndex.value),
      if (representation.value == ItemRepresentation.image &&
          imageUrlController.text.trim().isNotEmpty)
        'imageUrl': imageUrlController.text.trim(),
    };
  }

  Map<String, dynamic> _localItemPayload(Map<String, dynamic> payload) {
    return {
      'id': 'local-${DateTime.now().microsecondsSinceEpoch}',
      'name': payload['name'],
      'categoryId': payload['categoryId'],
      'categoryName': payload['categoryName'],
      'description': payload['description'],
      'soldBy': payload['soldBy'],
      'price': payload['price'],
      'cost': payload['cost'],
      'sku': payload['sku'],
      'barcode': payload['barcode'],
      'inventory': {
        'trackStock': payload['trackStock'] == true,
        'inStock': payload['inStock'],
        'lowStock': payload['lowStock'],
        'stores': payload['stores'] ?? [],
      },
      'expiration': {
        'trackExpiration': payload['trackExpiration'] == true,
        'manufacturingDate': payload['manufacturingDate'],
        'expirationDate': payload['expirationDate'],
        'alertQuantity': payload['expirationAlertQuantity'],
      },
      'composite': {
        'enabled': payload['compositeItem'] == true,
        'components': payload['compositeComponents'] ?? [],
      },
      'variantOption': payload['variantOption'] ?? [],
      'variants': payload['variants'] ?? [],
      'modifiers': {
        'enabled': payload['modifierEnabled'] == true,
        'groups': payload['modifierGroups'] ?? [],
      },
      'representation': {
        'type': payload['representation'],
        'colorIndex': payload['posColorIndex'],
        'shape': payload['posShape'],
        'imageUrl': selectedImage.value?.path,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'isLocalOnly': true,
    };
  }

  void _applyCategories(List<dynamic> data) {
    categories.assignAll(
      data
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(),
    );
  }

  Future<String?> _pickDate(String initialValue) async {
    final initial = DateTime.tryParse(initialValue) ?? DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return null;
    return picked.toIso8601String().split('T').first;
  }

  double? _number(String value) {
    final cleaned = value.replaceAll('\$', '').replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  String _shapeValue(int index) {
    return switch (index) {
      1 => 'circle',
      2 => 'star',
      3 => 'hexagon',
      _ => 'square',
    };
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    costController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    inStockController.dispose();
    lowStockController.dispose();
    expirationAlertQuantityController.dispose();
    imageUrlController.dispose();
    for (final store in stores) {
      store.dispose();
    }
    for (final component in compositeComponents) {
      component.dispose();
    }
    for (final option in variantOptions) {
      option.dispose();
    }
    for (final variant in variants) {
      variant.dispose();
    }
    super.onClose();
  }
}

class StoreInventoryDraft {
  final String storeId;
  final String name;
  final selected = false.obs;
  final inStockController = TextEditingController();
  final lowStockController = TextEditingController();

  StoreInventoryDraft({required this.storeId, required this.name});

  Map<String, dynamic> toPayload(double? Function(String) number) => {
    'storeId': storeId,
    'inStock': number(inStockController.text) ?? 0,
    'lowStock': number(lowStockController.text) ?? 0,
  };

  void dispose() {
    inStockController.dispose();
    lowStockController.dispose();
  }
}

class CompositeComponentDraft {
  final itemIdController = TextEditingController();
  final nameController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final costController = TextEditingController();

  Map<String, dynamic> toPayload(double? Function(String) number) => {
    'itemId': itemIdController.text.trim(),
    if (nameController.text.trim().isNotEmpty)
      'name': nameController.text.trim(),
    'quantity': number(quantityController.text) ?? 1,
    if (number(costController.text) != null)
      'cost': number(costController.text),
  };

  void dispose() {
    itemIdController.dispose();
    nameController.dispose();
    quantityController.dispose();
    costController.dispose();
  }
}

class VariantOptionDraft {
  final optionNameController = TextEditingController();
  final optionValuesController = TextEditingController();

  Map<String, dynamic> toPayload() => {
    'optionName': optionNameController.text.trim(),
    'optionValue': optionValuesController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(),
  };

  void dispose() {
    optionNameController.dispose();
    optionValuesController.dispose();
  }
}

class ItemVariantDraft {
  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();
  final costController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final availableForSale = true.obs;

  Map<String, dynamic> toPayload(double? Function(String) number) => {
    if (nameController.text.trim().isNotEmpty)
      'name': nameController.text.trim(),
    if (sizeController.text.trim().isNotEmpty)
      'size': sizeController.text.trim(),
    if (colorController.text.trim().isNotEmpty)
      'color': colorController.text.trim(),
    'availableForSale': availableForSale.value,
    if (number(priceController.text) != null)
      'price': number(priceController.text),
    if (number(costController.text) != null)
      'cost': number(costController.text),
    if (skuController.text.trim().isNotEmpty) 'sku': skuController.text.trim(),
    if (barcodeController.text.trim().isNotEmpty)
      'barcode': barcodeController.text.trim(),
  };

  void dispose() {
    nameController.dispose();
    sizeController.dispose();
    colorController.dispose();
    priceController.dispose();
    costController.dispose();
    skuController.dispose();
    barcodeController.dispose();
  }
}

class _ComboProductControllers {
  final TextEditingController nameController;
  final TextEditingController priceController;

  _ComboProductControllers({
    TextEditingController? nameController,
    TextEditingController? priceController,
  }) : nameController = nameController ?? TextEditingController(),
       priceController = priceController ?? TextEditingController();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class _ComboPackEditorSheet extends StatefulWidget {
  final ComboPackDraft? existing;
  final bool isEditing;
  final ValueChanged<ComboPackDraft> onSave;

  const _ComboPackEditorSheet({
    required this.existing,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_ComboPackEditorSheet> createState() => _ComboPackEditorSheetState();
}

class _ComboPackEditorSheetState extends State<_ComboPackEditorSheet> {
  late final TextEditingController _labelController;
  late final List<_ComboProductControllers> _productControllers;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existing?.label ?? '',
    );
    _productControllers =
        (widget.existing?.products ?? const <ModifierProduct>[])
            .map(
              (product) => _ComboProductControllers(
                nameController: TextEditingController(text: product.name),
                priceController: TextEditingController(
                  text: product.price.toStringAsFixed(2),
                ),
              ),
            )
            .toList();
    if (_productControllers.isEmpty) {
      _productControllers.add(_ComboProductControllers());
    }
  }

  void _addProductRow() {
    setState(() {
      _productControllers.add(_ComboProductControllers());
    });
  }

  void _removeProductRow(int rowIndex) {
    if (_productControllers.length == 1) return;
    final row = _productControllers.removeAt(rowIndex);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  void _save() {
    final label = _labelController.text.trim();
    final products = _productControllers
        .map(
          (row) => ModifierProduct(
            name: row.nameController.text.trim(),
            price:
                double.tryParse(
                  row.priceController.text
                      .replaceAll('\$', '')
                      .replaceAll(',', '')
                      .trim(),
                ) ??
                -1,
          ),
        )
        .where((product) => product.name.isNotEmpty)
        .toList();

    if (label.isEmpty) {
      AppHelperFunctions.showErrorSnackBar('Combo pack name is required.');
      return;
    }
    if (products.isEmpty) {
      AppHelperFunctions.showErrorSnackBar(
        'Add at least one combo pack product.',
      );
      return;
    }
    if (products.any((product) => product.price < 0)) {
      AppHelperFunctions.showErrorSnackBar(
        'Every combo pack product needs a valid price.',
      );
      return;
    }

    widget.onSave(
      ComboPackDraft(
        id:
            widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        label: label,
        products: products,
        selected: widget.existing?.selected ?? true,
      ),
    );
    Get.back();
  }

  @override
  void dispose() {
    _labelController.dispose();
    for (final row in _productControllers) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEditing ? 'Edit Combo Pack' : 'Create Combo Pack',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Combo pack name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ..._productControllers.asMap().entries.map((entry) {
                final rowIndex = entry.key;
                final row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: row.nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: row.priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeProductRow(rowIndex),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addProductRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _save,
                child: Text(
                  widget.isEditing ? 'Save changes' : 'Create combo pack',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
