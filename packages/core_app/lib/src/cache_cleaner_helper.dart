import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Cache Cleaner Helper - Clear app caches
///
/// Usage:
/// ```dart
/// // Clear all caches
/// await CacheCleanerHelper.clearAll();
///
/// // Clear only image cache
/// await CacheCleanerHelper.clearImageCache();
///
/// // Get cache size
/// final size = await CacheCleanerHelper.getCacheSize();
/// ```
class CacheCleanerHelper {
  CacheCleanerHelper._();

  /// Clear all caches
  static Future<void> clearAll() async {
    await Future.wait([clearImageCache(), clearTempFiles(), clearAppCache()]);
    debugPrint('All caches cleared');
  }

  /// Clear image cache (CachedNetworkImage)
  static Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      debugPrint('Image cache cleared');
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }

  /// Clear temporary files
  static Future<void> clearTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _deleteDirectoryContents(tempDir);
        debugPrint('Temp files cleared');
      }
    } catch (e) {
      debugPrint('Error clearing temp files: $e');
    }
  }

  /// Clear app cache directory
  static Future<void> clearAppCache() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      if (await cacheDir.exists()) {
        await _deleteDirectoryContents(cacheDir);
        debugPrint('App cache cleared');
      }
    } catch (e) {
      debugPrint('Error clearing app cache: $e');
    }
  }

  /// Clear downloads
  static Future<void> clearDownloads() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null && await downloadsDir.exists()) {
        await _deleteDirectoryContents(downloadsDir);
        debugPrint('Downloads cleared');
      }
    } catch (e) {
      debugPrint('Error clearing downloads: $e');
    }
  }

  /// Clear specific directory
  static Future<void> clearDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await _deleteDirectoryContents(dir);
        debugPrint('Directory cleared: $path');
      }
    } catch (e) {
      debugPrint('Error clearing directory: $e');
    }
  }

  // ==================== CACHE SIZE ====================

  /// Get total cache size in bytes
  static Future<int> getCacheSize() async {
    int totalSize = 0;
    totalSize += await getImageCacheSize();
    totalSize += await getTempSize();
    totalSize += await getAppCacheSize();
    return totalSize;
  }

  /// Get formatted cache size string
  static Future<String> getCacheSizeFormatted() async {
    final bytes = await getCacheSize();
    return _formatBytes(bytes);
  }

  /// Get image cache size
  static Future<int> getImageCacheSize() async {
    try {
      // Get cache directory from path_provider
      final cacheDir = await getTemporaryDirectory();
      final imageCacheDir = Directory('${cacheDir.path}/libCachedImageData');
      if (await imageCacheDir.exists()) {
        return await _getDirectorySize(imageCacheDir);
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get temp directory size
  static Future<int> getTempSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      return await _getDirectorySize(tempDir);
    } catch (e) {
      return 0;
    }
  }

  /// Get app cache size
  static Future<int> getAppCacheSize() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      return await _getDirectorySize(cacheDir);
    } catch (e) {
      return 0;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  /// Delete directory contents (not the directory itself)
  static Future<void> _deleteDirectoryContents(Directory dir) async {
    if (!await dir.exists()) return;

    final entities = await dir.list().toList();
    for (final entity in entities) {
      try {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      } catch (e) {
        debugPrint('Error deleting ${entity.path}: $e');
      }
    }
  }

  /// Get directory size recursively
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    if (!await dir.exists()) return size;

    try {
      final entities = await dir.list(recursive: true).toList();
      for (final entity in entities) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('Error calculating size: $e');
    }

    return size;
  }

  /// Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ==================== LOGOUT CLEANUP ====================

  /// Clear all user-related caches (for logout)
  static Future<void> clearForLogout() async {
    await Future.wait([clearImageCache(), clearTempFiles()]);
    debugPrint('Logout cleanup completed');
  }

  /// Clear caches for app upgrade
  static Future<void> clearForUpgrade() async {
    await Future.wait([clearImageCache(), clearAppCache()]);
    debugPrint('Upgrade cleanup completed');
  }

  /// Clear caches when storage is low
  static Future<void> clearForLowStorage() async {
    await Future.wait([clearImageCache(), clearTempFiles(), clearDownloads()]);
    debugPrint('Low storage cleanup completed');
  }
}
