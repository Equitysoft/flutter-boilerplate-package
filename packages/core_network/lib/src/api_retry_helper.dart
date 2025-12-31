import 'dart:async';
import 'package:flutter/foundation.dart';

/// API Exception base class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    this.message = 'An error occurred',
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Network Exception - No internet connection
class NetworkException extends ApiException {
  NetworkException({super.message = 'No internet connection'});
}

/// Server Exception - 5xx errors
class ServerException extends ApiException {
  ServerException({super.message = 'Server error', super.statusCode});
}

/// Client Exception - 4xx errors
class ClientException extends ApiException {
  ClientException({super.message = 'Client error', super.statusCode});
}

/// Unauthorized Exception - 401 error
class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized'})
    : super(statusCode: 401);
}

/// Forbidden Exception - 403 error
class ForbiddenException extends ApiException {
  ForbiddenException({super.message = 'Forbidden'}) : super(statusCode: 403);
}

/// Validation Exception - 422 error
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  ValidationException({super.message = 'Validation failed', this.errors})
    : super(statusCode: 422);
}

/// API Retry Helper - Safe retry logic for network failures
///
/// Usage:
/// ```dart
/// final result = await ApiRetryHelper.execute(
///   () => apiClient.get('/users'),
///   maxRetries: 3,
/// );
/// ```
class ApiRetryHelper {
  ApiRetryHelper._();

  /// Default max retries
  static const int defaultMaxRetries = 2;

  /// Default retry delay in milliseconds
  static const int defaultRetryDelay = 1000;

  /// Execute API call with retry logic
  ///
  /// Retries on:
  /// - Network failure
  /// - Timeout
  /// - Temporary server errors (5xx)
  static Future<T> execute<T>(
    Future<T> Function() apiCall, {
    int maxRetries = defaultMaxRetries,
    int retryDelayMs = defaultRetryDelay,
    bool Function(dynamic error)? shouldRetry,
    void Function(int attempt, dynamic error)? onRetry,
    void Function(dynamic error)? onFinalError,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt <= maxRetries) {
      try {
        return await apiCall();
      } catch (error) {
        lastError = error;
        attempt++;

        // Check if we should retry
        final canRetry = shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (!canRetry || attempt > maxRetries) {
          break;
        }

        // Log retry attempt
        debugPrint('API Retry: Attempt $attempt of $maxRetries');
        onRetry?.call(attempt, error);

        // Wait before retrying with exponential backoff
        await Future.delayed(Duration(milliseconds: retryDelayMs * attempt));
      }
    }

    // All retries failed
    onFinalError?.call(lastError);
    throw lastError;
  }

  /// Execute with timeout
  static Future<T> executeWithTimeout<T>(
    Future<T> Function() apiCall, {
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = defaultMaxRetries,
  }) async {
    return execute<T>(() => apiCall().timeout(timeout), maxRetries: maxRetries);
  }

  /// Default retry condition
  static bool _defaultShouldRetry(dynamic error) {
    // Retry on network errors
    if (error is NetworkException) return true;

    // Retry on timeout
    if (error is TimeoutException) return true;

    // Retry on server errors (5xx)
    if (error is ServerException) return true;

    // Don't retry on client errors (4xx)
    if (error is ClientException) return false;
    if (error is UnauthorizedException) return false;
    if (error is ForbiddenException) return false;
    if (error is ValidationException) return false;

    // Retry on unknown errors (might be transient)
    return true;
  }

  /// Execute multiple API calls with retry
  static Future<List<T>> executeAll<T>(
    List<Future<T> Function()> apiCalls, {
    int maxRetries = defaultMaxRetries,
    bool stopOnFirstError = false,
  }) async {
    final results = <T>[];
    final errors = <dynamic>[];

    for (final apiCall in apiCalls) {
      try {
        final result = await execute(apiCall, maxRetries: maxRetries);
        results.add(result);
      } catch (error) {
        if (stopOnFirstError) {
          rethrow;
        }
        errors.add(error);
      }
    }

    if (errors.isNotEmpty && results.isEmpty) {
      throw errors.first;
    }

    return results;
  }

  /// Execute with callback on success/failure
  static Future<void> executeWithCallbacks<T>(
    Future<T> Function() apiCall, {
    required void Function(T result) onSuccess,
    required void Function(dynamic error) onError,
    int maxRetries = defaultMaxRetries,
  }) async {
    try {
      final result = await execute(apiCall, maxRetries: maxRetries);
      onSuccess(result);
    } catch (error) {
      onError(error);
    }
  }
}

/// Retry configuration
class RetryConfig {
  final int maxRetries;
  final int retryDelayMs;
  final bool exponentialBackoff;
  final List<Type> retryOnErrors;

  const RetryConfig({
    this.maxRetries = 2,
    this.retryDelayMs = 1000,
    this.exponentialBackoff = true,
    this.retryOnErrors = const [
      NetworkException,
      TimeoutException,
      ServerException,
    ],
  });

  static const RetryConfig defaultConfig = RetryConfig();

  static const RetryConfig aggressive = RetryConfig(
    maxRetries: 5,
    retryDelayMs: 500,
  );

  static const RetryConfig noRetry = RetryConfig(maxRetries: 0);
}
