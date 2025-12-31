import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Helper - Handle app permissions with version-specific support
///
/// Supports:
/// - Android 13+ (API 33+): Granular media permissions, POST_NOTIFICATIONS
/// - Android 10-12 (API 29-32): Scoped storage
/// - Android 9 and below: Legacy storage
///
/// Usage:
/// ```dart
/// if (await PermissionHelper.requestCamera()) {
///   // Camera granted
/// }
///
/// await PermissionHelper.requestMultiple([
///   AppPermission.camera,
///   AppPermission.storage,
/// ]);
/// ```
enum AppPermission {
  camera,
  storage,
  photos,
  videos,
  audio,
  microphone,
  notification,
  location,
  locationAlways,
  contacts,
  calendar,
  phone,
}

class PermissionHelper {
  PermissionHelper._();

  /// Cached Android SDK version
  static int? _cachedAndroidVersion;

  // ==================== SINGLE PERMISSION ====================

  /// Request camera permission
  static Future<bool> requestCamera() async {
    return await _requestPermission(Permission.camera, 'Camera');
  }

  /// Request storage permission (handles all Android versions)
  static Future<bool> requestStorage() async {
    if (Platform.isAndroid) {
      final sdkVersion = await getAndroidVersion();

      if (sdkVersion >= 33) {
        // Android 13+: Request granular media permissions
        final photosGranted = await _requestPermission(
          Permission.photos,
          'Photos',
        );
        final videosGranted = await _requestPermission(
          Permission.videos,
          'Videos',
        );
        return photosGranted && videosGranted;
      } else if (sdkVersion >= 30) {
        // Android 11-12: Use manage external storage or photos
        return await _requestPermission(Permission.photos, 'Photos');
      } else {
        // Android 10 and below: Legacy storage permission
        return await _requestPermission(Permission.storage, 'Storage');
      }
    }
    // iOS: Use photos permission
    return await _requestPermission(Permission.photos, 'Photos');
  }

  /// Request photos permission only
  static Future<bool> requestPhotos() async {
    return await _requestPermission(Permission.photos, 'Photos');
  }

  /// Request videos permission (Android 13+ only)
  static Future<bool> requestVideos() async {
    if (Platform.isAndroid) {
      final sdkVersion = await getAndroidVersion();
      if (sdkVersion >= 33) {
        return await _requestPermission(Permission.videos, 'Videos');
      }
      // For older versions, use storage
      return await requestStorage();
    }
    return await _requestPermission(Permission.photos, 'Photos');
  }

  /// Request audio files permission (Android 13+ only)
  static Future<bool> requestAudio() async {
    if (Platform.isAndroid) {
      final sdkVersion = await getAndroidVersion();
      if (sdkVersion >= 33) {
        return await _requestPermission(Permission.audio, 'Audio');
      }
      // For older versions, use storage
      return await requestStorage();
    }
    return await _requestPermission(Permission.mediaLibrary, 'Media');
  }

  /// Request microphone permission
  static Future<bool> requestMicrophone() async {
    return await _requestPermission(Permission.microphone, 'Microphone');
  }

  /// Request notification permission (handles Android 13+ requirement)
  static Future<bool> requestNotification() async {
    if (Platform.isAndroid) {
      final sdkVersion = await getAndroidVersion();
      if (sdkVersion >= 33) {
        // Android 13+ requires explicit notification permission
        return await _requestPermission(
          Permission.notification,
          'Notification',
        );
      }
      // Android 12 and below: notifications are allowed by default
      return true;
    }
    // iOS: Request notification permission
    return await _requestPermission(Permission.notification, 'Notification');
  }

  /// Request location permission
  static Future<bool> requestLocation() async {
    return await _requestPermission(Permission.location, 'Location');
  }

  /// Request location always permission
  static Future<bool> requestLocationAlways() async {
    // Must request location permission first
    final locationGranted = await requestLocation();
    if (!locationGranted) return false;

    return await _requestPermission(
      Permission.locationAlways,
      'Background Location',
    );
  }

  /// Request contacts permission
  static Future<bool> requestContacts() async {
    return await _requestPermission(Permission.contacts, 'Contacts');
  }

  /// Request calendar permission
  static Future<bool> requestCalendar() async {
    return await _requestPermission(Permission.calendarFullAccess, 'Calendar');
  }

  /// Request phone permission
  static Future<bool> requestPhone() async {
    return await _requestPermission(Permission.phone, 'Phone');
  }

  // ==================== MULTIPLE PERMISSIONS ====================

  /// Request multiple permissions
  static Future<Map<AppPermission, bool>> requestMultiple(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, bool>{};

    for (final permission in permissions) {
      results[permission] = await _requestByType(permission);
    }

    return results;
  }

  /// Check if all permissions are granted
  static Future<bool> checkAll(List<AppPermission> permissions) async {
    for (final permission in permissions) {
      final p = await _getPermission(permission);
      if (!await p.isGranted) {
        return false;
      }
    }
    return true;
  }

  // ==================== CHECK STATUS ====================

  /// Check camera permission status
  static Future<bool> get isCameraGranted async {
    return await Permission.camera.isGranted;
  }

