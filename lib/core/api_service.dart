import 'dart:convert';
import 'package:get/get.dart';
import 'constants.dart';

/// Centralized API service using GetConnect for EduSarthi.
class ApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = AppConstants.baseUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 60);

    // Request modifier
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      print('🌐 API Request: ${request.method} ${request.url}');
      return request;
    });

    // Response modifier for debugging
    httpClient.addResponseModifier((request, response) {
      print('✅ API Response: ${response.statusCode} from ${request.url}');
      return response;
    });

    super.onInit();
    print('🔗 API Base URL: ${AppConstants.baseUrl}');
  }

  /// POST request with JSON body.
  Future<Map<String, dynamic>> postApi(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await post(endpoint, body);
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.body is Map<String, dynamic>) {
          return response.body;
        }
        return jsonDecode(response.bodyString ?? '{}');
      } else {
        final error = response.body;
        final msg = error is Map
            ? (error['detail'] ?? 'Something went wrong')
            : 'Error ${response.statusCode}';
        print('❌ API Error: $msg');
        throw ApiException(msg.toString(), statusCode: response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Network Error: $e');
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// GET request.
  Future<Map<String, dynamic>> getApi(String endpoint) async {
    try {
      final response = await get(endpoint);
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.body is Map<String, dynamic>) {
          return response.body;
        }
        return jsonDecode(response.bodyString ?? '{}');
      } else {
        throw ApiException(
          'Error ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
