import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Screen Helper - Screen size and orientation utilities
///
/// Usage:
/// ```dart
/// if (ScreenHelper.isTablet(context)) {
///   // Show tablet layout
/// }
///
/// final width = ScreenHelper.width(context);
/// ```
class ScreenHelper {
  ScreenHelper._();

  // ==================== SCREEN SIZE ====================

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get screen size
  static Size size(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get screen aspect ratio
  static double aspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  /// Get device pixel ratio
  static double pixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // ==================== SAFE AREA ====================

  /// Get top safe area padding (status bar)
  static double topPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get bottom safe area padding (home indicator)
  static double bottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Get safe area padding
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view insets (keyboard, etc.)
  static EdgeInsets viewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // ==================== ORIENTATION ====================

  /// Get screen orientation
  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // ==================== DEVICE TYPE ====================

  /// Check if device is a phone (width < 600)
  static bool isPhone(BuildContext context) {
    return width(context) < 600;
  }

  /// Check if device is a tablet (width >= 600)
  static bool isTablet(BuildContext context) {
    return width(context) >= 600;
  }

  /// Check if device is a large tablet (width >= 900)
  static bool isLargeTablet(BuildContext context) {
    return width(context) >= 900;
  }

  /// Check if device is desktop (width >= 1200)
  static bool isDesktop(BuildContext context) {
    return width(context) >= 1200;
  }

  /// Get device type
  static DeviceType deviceType(BuildContext context) {
    final w = width(context);
    if (w >= 1200) return DeviceType.desktop;
    if (w >= 900) return DeviceType.largeTablet;
    if (w >= 600) return DeviceType.tablet;
    return DeviceType.phone;
  }

  // ==================== RESPONSIVE VALUE ====================

  /// Get responsive value based on screen width
  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? largeTablet,
    T? desktop,
  }) {
    final type = deviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return desktop ?? largeTablet ?? tablet ?? phone;
      case DeviceType.largeTablet:
        return largeTablet ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  /// Get responsive value based on orientation
  static T orientationValue<T>(
    BuildContext context, {
    required T portrait,
    required T landscape,
  }) {
    return isPortrait(context) ? portrait : landscape;
  }

  // ==================== PERCENTAGE BASED ====================

  /// Get percentage of screen width
  static double widthPercent(BuildContext context, double percent) {
    return width(context) * (percent / 100);
  }

  /// Get percentage of screen height
  static double heightPercent(BuildContext context, double percent) {
    return height(context) * (percent / 100);
  }

  // ==================== TEXT SCALE ====================

  /// Get text scale factor
  static double textScale(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Check if large text is enabled
  static bool isLargeText(BuildContext context) {
    return textScale(context) > 1.0;
  }

  // ==================== PLATFORM BRIGHTNESS ====================

  /// Get platform brightness
  static Brightness brightness(BuildContext context) {
    return MediaQuery.of(context).platformBrightness;
  }

  /// Check if dark mode
  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Check if light mode
  static bool isLightMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.light;
  }

  // ==================== NO CONTEXT METHODS ====================

  /// Get screen size without context (using PlatformDispatcher)
  static Size get screenSize {
    final view = ui.PlatformDispatcher.instance.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  /// Get screen width without context
  static double get screenWidth => screenSize.width;

  /// Get screen height without context
  static double get screenHeight => screenSize.height;
}

/// Device type enum
enum DeviceType { phone, tablet, largeTablet, desktop }
