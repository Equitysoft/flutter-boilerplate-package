import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_boilerplate/services/prefs_service.dart';

/// Auth Interceptor - Handles adding auth token and token refresh
class AuthInterceptor extends Interceptor {
  final Dio dio;

  /// Callback when token refresh fails (should navigate to login)
  final VoidCallback? onAuthError;

  AuthInterceptor({required this.dio, this.onAuthError});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    final token = PrefsService.instance.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add common headers
    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    debugPrint('API Request: ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      'API Response: ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint(
      'API Error: ${err.response?.statusCode} ${err.requestOptions.path}',
    );

    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry the original request
        try {
          final response = await _retryRequest(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Retry failed
          debugPrint('Retry failed: $e');
        }
      }

      // Token refresh failed - logout
      await _handleAuthFailure();
      onAuthError?.call();
    }

    handler.next(err);
  }

  /// Try to refresh the access token
  Future<bool> _tryRefreshToken() async {
    final refreshToken = PrefsService.instance.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      debugPrint('Attempting token refresh...');

      // Create a new Dio instance to avoid interceptor loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh', // Adjust this endpoint as needed
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await PrefsService.instance.setAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await PrefsService.instance.setRefreshToken(newRefreshToken);
          }
          debugPrint('Token refresh successful');
          return true;
        }
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    return false;
  }

  /// Retry the failed request with new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final token = PrefsService.instance.accessToken;

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );

    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Handle authentication failure
  Future<void> _handleAuthFailure() async {
    debugPrint('Authentication failed - clearing tokens');
    await PrefsService.instance.clearUserData();
  }
}
