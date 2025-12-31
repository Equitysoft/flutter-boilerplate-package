import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Network Configuration - Customize network behavior per project
class NetworkConfig {
  /// Offline message text
  final String offlineMessage;

  /// Online message text
  final String onlineMessage;

  /// Offline message background color
  final Color offlineColor;

  /// Online message background color
  final Color onlineColor;

  /// Snackbar position
  final SnackPosition snackPosition;

  /// Snackbar duration
  final Duration duration;

  /// Custom offline widget builder
  final Widget Function(BuildContext context)? offlineWidgetBuilder;

  /// Callback when connection changes
  final void Function(bool isConnected)? onConnectionChange;

  const NetworkConfig({
    this.offlineMessage = 'No internet connection. Please check your network.',
    this.onlineMessage = 'Back online!',
    this.offlineColor = const Color(0xFFD32F2F),
    this.onlineColor = const Color(0xFF388E3C),
    this.snackPosition = SnackPosition.TOP,
    this.duration = const Duration(seconds: 3),
    this.offlineWidgetBuilder,
    this.onConnectionChange,
  });

  static const NetworkConfig defaultConfig = NetworkConfig();
}

/// Network Helper - Check internet connectivity with dynamic configuration
///
/// Usage:
/// ```dart
/// // Configure globally in main()
/// NetworkHelper.configure(NetworkConfig(
///   offlineMessage: 'You are offline',
///   onConnectionChange: (isConnected) => print('Connected: $isConnected'),
/// ));
///
/// // Check before API call
/// if (await NetworkHelper.isConnected) {
///   // Make API call
/// }
///
/// // Start listening to connectivity changes
/// NetworkHelper.startListening();
/// ```
class NetworkHelper {
  NetworkHelper._();

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static NetworkConfig _config = NetworkConfig.defaultConfig;
  static bool _wasConnected = true;

  // ==================== CONFIGURATION ====================

  /// Configure network helper globally
  static void configure(NetworkConfig config) {
    _config = config;
  }

  /// Get current configuration
  static NetworkConfig get config => _config;

  /// Reset to default configuration
  static void resetConfig() {
    _config = NetworkConfig.defaultConfig;
  }

  // ==================== CONNECTION CHECK ====================

  /// Check if internet is available
  static Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Check if connected to WiFi
  static Future<bool> get isWiFi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Check if connected to Mobile Data
  static Future<bool> get isMobileData async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }

  /// Get current connection type
  static Future<ConnectionType> get connectionType async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.wifi)) return ConnectionType.wifi;
    if (result.contains(ConnectivityResult.mobile))
      return ConnectionType.mobile;
    if (result.contains(ConnectivityResult.ethernet))
      return ConnectionType.ethernet;
    return ConnectionType.none;
  }

  /// Get connection type as string
  static Future<String> get connectionTypeString async {
    final type = await connectionType;
    switch (type) {
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.none:
        return 'No Connection';
    }
  }

  // ==================== CONNECTIVITY LISTENER ====================

  /// Stream of connectivity changes
  static Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Start listening to connectivity changes (global)
  static void startListening({
    bool showSnackbar = true,
    void Function(bool isConnected)? onConnectionChange,
  }) {
    stopListening(); // Stop any existing subscription

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = !results.contains(ConnectivityResult.none);

      // Only trigger on actual change
      if (isConnected != _wasConnected) {
        _wasConnected = isConnected;

        // Show snackbar
        if (showSnackbar) {
          if (isConnected) {
            showOnlineMessage();
          } else {
            showOfflineMessage();
          }
        }

        // Callback
        onConnectionChange?.call(isConnected);
        _config.onConnectionChange?.call(isConnected);
      }
    });
  }

  /// Stop listening to connectivity changes
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Check if listening
  static bool get isListening => _subscription != null;

  // ==================== MESSAGES ====================

  /// Show offline snackbar message
  static void showOfflineMessage({String? message}) {
    Get.showSnackbar(
      GetSnackBar(
        message: message ?? _config.offlineMessage,
        duration: _config.duration,
        backgroundColor: _config.offlineColor,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
        snackPosition: _config.snackPosition,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ),
    );
  }

  /// Show online snackbar message
  static void showOnlineMessage({String? message}) {
    Get.showSnackbar(
      GetSnackBar(
        message: message ?? _config.onlineMessage,
        duration: const Duration(seconds: 2),
        backgroundColor: _config.onlineColor,
        icon: const Icon(Icons.wifi, color: Colors.white),
        snackPosition: _config.snackPosition,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ),
    );
  }

  // ==================== EXECUTE WITH CHECK ====================

  /// Execute callback only if connected, otherwise show offline message
  static Future<T?> executeIfConnected<T>(
    Future<T> Function() callback, {
    String? offlineMessage,
    VoidCallback? onOffline,
  }) async {
    if (await isConnected) {
      return await callback();
    } else {
      showOfflineMessage(message: offlineMessage);
      onOffline?.call();
      return null;
    }
  }

  /// Execute with retry on connection
  static Future<T?> executeWithRetry<T>(
    Future<T> Function() callback, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      if (await isConnected) {
        try {
          return await callback();
        } catch (_) {
          if (i < maxRetries - 1) {
            await Future.delayed(retryDelay);
          }
        }
      } else {
        await Future.delayed(retryDelay);
      }
    }
    showOfflineMessage();
    return null;
  }
}

