/// API Endpoints configuration
/// Centralized place for all API URLs used in the application
class ApiEndpoints {
  ApiEndpoints._();

  // ==================== Base URLs ====================
  /// Base URL for development
  static const String devBaseUrl = 'https://dev-api.example.com/api/v1';

  /// Base URL for staging
  static const String stagingBaseUrl = 'https://staging-api.example.com/api/v1';

  /// Base URL for production
  static const String prodBaseUrl = 'https://api.example.com/api/v1';

  /// Current base URL (change based on environment)
  static const String baseUrl = devBaseUrl;

  // ==================== Timeouts ====================
  /// Connection timeout in milliseconds
  static const int connectionTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Send timeout in milliseconds
  static const int sendTimeout = 30000;

  // ==================== Auth Endpoints ====================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String changePassword = '/auth/change-password';
  static const String socialLogin = '/auth/social-login';

  // ==================== User Endpoints ====================
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String uploadAvatar = '/user/avatar';
  static const String deleteAccount = '/user/delete';

  // ==================== Device & FCM ====================
  static const String registerDevice = '/device/register';
  static const String updateFcmToken = '/device/fcm-token';

  // ==================== Common ====================
  static const String uploadFile = '/upload';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // ==================== Helper Methods ====================
  /// Build full URL from endpoint
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Build URL with path parameters
  /// Example: buildUrlWithParams('/user/{id}', {'id': '123'}) => '/user/123'
  static String buildUrlWithParams(
    String endpoint,
    Map<String, String> params,
  ) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return '$baseUrl$url';
  }
}
