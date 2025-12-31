import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App Logger - Centralized logging utility
///
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.error('Error message', error, stackTrace);
/// AppLogger.api('GET', '/users', response);
/// ```
class AppLogger {
  AppLogger._();

  /// Enable/disable all logging (single toggle)
  static bool _isEnabled = true;

  /// Enable/disable specific log types
  static bool _debugEnabled = true;
  static bool _infoEnabled = true;
  static bool _warningEnabled = true;
  static bool _errorEnabled = true;
  static bool _apiEnabled = true;

  /// Logger instance
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.trace : Level.off,
  );

  /// Simple logger for production
  static final Logger _simpleLogger = Logger(
    printer: SimplePrinter(printTime: true),
    level: Level.warning,
  );

  // ==================== CONFIGURATION ====================

  /// Enable all logging
  static void enable() {
    _isEnabled = true;
  }

  /// Disable all logging
  static void disable() {
    _isEnabled = false;
  }

  /// Configure logging options
  static void configure({
    bool? enabled,
    bool? debugEnabled,
    bool? infoEnabled,
    bool? warningEnabled,
    bool? errorEnabled,
    bool? apiEnabled,
  }) {
    if (enabled != null) _isEnabled = enabled;
    if (debugEnabled != null) _debugEnabled = debugEnabled;
    if (infoEnabled != null) _infoEnabled = infoEnabled;
    if (warningEnabled != null) _warningEnabled = warningEnabled;
    if (errorEnabled != null) _errorEnabled = errorEnabled;
    if (apiEnabled != null) _apiEnabled = apiEnabled;
  }

  // ==================== DEBUG LOGS ====================

  /// Log debug message
  static void debug(dynamic message, [dynamic data]) {
    if (!_isEnabled || !_debugEnabled || !kDebugMode) return;
    _logger.d('$message${data != null ? '\n$data' : ''}');
  }

  /// Log debug with tag
  static void debugTag(String tag, dynamic message, [dynamic data]) {
    if (!_isEnabled || !_debugEnabled || !kDebugMode) return;
    _logger.d('[$tag] $message${data != null ? '\n$data' : ''}');
  }

  // ==================== INFO LOGS ====================

  /// Log info message
  static void info(dynamic message, [dynamic data]) {
    if (!_isEnabled || !_infoEnabled) return;
    if (kDebugMode) {
      _logger.i('$message${data != null ? '\n$data' : ''}');
    }
  }

  /// Log info with tag
  static void infoTag(String tag, dynamic message, [dynamic data]) {
    if (!_isEnabled || !_infoEnabled) return;
    if (kDebugMode) {
      _logger.i('[$tag] $message${data != null ? '\n$data' : ''}');
    }
  }

  // ==================== WARNING LOGS ====================

  /// Log warning message
  static void warning(dynamic message, [dynamic data]) {
    if (!_isEnabled || !_warningEnabled) return;
    if (kDebugMode) {
      _logger.w('$message${data != null ? '\n$data' : ''}');
    } else {
      _simpleLogger.w('$message');
    }
  }

  /// Log warning with tag
  static void warningTag(String tag, dynamic message, [dynamic data]) {
    if (!_isEnabled || !_warningEnabled) return;
    if (kDebugMode) {
      _logger.w('[$tag] $message${data != null ? '\n$data' : ''}');
    }
  }

  // ==================== ERROR LOGS ====================

  /// Log error message
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled || !_errorEnabled) return;
    if (kDebugMode) {
      _logger.e('$message', error: error, stackTrace: stackTrace);
    } else {
      _simpleLogger.e('$message', error: error, stackTrace: stackTrace);
    }
  }

  /// Log error with tag
  static void errorTag(
    String tag,
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_isEnabled || !_errorEnabled) return;
    if (kDebugMode) {
      _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
    }
  }

  // ==================== API LOGS ====================

  /// Log API request
  static void apiRequest(String method, String url, [dynamic body]) {
    if (!_isEnabled || !_apiEnabled || !kDebugMode) return;
    _logger.i(
      '🌐 API REQUEST\n'
      '├── Method: $method\n'
      '├── URL: $url\n'
      '└── Body: ${_truncate(body?.toString() ?? 'null')}',
    );
  }

  /// Log API response
  static void apiResponse(
    String method,
    String url,
    int statusCode,
    dynamic response,
  ) {
    if (!_isEnabled || !_apiEnabled || !kDebugMode) return;
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    _logger.i(
      '$emoji API RESPONSE [$statusCode]\n'
      '├── Method: $method\n'
      '├── URL: $url\n'
      '└── Response: ${_truncate(response?.toString() ?? 'null')}',
    );
  }

  /// Log API error
  static void apiError(String method, String url, dynamic error) {
    if (!_isEnabled || !_apiEnabled) return;
    _logger.e(
      '❌ API ERROR\n'
      '├── Method: $method\n'
      '├── URL: $url\n'
      '└── Error: $error',
    );
  }

  /// Combined API log
  static void api(
    String method,
    String url, {
    dynamic request,
    dynamic response,
    int? statusCode,
    dynamic error,
  }) {
    if (!_isEnabled || !_apiEnabled || !kDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('🌐 API CALL');
    buffer.writeln('├── $method $url');

    if (request != null) {
      buffer.writeln('├── Request: ${_truncate(request.toString())}');
    }

    if (statusCode != null) {
      buffer.writeln('├── Status: $statusCode');
    }

    if (response != null) {
      buffer.writeln('├── Response: ${_truncate(response.toString())}');
    }

    if (error != null) {
      buffer.writeln('└── Error: $error');
      _logger.e(buffer.toString());
    } else {
      buffer.writeln('└── Success');
      _logger.i(buffer.toString());
    }
  }

  // ==================== UTILITY ====================

  /// Truncate long strings
  static String _truncate(String text, {int maxLength = 500}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... [TRUNCATED]';
  }

  /// Log separator line
  static void separator() {
    if (!_isEnabled || !kDebugMode) return;
    debugPrint('─' * 80);
  }

  /// Log with custom level
  static void log(Level level, dynamic message) {
    if (!_isEnabled) return;
    switch (level) {
      case Level.trace:
      case Level.debug:
        debug(message);
        break;
      case Level.info:
        info(message);
        break;
      case Level.warning:
        warning(message);
        break;
      case Level.error:
      case Level.fatal:
        error(message);
        break;
      default:
        debug(message);
    }
  }
}
