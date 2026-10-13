import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/constants/api_constants.dart';

abstract interface class HomeRepository {
  Future<ResponseData> fetchCategories();

  Future<ResponseData> fetchItems();

  Future<ResponseData> fetchTables();
}

class HttpHomeRepository implements HomeRepository {
  final NetworkCaller _networkCaller;

  HttpHomeRepository({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  @override
  Future<ResponseData> fetchCategories() =>
      _networkCaller.getRequest(ApiConstants.categories);

  /// Only the items sold in this till's store, at that store's price.
  @override
  Future<ResponseData> fetchItems() {
    final storeId = StorageService.storeId;
    final uri = Uri.parse(ApiConstants.inventory);
    return _networkCaller.getRequest(
      storeId == null
          ? uri.toString()
          : uri.replace(queryParameters: {'storeId': storeId}).toString(),
    );
  }

  @override
  Future<ResponseData> fetchTables() =>
      _networkCaller.getRequest(ApiConstants.tables);
}
