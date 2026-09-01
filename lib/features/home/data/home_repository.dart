import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
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

  @override
  Future<ResponseData> fetchItems() =>
      _networkCaller.getRequest(ApiConstants.inventory);

  @override
  Future<ResponseData> fetchTables() =>
      _networkCaller.getRequest(ApiConstants.tables);
}
