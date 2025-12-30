import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// File Picker Helper - File picking with validation
///
/// Usage:
/// ```dart
/// final file = await FilePickerHelper.pickImage(
///   maxSizeMB: 5,
/// );
///
/// final files = await FilePickerHelper.pickMultipleImages(
///   maxFiles: 5,
///   maxSizeMB: 10,
/// );
/// ```
class FilePickerHelper {
  FilePickerHelper._();

  // ==================== IMAGE PICKING ====================

  /// Pick single image
  static Future<File?> pickImage({
    double maxSizeMB = 10,
    List<String> allowedExtensions = const [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
    ],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);

    // Validate size
    final validation = await _validateFile(
      file,
      maxSizeMB: maxSizeMB,
      allowedExtensions: allowedExtensions,
    );

    if (!validation.isValid) {
      _showErrorMessage(validation.errorMessage!);
      return null;
    }

    return file;
  }

  /// Pick multiple images
  static Future<List<File>> pickMultipleImages({
    int maxFiles = 10,
    double maxSizeMB = 10,
    double maxTotalSizeMB = 50,
    List<String> allowedExtensions = const [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
    ],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    // Check max files
    if (result.files.length > maxFiles) {
      _showErrorMessage('Maximum $maxFiles files allowed.');
      return [];
    }

    final files = <File>[];
    double totalSize = 0;

    for (final platformFile in result.files) {
      final file = File(platformFile.path!);

      // Validate each file
      final validation = await _validateFile(
        file,
        maxSizeMB: maxSizeMB,
        allowedExtensions: allowedExtensions,
      );

      if (!validation.isValid) {
        _showErrorMessage('${platformFile.name}: ${validation.errorMessage}');
        continue;
      }

      totalSize += validation.fileSizeMB;

      // Check total size
      if (totalSize > maxTotalSizeMB) {
        _showErrorMessage('Total file size exceeds ${maxTotalSizeMB}MB limit.');
        break;
      }

      files.add(file);
    }

    return files;
  }

  // ==================== VIDEO PICKING ====================

  /// Pick single video
  static Future<File?> pickVideo({
    double maxSizeMB = 100,
    List<String> allowedExtensions = const ['mp4', 'mov', 'avi', 'mkv', 'webm'],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);

    final validation = await _validateFile(
      file,
      maxSizeMB: maxSizeMB,
      allowedExtensions: allowedExtensions,
    );

    if (!validation.isValid) {
      _showErrorMessage(validation.errorMessage!);
      return null;
    }

    return file;
  }

  // ==================== DOCUMENT PICKING ====================

  /// Pick single document
  static Future<File?> pickDocument({
    double maxSizeMB = 25,
    List<String> allowedExtensions = const [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'txt',
    ],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);

    final validation = await _validateFile(
      file,
      maxSizeMB: maxSizeMB,
      allowedExtensions: allowedExtensions,
    );

    if (!validation.isValid) {
      _showErrorMessage(validation.errorMessage!);
      return null;
    }

    return file;
  }

  /// Pick multiple documents
  static Future<List<File>> pickMultipleDocuments({
    int maxFiles = 5,
    double maxSizeMB = 25,
    List<String> allowedExtensions = const [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'txt',
    ],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    if (result.files.length > maxFiles) {
      _showErrorMessage('Maximum $maxFiles files allowed.');
      return [];
    }

    final files = <File>[];

    for (final platformFile in result.files) {
      final file = File(platformFile.path!);

      final validation = await _validateFile(
        file,
        maxSizeMB: maxSizeMB,
        allowedExtensions: allowedExtensions,
      );

      if (!validation.isValid) {
        _showErrorMessage('${platformFile.name}: ${validation.errorMessage}');
        continue;
      }

      files.add(file);
    }

    return files;
  }

  // ==================== ANY FILE PICKING ====================

  /// Pick any file
  static Future<File?> pickAnyFile({double maxSizeMB = 50}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);

    final validation = await _validateFileSize(file, maxSizeMB);

    if (!validation.isValid) {
      _showErrorMessage(validation.errorMessage!);
      return null;
    }

    return file;
  }

  // ==================== VALIDATION ====================

  /// Validate file size and extension
  static Future<FileValidationResult> _validateFile(
    File file, {
    required double maxSizeMB,
    required List<String> allowedExtensions,
  }) async {
    // Check if file exists
    if (!await file.exists()) {
      return FileValidationResult(
        isValid: false,
        errorMessage: 'File not found.',
        fileSizeMB: 0,
      );
    }

    // Check file size
    final sizeResult = await _validateFileSize(file, maxSizeMB);
    if (!sizeResult.isValid) return sizeResult;

    // Check extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return FileValidationResult(
        isValid: false,
        errorMessage:
            'File type .$extension is not allowed. '
            'Allowed types: ${allowedExtensions.join(', ')}',
        fileSizeMB: sizeResult.fileSizeMB,
      );
    }

    return FileValidationResult(
      isValid: true,
      fileSizeMB: sizeResult.fileSizeMB,
    );
  }

  /// Validate file size only
  static Future<FileValidationResult> _validateFileSize(
    File file,
    double maxSizeMB,
  ) async {
    final bytes = await file.length();
    final sizeMB = bytes / (1024 * 1024);

    if (sizeMB > maxSizeMB) {
      return FileValidationResult(
        isValid: false,
        errorMessage:
            'File size (${sizeMB.toStringAsFixed(1)}MB) exceeds '
            'maximum limit of ${maxSizeMB}MB.',
        fileSizeMB: sizeMB,
      );
    }

    return FileValidationResult(isValid: true, fileSizeMB: sizeMB);
  }

  /// Show error message
  static void _showErrorMessage(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.shade700,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      ),
    );
  }

  // ==================== UTILITY ====================

  /// Get file size in MB
  static Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Get file extension
  static String getExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  /// Get file name
  static String getFileName(File file) {
    return file.path.split(Platform.pathSeparator).last;
  }

  /// Check if file is image
  static bool isImage(File file) {
    final ext = getExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  /// Check if file is video
  static bool isVideo(File file) {
    final ext = getExtension(file);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv'].contains(ext);
  }

  /// Check if file is document
  static bool isDocument(File file) {
    final ext = getExtension(file);
    return [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
    ].contains(ext);
  }
}

/// File validation result
class FileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double fileSizeMB;

  FileValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.fileSizeMB,
  });
}
