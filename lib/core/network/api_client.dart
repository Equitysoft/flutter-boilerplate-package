import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_boilerplate/core/network/api_config.dart';
import 'package:app_boilerplate/core/network/api_error_handler.dart';
import 'package:app_boilerplate/core/network/api_response.dart';
import 'package:app_boilerplate/core/network/interceptors/auth_interceptor.dart';
import 'package:app_boilerplate/core/network/interceptors/logging_interceptor.dart';
import 'package:app_boilerplate/core/network/interceptors/network_interceptor.dart';

/// ApiClient - Singleton service for making HTTP requests
/// Uses Dio with configured interceptors for auth, logging, and network checking
///
/// Initialize ApiConfig before using:
/// ```dart
/// ApiConfig.init(baseUrl: 'https://api.example.com');
/// // or use EnvironmentConfig for multi-environment support
/// ```
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  /// Callback when authentication fails (should navigate to login)
  VoidCallback? onAuthError;

  ApiClient._() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  /// Get singleton instance
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Reset instance (useful when API config changes)
  static void reset() {
    _instance = null;
  }

  /// Get Dio instance (for advanced usage)
  Dio get dio => _dio;

  /// Get ApiConfig
  ApiConfig get _config => ApiConfig.instance;

  /// Base options for Dio
  BaseOptions get _baseOptions {
    final config = _config;
    return BaseOptions(
      baseUrl: config.fullBaseUrl,
      connectTimeout: Duration(milliseconds: config.connectionTimeout),
      receiveTimeout: Duration(milliseconds: config.receiveTimeout),
      sendTimeout: Duration(milliseconds: config.sendTimeout),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (config.defaultHeaders != null) ...config.defaultHeaders!,
      },
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// Setup interceptors
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      // Network connectivity check
      NetworkInterceptor(),
      // Auth token injection and refresh
      AuthInterceptor(dio: _dio, onAuthError: () => onAuthError?.call()),
      // Logging (only in debug mode and if enabled)
      if (kDebugMode && _config.enableLogging) LoggingInterceptor(),
    ]);
  }

  /// Set auth error callback
  void setAuthErrorCallback(VoidCallback callback) {
    onAuthError = callback;
  }

  // ==================== HTTP Methods ====================

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // ==================== File Upload ====================

  /// Upload single file
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    required String fileKey,
    Map<String, dynamic>? extraData,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(file.path, filename: fileName),
        if (extraData != null) ...extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(contentType: 'multipart/form-data'),
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// Upload multiple files
  Future<ApiResponse<T>> uploadFiles<T>(
    String path, {
    required List<File> files,
    required String fileKey,
    Map<String, dynamic>? extraData,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final List<MultipartFile> multipartFiles = [];

      for (final file in files) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }

      final formData = FormData.fromMap({
        fileKey: multipartFiles,
        if (extraData != null) ...extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(contentType: 'multipart/form-data'),
      );

      return _handleResponse<T>(response, fromJson: fromJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // ==================== Download ====================

  /// Download file
  Future<void> downloadFile(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // ==================== Response Handler ====================

  /// Handle response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(
    Response response, {
    T Function(dynamic)? fromJson,
  }) {
    final statusCode = response.statusCode ?? 0;

    // Check for error status codes
    if (statusCode >= 400) {
      throw ApiErrorHandler.handle(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    }

    // Parse successful response
    return ApiResponse.fromJson(response.data, fromJson: fromJson);
  }

  // ==================== Cancel Token ====================

  /// Create a cancel token
  CancelToken createCancelToken() => CancelToken();

  /// Cancel a request
  void cancelRequest(CancelToken token, [String? reason]) {
    token.cancel(reason);
  }
}
