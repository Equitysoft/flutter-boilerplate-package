import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Image Helper - Common image handling utilities
///
/// Usage:
/// ```dart
/// ImageHelper.network(
///   url: 'https://example.com/image.jpg',
///   width: 100,
///   height: 100,
/// )
/// ```
class ImageHelper {
  ImageHelper._();

  /// Default placeholder widget
  static Widget defaultPlaceholder({
    double? width,
    double? height,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      color: color ?? Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[400],
          size: (width ?? 50) * 0.4,
        ),
      ),
    );
  }

  /// Default error widget
  static Widget defaultErrorWidget({
    double? width,
    double? height,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      color: color ?? Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey[400],
          size: (width ?? 50) * 0.4,
        ),
      ),
    );
  }

  /// Network image with caching, placeholder, and error handling
  static Widget network({
    required String? url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
    Color? placeholderColor,
    Duration fadeInDuration = Duration.zero,
    Duration fadeOutDuration = Duration.zero,
    Map<String, String>? headers,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    // Handle null or empty URL
    if (url == null || url.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child:
            errorWidget ??
            defaultErrorWidget(
              width: width,
              height: height,
              color: placeholderColor,
            ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        httpHeaders: headers,
        placeholder: (context, url) =>
            placeholder ??
            defaultPlaceholder(
              width: width,
              height: height,
              color: placeholderColor,
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            defaultErrorWidget(
              width: width,
              height: height,
              color: placeholderColor,
            ),
      ),
    );
  }

  /// Circular network image (for avatars)
  static Widget avatar({
    required String? url,
    double size = 50,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
  }) {
    // Handle null or empty URL
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        child:
            errorWidget ??
            Icon(Icons.person, color: Colors.grey[400], size: size * 0.5),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: size / 2,
        backgroundImage: imageProvider,
        backgroundColor: backgroundColor ?? Colors.grey[200],
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        child:
            placeholder ??
            Icon(Icons.person, color: Colors.grey[400], size: size * 0.5),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        child:
            errorWidget ??
            Icon(Icons.person, color: Colors.grey[400], size: size * 0.5),
      ),
    );
  }

  /// Asset image with error handling
  static Widget asset({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            defaultErrorWidget(width: width, height: height),
      ),
    );
  }

  /// Get cached image provider
  static ImageProvider networkProvider(String url) {
    return CachedNetworkImageProvider(url);
  }

  /// Precache network image
  static Future<void> precache(BuildContext context, String url) async {
    await precacheImage(CachedNetworkImageProvider(url), context);
  }

  /// Precache multiple images
  static Future<void> precacheAll(
    BuildContext context,
    List<String> urls,
  ) async {
    await Future.wait(urls.map((url) => precache(context, url)));
  }
}
