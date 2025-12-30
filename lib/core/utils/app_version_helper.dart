import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App Version Helper - Version checking and update dialogs
///
/// Usage:
/// ```dart
/// // Initialize at app start
/// await AppVersionHelper.init();
///
/// // Check for updates
/// await AppVersionHelper.checkForUpdate(
///   latestVersion: '2.0.0',
///   forceUpdate: false,
/// );
/// ```
class AppVersionHelper {
  AppVersionHelper._();

  static PackageInfo? _packageInfo;

  /// Initialize - call this at app start
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// Get package info
  static PackageInfo get packageInfo {
    if (_packageInfo == null) {
      throw Exception('AppVersionHelper not initialized. Call init() first.');
    }
    return _packageInfo!;
  }

  // ==================== VERSION INFO ====================

  /// Get app name
  static String get appName => packageInfo.appName;

  /// Get package name
  static String get packageName => packageInfo.packageName;

  /// Get version name (e.g., "1.0.0")
  static String get version => packageInfo.version;

  /// Get build number (e.g., "1")
  static String get buildNumber => packageInfo.buildNumber;

  /// Get full version string (e.g., "1.0.0+1")
  static String get fullVersion =>
      '${packageInfo.version}+${packageInfo.buildNumber}';

  /// Get version display string (e.g., "v1.0.0 (1)")
  static String get versionDisplay =>
      'v${packageInfo.version} (${packageInfo.buildNumber})';

  // ==================== VERSION COMPARISON ====================

  /// Compare versions
  /// Returns: -1 if current < other, 0 if equal, 1 if current > other
  static int compareVersions(String version1, String version2) {
    final v1Parts = version1
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final v2Parts = version2
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // Pad shorter version with zeros
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }

    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }

    return 0;
  }

  /// Check if current version is older than given version
  static bool isOlderThan(String otherVersion) {
    return compareVersions(version, otherVersion) < 0;
  }

  /// Check if current version is newer than given version
  static bool isNewerThan(String otherVersion) {
    return compareVersions(version, otherVersion) > 0;
  }

  /// Check if current version equals given version
  static bool isEqualTo(String otherVersion) {
    return compareVersions(version, otherVersion) == 0;
  }

  // ==================== UPDATE CHECK ====================

  /// Check for update and show dialog if needed
  static Future<UpdateStatus> checkForUpdate({
    required String latestVersion,
    bool forceUpdate = false,
    String? updateUrl,
    String? releaseNotes,
  }) async {
    if (isOlderThan(latestVersion)) {
      if (forceUpdate) {
        await _showForceUpdateDialog(
          latestVersion: latestVersion,
          updateUrl: updateUrl,
          releaseNotes: releaseNotes,
        );
        return UpdateStatus.forceUpdate;
      } else {
        final shouldUpdate = await _showOptionalUpdateDialog(
          latestVersion: latestVersion,
          updateUrl: updateUrl,
          releaseNotes: releaseNotes,
        );
        return shouldUpdate
            ? UpdateStatus.optionalUpdateAccepted
            : UpdateStatus.optionalUpdateSkipped;
      }
    }
    return UpdateStatus.upToDate;
  }

  /// Show force update dialog (cannot dismiss)
  static Future<void> _showForceUpdateDialog({
    required String latestVersion,
    String? updateUrl,
    String? releaseNotes,
  }) async {
    await Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version ($latestVersion) is available. '
                'You must update to continue using the app.',
              ),
              if (releaseNotes != null) ...[
                const SizedBox(height: 16),
                const Text(
                  "What's New:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(releaseNotes),
              ],
              const SizedBox(height: 8),
              Text(
                'Current version: $version',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // TODO: Open store URL
                // LaunchUrl.open(updateUrl ?? storeUrl);
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show optional update dialog
  static Future<bool> _showOptionalUpdateDialog({
    required String latestVersion,
    String? updateUrl,
    String? releaseNotes,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version ($latestVersion) is available. '
              'Would you like to update?',
            ),
            if (releaseNotes != null) ...[
              const SizedBox(height: 16),
              const Text(
                "What's New:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(releaseNotes),
            ],
            const SizedBox(height: 8),
            Text(
              'Current version: $version',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
              // TODO: Open store URL
              // LaunchUrl.open(updateUrl ?? storeUrl);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Update status enum
enum UpdateStatus {
  upToDate,
  forceUpdate,
  optionalUpdateAccepted,
  optionalUpdateSkipped,
}
