import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// App Restart Helper - Soft reset and app restart utilities
///
/// Usage:
/// ```dart
/// // Full app restart
/// await AppRestartHelper.restart();
///
/// // Clear and logout
/// await AppRestartHelper.logout();
///
/// // Clear and change environment
/// await AppRestartHelper.switchEnvironment();
/// ```
class AppRestartHelper {
  AppRestartHelper._();

  /// Callback to be executed before restart
  static Future<void> Function()? onBeforeRestart;

  /// Callback to be executed on logout
  static Future<void> Function()? onLogout;

  // ==================== RESTART METHODS ====================

  /// Soft restart - navigate to initial route and clear navigation stack
  static Future<void> softRestart({String initialRoute = '/'}) async {
    // Execute before restart callback
    await onBeforeRestart?.call();

    // Clear all GetX controllers
    Get.deleteAll(force: true);

    // Navigate to initial route and clear stack
    Get.offAllNamed(initialRoute);
  }

  /// Restart with widget rebuild
  static Future<void> restart({String initialRoute = '/'}) async {
    await onBeforeRestart?.call();
    Get.deleteAll(force: true);
    Get.offAllNamed(initialRoute);
  }

  /// Logout - clear user data and restart
  static Future<void> logout({
    String loginRoute = '/login',
    Future<void> Function()? clearUserData,
  }) async {
    // Show loading
    _showLoading('Logging out...');

    try {
      // Execute logout callback
      await onLogout?.call();

      // Clear user data
      await clearUserData?.call();

      // Clear all controllers
      Get.deleteAll(force: true);

      // Hide loading
      _hideLoading();

      // Navigate to login
      Get.offAllNamed(loginRoute);
    } catch (e) {
      _hideLoading();
      _showError('Logout failed. Please try again.');
    }
  }

  /// Switch environment - restart with new environment
  static Future<void> switchEnvironment({
    required Future<void> Function() configureEnvironment,
    String initialRoute = '/',
  }) async {
    _showLoading('Switching environment...');

    try {
      // Clear all data and controllers
      Get.deleteAll(force: true);

      // Configure new environment
      await configureEnvironment();

      _hideLoading();

      // Restart app
      Get.offAllNamed(initialRoute);
    } catch (e) {
      _hideLoading();
      _showError('Failed to switch environment.');
    }
  }

  /// Change language and restart
  static Future<void> changeLanguage({
    required Locale locale,
    String initialRoute = '/',
    Future<void> Function(Locale)? saveLanguage,
  }) async {
    // Save language preference
    await saveLanguage?.call(locale);

    // Update GetX locale
    Get.updateLocale(locale);

    // Soft restart
    await softRestart(initialRoute: initialRoute);
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all GetX controllers
  static void clearAllControllers() {
    Get.deleteAll(force: true);
  }

  /// Clear specific controller
  static void clearController<T>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }

  /// Reset app state without navigation
  static Future<void> resetState({Future<void> Function()? onReset}) async {
    await onReset?.call();
    Get.deleteAll(force: true);
  }

  /// Force close app (Android only)
  static void forceClose() {
    SystemNavigator.pop();
  }

  // ==================== PRIVATE METHODS ====================

  static void _showLoading(String message) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void _hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void _showError(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ),
    );
  }
}
