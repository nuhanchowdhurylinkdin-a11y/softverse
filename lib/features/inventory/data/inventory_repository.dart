import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';

abstract interface class InventoryRepository {
  Future<ResponseData> fetchInventory({String? stockStatus});

  Future<ResponseData> fetchCategories();
}

class HttpInventoryRepository implements InventoryRepository {
  final NetworkCaller _networkCaller;

  HttpInventoryRepository({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  @override
  Future<ResponseData> fetchInventory({String? stockStatus}) {
    final query = {
      'storeId': ?StorageService.storeId,
      'stockStatus': ?stockStatus,
    };
    final uri = Uri.parse(ApiConstants.inventory);
    return _networkCaller.getRequest(
      query.isEmpty
          ? uri.toString()
          : uri.replace(queryParameters: query).toString(),
    );
  }

  @override
  Future<ResponseData> fetchCategories() =>
      _networkCaller.getRequest(ApiConstants.categories);
}
