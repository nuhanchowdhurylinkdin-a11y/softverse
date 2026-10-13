import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softverse/core/models/response_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softverse/core/services/network_caller.dart';
import 'package:softverse/core/services/storage_service.dart';
import 'package:softverse/features/home/data/home_repository.dart';
import 'package:softverse/features/inventory/data/inventory_repository.dart';
import 'package:softverse/features/item/data/category_repository.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'BASE_URL=https://phase-one.test');
  });

  test('home repository keeps catalog endpoints injectable', () async {
    final network = _RecordingNetworkCaller();
    final repository = HttpHomeRepository(networkCaller: network);

    await repository.fetchCategories();
    await repository.fetchItems();
    await repository.fetchTables();

    expect(network.urls, [
      'https://phase-one.test/categories',
      'https://phase-one.test/inventory',
      'https://phase-one.test/tables',
    ]);
  });

  test('inventory repository serializes stock filters independently', () async {
    final network = _RecordingNetworkCaller();
    final repository = HttpInventoryRepository(networkCaller: network);

    await repository.fetchInventory();
    await repository.fetchInventory(stockStatus: 'low_stock');
    await repository.fetchInventory(stockStatus: 'out_of_stock');

    expect(network.urls, [
      'https://phase-one.test/inventory',
      'https://phase-one.test/inventory?stockStatus=low_stock',
      'https://phase-one.test/inventory?stockStatus=out_of_stock',
    ]);
  });

  test('item lists ask for this till\'s store only', () async {
    SharedPreferences.setMockInitialValues({
      'businessId': 'business-1',
      'storeId': 'store-1',
      'storeBusinessId': 'business-1',
    });
    await StorageService.init();
    final network = _RecordingNetworkCaller();

    await HttpHomeRepository(networkCaller: network).fetchItems();
    await HttpInventoryRepository(
      networkCaller: network,
    ).fetchInventory(stockStatus: 'low_stock');

    expect(network.urls, [
      'https://phase-one.test/inventory?storeId=store-1',
      'https://phase-one.test/inventory?storeId=store-1&stockStatus=low_stock',
    ]);
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test(
    'category repository uses the active and management API routes',
    () async {
      final network = _RecordingNetworkCaller();
      final repository = HttpCategoryRepository(networkCaller: network);

      await repository.fetchCategories();
      await repository.fetchAdminCategories();
      await repository.createCategory({'name': 'Food'});
      await repository.updateCategory('category-id', {'name': 'Fresh Food'});
      await repository.deleteCategory('category-id');

      expect(network.calls, [
        'GET https://phase-one.test/categories',
        'GET https://phase-one.test/categories/admin?limit=100',
        'POST https://phase-one.test/categories',
        'PATCH https://phase-one.test/categories/category-id',
        'DELETE https://phase-one.test/categories/category-id',
      ]);
    },
  );
}

class _RecordingNetworkCaller extends NetworkCaller {
  final calls = <String>[];
  List<String> get urls => calls
      .where((call) => call.startsWith('GET '))
      .map((call) => call.substring(4))
      .toList();

  @override
  Future<ResponseData> getRequest(String url, {String? token}) async {
    calls.add('GET $url');
    return _success();
  }

  @override
  Future<ResponseData> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    calls.add('POST $url');
    return _success();
  }

  @override
  Future<ResponseData> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    calls.add('PATCH $url');
    return _success();
  }

  @override
  Future<ResponseData> deleteRequest(String url, {String? token}) async {
    calls.add('DELETE $url');
    return _success();
  }

  ResponseData _success() {
    return ResponseData(
      isSuccess: true,
      statusCode: 200,
      errorMessage: '',
      responseData: const <String, dynamic>{},
    );
  }
}
