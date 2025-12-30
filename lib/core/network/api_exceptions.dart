import 'dart:io';

/// Base class for API exceptions
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Exception for network/connection errors
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
    super.data,
  });
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error. Please try again later.',
    super.statusCode,
    super.data,
  });
}

/// Exception for client errors (4xx)
class ClientException extends ApiException {
  const ClientException({
    super.message = 'Request failed. Please try again.',
    super.statusCode,
    super.data,
  });
}

/// Exception for unauthorized access (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please login again.',
    super.statusCode = HttpStatus.unauthorized,
    super.data,
  });
}

/// Exception for forbidden access (403)
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied. You don\'t have permission.',
    super.statusCode = HttpStatus.forbidden,
    super.data,
  });
}

/// Exception for not found (404)
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found.',
    super.statusCode = HttpStatus.notFound,
    super.data,
  });
}

/// Exception for validation errors (422)
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'Validation failed. Please check your input.',
    super.statusCode = HttpStatus.unprocessableEntity,
    super.data,
    this.errors,
  });

  /// Get first error message for a field
  String? getFieldError(String field) {
    return errors?[field]?.first;
  }

  /// Get all error messages as a single string
  String getAllErrors() {
    if (errors == null || errors!.isEmpty) return message;
    return errors!.values.expand((e) => e).join('\n');
  }
}

/// Exception for timeout errors
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again.',
    super.statusCode,
    super.data,
  });
}

/// Exception for request cancellation
class CancelledException extends ApiException {
  const CancelledException({
    super.message = 'Request was cancelled.',
    super.statusCode,
    super.data,
  });
}

/// Exception for bad request (400)
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'Bad request. Please check your input.',
    super.statusCode = HttpStatus.badRequest,
    super.data,
  });
}

/// Exception for too many requests (429)
class TooManyRequestsException extends ApiException {
  final int? retryAfter;

  const TooManyRequestsException({
    super.message = 'Too many requests. Please try again later.',
    super.statusCode = HttpStatus.tooManyRequests,
    super.data,
    this.retryAfter,
  });
}

/// Exception for maintenance mode (503)
class MaintenanceException extends ApiException {
  const MaintenanceException({
    super.message = 'Server is under maintenance. Please try again later.',
    super.statusCode = HttpStatus.serviceUnavailable,
    super.data,
  });
}

/// Generic/Unknown exception
class UnknownException extends ApiException {
  const UnknownException({
    super.message = 'Something went wrong. Please try again.',
    super.statusCode,
    super.data,
  });
}
