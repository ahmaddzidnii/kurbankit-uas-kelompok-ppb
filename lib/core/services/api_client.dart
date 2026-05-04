import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:qurban_kit/core/configs/api_config.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  String? _authToken;
  VoidCallback? _onUnauthorized;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
      ),
    );
  }

  /// Set token untuk request berikutnya
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Set callback untuk unauthorized (401) error
  void setOnUnauthorized(VoidCallback callback) {
    _onUnauthorized = callback;
  }

  /// Clear callback
  void clearOnUnauthorized() {
    _onUnauthorized = null;
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _getOptions(),
      );
      return response.data; // Return langsung response data
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, {required dynamic data}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: _getOptions(),
      );
      return response.data; // Return langsung response data
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, {required dynamic data}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: _getOptions(),
      );
      return response.data; // Return langsung response data
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint, options: _getOptions());
      return response.data; // Return langsung response data
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // Private Methods

  /// Get options dengan authorization header
  Options _getOptions() {
    final headers = <String, dynamic>{'Content-Type': 'application/json'};

    // Tambahkan token jika ada
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return Options(headers: headers);
  }

  /// Handle error
  void _handleError(DioException error) {
    // Timeout
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw NetworkException(message: 'Koneksi timeout. Coba lagi.');
    }

    // Response error (4xx, 5xx)
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // 401 Unauthorized
      if (statusCode == 401) {
        // Trigger callback jika ada
        _onUnauthorized?.call();

        throw UnauthorizedException(
          message:
              data?['message'] ??
              'Token sudah kadaluarsa. Silakan login kembali.',
        );
      }

      // 422 Validation Error
      if (statusCode == 422) {
        throw ValidationException(
          message: data?['message'] ?? 'Validasi gagal',
          errors: data?['errors'],
        );
      }

      // Error lainnya
      throw ServerException(
        message: data?['message'] ?? 'Terjadi kesalahan server',
        statusCode: statusCode,
        response: data,
      );
    }

    // No internet
    throw NetworkException(message: 'Tidak ada koneksi internet');
  }
}