  /// Check storage permission status (version aware)
  static Future<bool> get isStorageGranted async {
    if (Platform.isAndroid) {
      final sdkVersion = await getAndroidVersion();
      if (sdkVersion >= 33) {
        return await Permission.photos.isGranted &&
            await Permission.videos.isGranted;
      } else if (sdkVersion >= 30) {
        return await Permission.photos.isGranted;
      }
      return await Permission.storage.isGranted;
    }
    return await Permission.photos.isGranted;
  }

  /// Check microphone permission status
  static Future<bool> get isMicrophoneGranted async {
    return await Permission.microphone.isGranted;
  }

  /// Check notification permission status
  static Future<bool> get isNotificationGranted async {
    if (Platform.isAndroid) {
      final sdkVersion = await getAndroidVersion();
      if (sdkVersion < 33) {
        return true; // Always granted on Android < 13
      }
    }
    return await Permission.notification.isGranted;
  }

  /// Check location permission status
  static Future<bool> get isLocationGranted async {
    return await Permission.location.isGranted;
  }

  // ==================== ANDROID VERSION DETECTION ====================

  /// Get Android SDK version (cached)
  static Future<int> getAndroidVersion() async {
    if (_cachedAndroidVersion != null) {
      return _cachedAndroidVersion!;
    }

    if (!Platform.isAndroid) {
      _cachedAndroidVersion = 0;
      return 0;
    }

    try {
      // Use MethodChannel to get Android SDK version
      const channel = MethodChannel('flutter.native/helper');
      final version = await channel.invokeMethod<int>('getAndroidSdkVersion');
      _cachedAndroidVersion = version ?? 33;
      return _cachedAndroidVersion!;
    } catch (e) {
      // Fallback: Parse from Platform.operatingSystemVersion
      try {
        final osVersion = Platform.operatingSystemVersion;
        // Try to extract SDK version from strings like "SDK 33" or "API 33"
        final sdkMatch = RegExp(
          r'SDK\s*(\d+)|API\s*(\d+)',
        ).firstMatch(osVersion);
        if (sdkMatch != null) {
          final version = int.tryParse(
            sdkMatch.group(1) ?? sdkMatch.group(2) ?? '',
          );
          if (version != null) {
            _cachedAndroidVersion = version;
            return version;
          }
        }
      } catch (_) {}

      // Default to Android 13 (conservative for permissions)
      debugPrint('Could not detect Android version, defaulting to 33');
      _cachedAndroidVersion = 33;
      return 33;
    }
  }

  // ==================== INTERNAL METHODS ====================

  /// Request permission and handle denial
  static Future<bool> _requestPermission(
    Permission permission,
    String permissionName,
  ) async {
    // Check if already granted
    if (await permission.isGranted) {
      return true;
    }

    // Check if restricted (iOS specific)
    if (await permission.isRestricted) {
      _showRestrictedMessage(permissionName);
      return false;
    }

    // Request permission
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    }

    // Handle limited (iOS 14+ photos)
    if (status.isLimited) {
      return true; // Limited access is still usable
    }

    // Handle permanently denied
    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(permissionName);
      return false;
    }

    // Handle denied
    if (status.isDenied) {
      _showDeniedMessage(permissionName);
      return false;
    }

    return false;
  }

  /// Request permission by type
  static Future<bool> _requestByType(AppPermission type) async {
    switch (type) {
      case AppPermission.camera:
        return await requestCamera();
      case AppPermission.storage:
        return await requestStorage();
      case AppPermission.photos:
        return await requestPhotos();
      case AppPermission.videos:
        return await requestVideos();
      case AppPermission.audio:
        return await requestAudio();
      case AppPermission.microphone:
        return await requestMicrophone();
      case AppPermission.notification:
        return await requestNotification();
      case AppPermission.location:
        return await requestLocation();
      case AppPermission.locationAlways:
        return await requestLocationAlways();
      case AppPermission.contacts:
        return await requestContacts();
      case AppPermission.calendar:
        return await requestCalendar();
      case AppPermission.phone:
        return await requestPhone();
    }
  }

  /// Get permission by type (version aware)
  static Future<Permission> _getPermission(AppPermission type) async {
    switch (type) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.storage:
        if (Platform.isAndroid) {
          final sdkVersion = await getAndroidVersion();
          if (sdkVersion >= 33) return Permission.photos;
        }
        return Permission.storage;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.videos:
        return Permission.videos;
      case AppPermission.audio:
        return Permission.audio;
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.notification:
        return Permission.notification;
      case AppPermission.location:
        return Permission.location;
      case AppPermission.locationAlways:
        return Permission.locationAlways;
      case AppPermission.contacts:
        return Permission.contacts;
      case AppPermission.calendar:
        return Permission.calendarFullAccess;
      case AppPermission.phone:
        return Permission.phone;
    }
  }

  /// Show settings dialog for permanently denied permission
  static Future<void> _showSettingsDialog(String permissionName) async {
    await Get.dialog(
      AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName permission is permanently denied. '
          'Please enable it from app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show denied message
  static void _showDeniedMessage(String permissionName) {
    Get.showSnackbar(
      GetSnackBar(
        message: '$permissionName permission denied.',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ),
    );
  }

  /// Show restricted message (iOS)
  static void _showRestrictedMessage(String permissionName) {
    Get.showSnackbar(
      GetSnackBar(
        message:
            '$permissionName permission is restricted by parental controls.',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ),
    );
  }
}
