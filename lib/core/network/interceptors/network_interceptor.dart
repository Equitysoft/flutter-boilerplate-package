import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_boilerplate/core/network/api_exceptions.dart';

/// Network Interceptor - Checks internet connectivity before making requests
class NetworkInterceptor extends Interceptor {
  final Connectivity connectivity;

  NetworkInterceptor({Connectivity? connectivity})
    : connectivity = connectivity ?? Connectivity();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check internet connectivity
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('No internet connection');

      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkException(),
        ),
      );
    }

    handler.next(options);
  }
}