/// Connection type enum
enum ConnectionType { wifi, mobile, ethernet, none }

// ==================== SCREEN-WISE NETWORK HANDLING ====================

/// Network Mixin - Add to any GetX Controller for screen-wise network handling
///
/// Usage:
/// ```dart
/// class HomeController extends GetxController with NetworkMixin {
///   @override
///   void onInit() {
///     super.onInit();
///     startNetworkListener();
///   }
///
///   @override
///   void onConnected() {
///     // Refresh data when back online
///     fetchData();
///   }
///
///   @override
///   void onDisconnected() {
///     // Show offline UI
///   }
/// }
/// ```
mixin NetworkMixin on GetxController {
  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;

  /// Observable connection status
  final RxBool isConnected = true.obs;

  /// Observable connection type
  final Rx<ConnectionType> connectionType = ConnectionType.none.obs;

  /// Start listening to network changes for this screen
  void startNetworkListener({bool showSnackbar = false}) {
    _checkInitialConnection();

    _networkSubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final connected = !results.contains(ConnectivityResult.none);

      // Update connection type
      if (results.contains(ConnectivityResult.wifi)) {
        connectionType.value = ConnectionType.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        connectionType.value = ConnectionType.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        connectionType.value = ConnectionType.ethernet;
      } else {
        connectionType.value = ConnectionType.none;
      }

      // Only trigger on actual change
      if (connected != isConnected.value) {
        isConnected.value = connected;

        if (showSnackbar) {
          if (connected) {
            NetworkHelper.showOnlineMessage();
          } else {
            NetworkHelper.showOfflineMessage();
          }
        }

        // Call callbacks
        if (connected) {
          onConnected();
        } else {
          onDisconnected();
        }
      }
    });
  }

  /// Check initial connection
  Future<void> _checkInitialConnection() async {
    isConnected.value = await NetworkHelper.isConnected;
    connectionType.value = await NetworkHelper.connectionType;
  }

  /// Stop listening to network changes
  void stopNetworkListener() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }

  /// Override to handle when connection is restored
  void onConnected() {}

  /// Override to handle when connection is lost
  void onDisconnected() {}

  @override
  void onClose() {
    stopNetworkListener();
    super.onClose();
  }
}

/// Network Aware Widget - Show offline UI automatically
///
/// Usage:
/// ```dart
/// NetworkAwareWidget(
///   onlineChild: MyOnlineContent(),
///   offlineChild: OfflinePlaceholder(),
///   onRetry: () => controller.fetchData(),
/// )
/// ```
class NetworkAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget? offlineChild;
  final VoidCallback? onRetry;
  final String? offlineMessage;

  const NetworkAwareWidget({
    super.key,
    required this.onlineChild,
    this.offlineChild,
    this.onRetry,
    this.offlineMessage,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline =
            snapshot.hasData &&
            !snapshot.data!.contains(ConnectivityResult.none);

        if (isOnline) {
          return onlineChild;
        }

        return offlineChild ?? _buildDefaultOfflineWidget();
      },
    );
  }

  Widget _buildDefaultOfflineWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              offlineMessage ?? 'No internet connection',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  if (await NetworkHelper.isConnected) {
                    onRetry?.call();
                  } else {
                    NetworkHelper.showOfflineMessage();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
