import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

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

  bool _isRefreshing = false;

  Future<ResponseData> getRequest(String url, {String? token}) async {
    log('GET Request: $url');
    try {
      final http.Response response = await http
          .get(
            Uri.parse(url),
            headers: _buildHeaders(token: token ?? StorageService.accessToken),
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _handleResponseWithRefresh(
        response,
        retry: () => getRequest(url, token: token),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('POST Request: $url');
    try {
      final http.Response response = await http
          .post(
            Uri.parse(url),
            headers: _buildHeaders(token: token ?? StorageService.accessToken),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _handleResponseWithRefresh(
        response,
        retry: () => postRequest(url, body: body, token: token),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PATCH Request: $url');
    try {
      final http.Response response = await http
          .patch(
            Uri.parse(url),
            headers: _buildHeaders(token: token ?? StorageService.accessToken),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _handleResponseWithRefresh(
        response,
        retry: () => patchRequest(url, body: body, token: token),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> deleteRequest(String url, {String? token}) async {
    log('DELETE Request: $url');
    try {
      final http.Response response = await http
          .delete(
            Uri.parse(url),
            headers: _buildHeaders(token: token ?? StorageService.accessToken),
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _handleResponseWithRefresh(
        response,
        retry: () => deleteRequest(url, token: token),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> multipartRequest(
    String url, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'image',
    String? token,
  }) async {
    log('MULTIPART Request: $url');
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      final bearer = token ?? StorageService.accessToken;
      if (bearer != null) {
        request.headers['Authorization'] = 'Bearer $bearer';
      }
      request.fields.addAll(fields);
      if (file != null) {
        final mimeType =
            lookupMimeType(file.path) ?? _mimeTypeFromExtension(file.path);
        final mediaType = mimeType == null ? null : MediaType.parse(mimeType);
        request.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            file.path,
            contentType: mediaType,
          ),
        );
      }
      final streamed = await request.send().timeout(
        Duration(seconds: timeoutDuration),
      );
      final response = await http.Response.fromStream(streamed);
      return _handleResponseWithRefresh(
        response,
        retry: () => multipartRequest(
          url,
          fields: fields,
          file: file,
          fileField: fileField,
          token: token,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> _handleResponseWithRefresh(
    http.Response response, {
    required Future<ResponseData> Function() retry,
  }) async {
    if (response.statusCode == 401 &&
        StorageService.refreshToken != null &&
        !_isRefreshing) {
      final refreshed = await _refreshTokens();
      if (refreshed) return retry();
    }
    return _handleResponse(response);
  }

  ResponseData _handleResponse(http.Response response) {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    dynamic decodedResponse;
    try {
      decodedResponse = response.body.isEmpty ? {} : jsonDecode(response.body);
    } on FormatException {
      return ResponseData(
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        responseData: response.body,
        errorMessage: response.statusCode >= 200 && response.statusCode < 300
            ? ''
            : 'Invalid response from server.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ResponseData(
        isSuccess: true,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: '',
      );
    }

    return ResponseData(
      isSuccess: false,
      statusCode: response.statusCode,
      responseData: decodedResponse,
      errorMessage: decodedResponse is Map
          ? _errorMessageFrom(decodedResponse)
          : 'An error occurred',
    );
  }

  String _errorMessageFrom(Map<dynamic, dynamic> decodedResponse) {
    final directMessage = decodedResponse['message'];
    if (directMessage is List) return directMessage.join(', ');
    if (directMessage != null) return directMessage.toString();
    final nestedError = decodedResponse['error'];
    if (nestedError is Map && nestedError['message'] != null) {
      final nestedMessage = nestedError['message'];
      if (nestedMessage is List) return nestedMessage.join(', ');
      return nestedMessage.toString();
    }
    return 'An error occurred';
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = StorageService.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    _isRefreshing = true;
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.refresh),
            headers: _buildHeaders(),
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(Duration(seconds: timeoutDuration));
      final parsed = _handleResponse(response);
      if (!parsed.isSuccess || parsed.responseData is! Map) {
        await StorageService.logoutUser();
        return false;
      }

      final data = Map<String, dynamic>.from(parsed.responseData as Map);
      final accessToken = data['accessToken']?.toString();
      final newRefreshToken = data['refreshToken']?.toString();
      if (accessToken == null || newRefreshToken == null) {
        await StorageService.logoutUser();
        return false;
      }
      await StorageService.updateTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } catch (error) {
      log('Refresh token error: $error');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');
    if (error is SocketException || error is http.ClientException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 0,
        responseData: '',
        errorMessage: 'No connection to server.',
      );
    }
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

  String? _mimeTypeFromExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return null;
  }
}
