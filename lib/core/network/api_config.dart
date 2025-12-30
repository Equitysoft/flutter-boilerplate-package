/// API Configuration - Dynamic configuration passed at app initialization
/// This allows each project to define its own API URLs and settings
class ApiConfig {
  static ApiConfig? _instance;

  /// Base URL for API calls
  final String baseUrl;

  /// Connection timeout in milliseconds
  final int connectionTimeout;

  /// Receive timeout in milliseconds
  final int receiveTimeout;

  /// Send timeout in milliseconds
  final int sendTimeout;

  /// Enable logging in debug mode
  final bool enableLogging;

  /// Custom headers to add to all requests
  final Map<String, String>? defaultHeaders;

  /// API version prefix (e.g., '/api/v1')
  final String? apiVersion;

  ApiConfig._({
    required this.baseUrl,
    this.connectionTimeout = 30000,
    this.receiveTimeout = 30000,
    this.sendTimeout = 30000,
    this.enableLogging = true,
    this.defaultHeaders,
    this.apiVersion,
  });

  /// Initialize API configuration - Call this before using ApiClient
  ///
  /// Example:
  /// ```dart
  /// ApiConfig.init(
  ///   baseUrl: 'https://api.example.com',
  ///   apiVersion: '/api/v1',
  /// );
  /// ```
  static void init({
    required String baseUrl,
    int connectionTimeout = 30000,
    int receiveTimeout = 30000,
    int sendTimeout = 30000,
    bool enableLogging = true,
    Map<String, String>? defaultHeaders,
    String? apiVersion,
  }) {
    _instance = ApiConfig._(
      baseUrl: baseUrl,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      enableLogging: enableLogging,
      defaultHeaders: defaultHeaders,
      apiVersion: apiVersion,
    );
  }

  /// Get current configuration instance
  static ApiConfig get instance {
    if (_instance == null) {
      throw Exception(
        'ApiConfig not initialized. Call ApiConfig.init() in main() before using ApiClient.',
      );
    }
    return _instance!;
  }

  /// Check if configuration is initialized
  static bool get isInitialized => _instance != null;

  /// Get full base URL including API version
  String get fullBaseUrl {
    if (apiVersion != null && apiVersion!.isNotEmpty) {
      return '$baseUrl$apiVersion';
    }
    return baseUrl;
  }

  /// Reset configuration (useful for testing)
  static void reset() {
    _instance = null;
  }
}

/// Environment configuration helper
enum Environment { development, staging, production }

/// Environment-based API configuration
class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  /// Set current environment
  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  /// Get current environment
  static Environment get currentEnvironment => _currentEnvironment;

  /// Check if running in development
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// Check if running in staging
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// Check if running in production
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Initialize API config based on environment
  ///
  /// Example:
  /// ```dart
  /// EnvironmentConfig.initApiConfig(
  ///   environment: Environment.development,
  ///   devBaseUrl: 'https://dev-api.example.com',
  ///   stagingBaseUrl: 'https://staging-api.example.com',
  ///   prodBaseUrl: 'https://api.example.com',
  ///   apiVersion: '/api/v1',
  /// );
  /// ```
  static void initApiConfig({
    required Environment environment,
    required String devBaseUrl,
    required String stagingBaseUrl,
    required String prodBaseUrl,
    String? apiVersion,
    int connectionTimeout = 30000,
    int receiveTimeout = 30000,
    int sendTimeout = 30000,
    Map<String, String>? defaultHeaders,
  }) {
    _currentEnvironment = environment;

    String baseUrl;
    bool enableLogging;

    switch (environment) {
      case Environment.development:
        baseUrl = devBaseUrl;
        enableLogging = true;
        break;
      case Environment.staging:
        baseUrl = stagingBaseUrl;
        enableLogging = true;
        break;
      case Environment.production:
        baseUrl = prodBaseUrl;
        enableLogging = false;
        break;
    }

    ApiConfig.init(
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      enableLogging: enableLogging,
      defaultHeaders: defaultHeaders,
    );
  }
}
