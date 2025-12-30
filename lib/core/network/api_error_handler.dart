import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:app_boilerplate/core/network/api_exceptions.dart';

/// Error handler utility for processing API errors
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Handle DioException and convert to ApiException
  static ApiException handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return const NetworkException();
    } else {
      debugPrint('Unknown error: $error');
      return UnknownException(message: error.toString());
    }
  }

  /// Handle DioException
  static ApiException _handleDioError(DioException error) {
    debugPrint('DioException: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'SSL Certificate error. Please check your connection.',
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return UnknownException(
          message: error.message ?? 'Unknown error occurred',
        );
    }
  }

  /// Handle HTTP response errors
  static ApiException _handleResponseError(Response? response) {
    if (response == null) {
      return const UnknownException();
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract error message from response
    String message =
        _extractErrorMessage(data) ?? _getDefaultMessage(statusCode);

    debugPrint('Response error [$statusCode]: $message');

    switch (statusCode) {
      case HttpStatus.badRequest: // 400
        return BadRequestException(message: message, data: data);

      case HttpStatus.unauthorized: // 401
        return UnauthorizedException(message: message, data: data);

      case HttpStatus.forbidden: // 403
        return ForbiddenException(message: message, data: data);

      case HttpStatus.notFound: // 404
        return NotFoundException(message: message, data: data);

      case HttpStatus.unprocessableEntity: // 422
        return ValidationException(
          message: message,
          data: data,
          errors: _extractValidationErrors(data),
        );

      case HttpStatus.tooManyRequests: // 429
        return TooManyRequestsException(
          message: message,
          data: data,
          retryAfter: _extractRetryAfter(response),
        );

      case HttpStatus.internalServerError: // 500
      case HttpStatus.badGateway: // 502
      case HttpStatus.gatewayTimeout: // 504
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );

      case HttpStatus.serviceUnavailable: // 503
        return MaintenanceException(message: message, data: data);

      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
            data: data,
          );
        } else if (statusCode >= 400) {
          return ClientException(
            message: message,
            statusCode: statusCode,
            data: data,
          );
        }
        return UnknownException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Try common error message fields
      return data['message'] as String? ??
          data['error'] as String? ??
          data['error_message'] as String? ??
          data['msg'] as String? ??
          (data['errors'] is String ? data['errors'] as String : null);
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  /// Extract validation errors from response data
  static Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data == null) return null;

    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e.toString()).toList(),
          );
        }
        return MapEntry(key.toString(), [value.toString()]);
      });
    }

    return null;
  }

  /// Extract retry-after header for rate limiting
  static int? _extractRetryAfter(Response response) {
    final retryAfter = response.headers.value('retry-after');
    if (retryAfter != null) {
      return int.tryParse(retryAfter);
    }
    return null;
  }

  /// Get default error message for status code
  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Server is under maintenance. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
