import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
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
    final uri = Uri.parse(ApiConstants.inventory);
    final url = stockStatus == null
        ? uri.toString()
        : uri.replace(queryParameters: {'stockStatus': stockStatus}).toString();
    return _networkCaller.getRequest(url);
  }

  @override
  Future<ResponseData> fetchCategories() =>
      _networkCaller.getRequest(ApiConstants.categories);
}
