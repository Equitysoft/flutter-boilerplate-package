import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Helper - Handle app permissions
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

  // ==================== SINGLE PERMISSION ====================

  /// Request camera permission
  static Future<bool> requestCamera() async {
    return await _requestPermission(Permission.camera, 'Camera');
  }

  /// Request storage permission
  static Future<bool> requestStorage() async {
    if (Platform.isAndroid) {
      // For Android 13+ use photos permission
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return await _requestPermission(Permission.photos, 'Photos');
      }
      return await _requestPermission(Permission.storage, 'Storage');
    }
    return await _requestPermission(Permission.photos, 'Photos');
  }

  /// Request photos permission
  static Future<bool> requestPhotos() async {
    return await _requestPermission(Permission.photos, 'Photos');
  }

  /// Request microphone permission
  static Future<bool> requestMicrophone() async {
    return await _requestPermission(Permission.microphone, 'Microphone');
  }

  /// Request notification permission
  static Future<bool> requestNotification() async {
    return await _requestPermission(Permission.notification, 'Notification');
  }

  /// Request location permission
  static Future<bool> requestLocation() async {
    return await _requestPermission(Permission.location, 'Location');
  }

  /// Request location always permission
  static Future<bool> requestLocationAlways() async {
    return await _requestPermission(
      Permission.locationAlways,
      'Location Always',
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
      final p = _getPermission(permission);
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

  /// Check storage permission status
  static Future<bool> get isStorageGranted async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
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
    return await Permission.notification.isGranted;
  }

  /// Check location permission status
  static Future<bool> get isLocationGranted async {
    return await Permission.location.isGranted;
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

    // Request permission
    final status = await permission.request();

    if (status.isGranted) {
      return true;
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

  /// Get permission by type
  static Permission _getPermission(AppPermission type) {
    switch (type) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.storage:
        return Permission.storage;
      case AppPermission.photos:
        return Permission.photos;
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

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    // Default to a high version for newer Android
    return 33;
  }
}
