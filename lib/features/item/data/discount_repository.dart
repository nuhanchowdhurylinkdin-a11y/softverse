import '../../../core/models/response_data.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';

abstract interface class DiscountRepository {
  Future<ResponseData> fetchDiscountRules();
  Future<ResponseData> createDiscountRule(Map<String, dynamic> body);
  Future<ResponseData> updateDiscountRule(
    String id,
    Map<String, dynamic> body,
  );
  Future<ResponseData> deleteDiscountRule(String id);
}

class HttpDiscountRepository implements DiscountRepository {
  final NetworkCaller _networkCaller;

  HttpDiscountRepository({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  @override
  Future<ResponseData> fetchDiscountRules() =>
      _networkCaller.getRequest(ApiConstants.discountRules);

  @override
  Future<ResponseData> createDiscountRule(Map<String, dynamic> body) =>
      _networkCaller.postRequest(ApiConstants.discountRules, body: body);

  @override
  Future<ResponseData> updateDiscountRule(
    String id,
    Map<String, dynamic> body,
  ) => _networkCaller.patchRequest(ApiConstants.discountRule(id), body: body);

  @override
  Future<ResponseData> deleteDiscountRule(String id) =>
      _networkCaller.deleteRequest(ApiConstants.discountRule(id));
}
