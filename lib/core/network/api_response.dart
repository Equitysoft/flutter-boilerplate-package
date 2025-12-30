import 'dart:convert';

/// Standard API Response wrapper
/// Used for consistent response handling across all API calls
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.meta,
  });

  /// Create success response
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      meta: meta,
    );
  }

  /// Create error response
  factory ApiResponse.error({String? message, int? statusCode, T? data}) {
    return ApiResponse(
      success: false,
      message: message ?? 'Something went wrong',
      statusCode: statusCode,
      data: data,
    );
  }

  /// Parse API response from JSON
  ///
  /// [json] - Raw response data
  /// [fromJson] - Function to convert data to model
  /// [dataKey] - Key to extract data from response (default: 'data')
  factory ApiResponse.fromJson(
    dynamic json, {
    T Function(dynamic)? fromJson,
    String dataKey = 'data',
  }) {
    if (json == null) {
      return ApiResponse.error(message: 'Empty response');
    }

    Map<String, dynamic> response;
    if (json is String) {
      response = jsonDecode(json);
    } else if (json is Map<String, dynamic>) {
      response = json;
    } else {
      return ApiResponse.error(message: 'Invalid response format');
    }

    final success =
        response['success'] as bool? ??
        response['status'] as bool? ??
        (response['error'] == null);

    final message =
        response['message'] as String? ?? response['msg'] as String?;

    final rawData = response[dataKey] ?? response['result'];

    T? data;
    if (fromJson != null && rawData != null) {
      data = fromJson(rawData);
    } else if (rawData is T) {
      data = rawData;
    }

    return ApiResponse(
      success: success,
      message: message,
      data: data,
      meta: response['meta'] as Map<String, dynamic>?,
    );
  }

  /// Parse list response
  factory ApiResponse.fromJsonList(
    dynamic json, {
    required T Function(List<dynamic>) fromJsonList,
    String dataKey = 'data',
  }) {
    if (json == null) {
      return ApiResponse.error(message: 'Empty response');
    }

    Map<String, dynamic> response;
    if (json is String) {
      response = jsonDecode(json);
    } else if (json is Map<String, dynamic>) {
      response = json;
    } else {
      return ApiResponse.error(message: 'Invalid response format');
    }

    final success =
        response['success'] as bool? ??
        response['status'] as bool? ??
        (response['error'] == null);

    final message = response['message'] as String?;
    final rawData = response[dataKey] ?? response['result'];

    T? data;
    if (rawData is List) {
      data = fromJsonList(rawData);
    }

    return ApiResponse(
      success: success,
      message: message,
      data: data,
      meta: response['meta'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      lastPage: json['last_page'] ?? json['lastPage'] ?? 1,
      perPage: json['per_page'] ?? json['perPage'] ?? 10,
      total: json['total'] ?? 0,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
