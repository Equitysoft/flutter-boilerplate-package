import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logging Interceptor - Logs API requests and responses in debug mode
class LoggingInterceptor extends Interceptor {
  final Logger _logger;
  final bool enableLogging;

  LoggingInterceptor({Logger? logger, this.enableLogging = true})
    : _logger =
          logger ??
          Logger(
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 5,
              lineLength: 80,
              colors: true,
              printEmojis: true,
            ),
          );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode && enableLogging) {
      _logger.i(
        '┌────────────────────────────────────────────────────────────────────────────────\n'
        '│ 🌐 REQUEST\n'
        '├────────────────────────────────────────────────────────────────────────────────\n'
        '│ ${options.method} ${options.uri}\n'
        '│ Headers: ${_formatHeaders(options.headers)}\n'
        '│ Data: ${_formatData(options.data)}\n'
        '└────────────────────────────────────────────────────────────────────────────────',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode && enableLogging) {
      _logger.d(
        '┌────────────────────────────────────────────────────────────────────────────────\n'
        '│ ✅ RESPONSE [${response.statusCode}]\n'
        '├────────────────────────────────────────────────────────────────────────────────\n'
        '│ ${response.requestOptions.method} ${response.requestOptions.uri}\n'
        '│ Data: ${_formatData(response.data)}\n'
        '└────────────────────────────────────────────────────────────────────────────────',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && enableLogging) {
      _logger.e(
        '┌────────────────────────────────────────────────────────────────────────────────\n'
        '│ ❌ ERROR [${err.response?.statusCode ?? 'N/A'}]\n'
        '├────────────────────────────────────────────────────────────────────────────────\n'
        '│ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
        '│ Type: ${err.type}\n'
        '│ Message: ${err.message}\n'
        '│ Response: ${_formatData(err.response?.data)}\n'
        '└────────────────────────────────────────────────────────────────────────────────',
      );
    }
    handler.next(err);
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    // Hide sensitive headers
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***HIDDEN***';
    }
    return sanitized.toString();
  }

  String _formatData(dynamic data) {
    if (data == null) return 'null';

    final str = data.toString();
    // Truncate long data
    if (str.length > 500) {
      return '${str.substring(0, 500)}... [TRUNCATED]';
    }
    return str;
  }
}
