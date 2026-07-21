import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:http/http.dart';

import '../models/response_data.dart';
import '../utils/constants/api_constants.dart';
import '../services/storage_service.dart';

class NetworkCaller {
  final int timeoutDuration = 40;

  Map<String, String> _buildHeaders({String? token}) {
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<ResponseData> getRequest(String url, {String? token}) async {
    log('GET Request: $url');
    try {
      final Response response = await get(
        Uri.parse(url),
        headers: _buildHeaders(token: token ?? StorageService.accessToken),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> postRequest(String url,
      {Map<String, dynamic>? body, String? token}) async {
    log('POST Request: $url');
    try {
      final Response response = await post(
        Uri.parse(url),
        headers: _buildHeaders(token: token ?? StorageService.accessToken),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> patchRequest(String url,
      {Map<String, dynamic>? body, String? token}) async {
    log('PATCH Request: $url');
    try {
      final Response response = await patch(
        Uri.parse(url),
        headers: _buildHeaders(token: token ?? StorageService.accessToken),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> deleteRequest(String url, {String? token}) async {
    log('DELETE Request: $url');
    try {
      final Response response = await delete(
        Uri.parse(url),
        headers: _buildHeaders(token: token ?? StorageService.accessToken),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  ResponseData _handleResponse(Response response) {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    dynamic decodedResponse;
    try {
      decodedResponse = jsonDecode(response.body);
    } on FormatException {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: response.body,
        errorMessage: 'Invalid response from server.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decodedResponse['success'] == true) {
        return ResponseData(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: '',
        );
      }
    }

    return ResponseData(
      isSuccess: false,
      statusCode: response.statusCode,
      responseData: decodedResponse,
      errorMessage: decodedResponse['message'] ?? 'An error occurred',
    );
  }

  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');
    if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: '',
        errorMessage: 'Request timeout. Please try again.',
      );
    }
    return ResponseData(
      isSuccess: false,
      statusCode: 500,
      responseData: '',
      errorMessage: 'Unexpected error occurred.',
    );
  }
}
