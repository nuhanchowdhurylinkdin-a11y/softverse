import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';

abstract interface class CategoryRepository {
  Future<ResponseData> fetchCategories();
}

class HttpCategoryRepository implements CategoryRepository {
  final NetworkCaller _networkCaller;

  HttpCategoryRepository({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  @override
  Future<ResponseData> fetchCategories() =>
      _networkCaller.getRequest(ApiConstants.categories);
}
