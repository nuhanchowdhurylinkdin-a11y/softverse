import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';

abstract interface class CategoryRepository {
  Future<ResponseData> fetchCategories();
  Future<ResponseData> fetchAdminCategories();
  Future<ResponseData> createCategory(Map<String, dynamic> body);
  Future<ResponseData> updateCategory(String id, Map<String, dynamic> body);
  Future<ResponseData> deleteCategory(String id);
}

class HttpCategoryRepository implements CategoryRepository {
  final NetworkCaller _networkCaller;

  HttpCategoryRepository({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  @override
  Future<ResponseData> fetchCategories() =>
      _networkCaller.getRequest(ApiConstants.categories);

  @override
  Future<ResponseData> fetchAdminCategories() =>
      _networkCaller.getRequest(ApiConstants.categoryAdmin);

  @override
  Future<ResponseData> createCategory(Map<String, dynamic> body) =>
      _networkCaller.postRequest(ApiConstants.categories, body: body);

  @override
  Future<ResponseData> updateCategory(String id, Map<String, dynamic> body) =>
      _networkCaller.patchRequest(ApiConstants.category(id), body: body);

  @override
  Future<ResponseData> deleteCategory(String id) =>
      _networkCaller.deleteRequest(ApiConstants.category(id));
}
