import 'package:flutter/material.dart';

/// App Preload Helper - Preload APIs, images, and configs for performance
///
/// Usage:
/// ```dart
/// // Initialize preloading in splash screen
/// await AppPreloadHelper.init(
///   onProgress: (progress, message) {
///     print('Loading: $message ($progress%)');
///   },
/// );
/// ```
class AppPreloadHelper {
  AppPreloadHelper._();

  /// Registered preload tasks
  static final List<PreloadTask> _tasks = [];

  /// Progress callbacks
  static void Function(double progress, String message)? _onProgress;

  // ==================== REGISTRATION ====================

  /// Register a preload task
  static void registerTask(PreloadTask task) {
    _tasks.add(task);
  }

  /// Register multiple tasks
  static void registerTasks(List<PreloadTask> tasks) {
    _tasks.addAll(tasks);
  }

  /// Register API preload task
  static void registerApiTask({
    required String name,
    required Future<void> Function() execute,
    bool isRequired = false,
    int priority = 0,
  }) {
    _tasks.add(
      PreloadTask(
        name: name,
        type: PreloadType.api,
        execute: execute,
        isRequired: isRequired,
        priority: priority,
      ),
    );
  }

  /// Register image preload task
  static void registerImageTask({
    required String name,
    required List<String> imageUrls,
    required BuildContext context,
    int priority = 0,
  }) {
    _tasks.add(
      PreloadTask(
        name: name,
        type: PreloadType.image,
        execute: () async {
          for (final url in imageUrls) {
            try {
              await precacheImage(NetworkImage(url), context);
            } catch (_) {
              // Ignore image preload failures
            }
          }
        },
        isRequired: false,
        priority: priority,
      ),
    );
  }

  /// Register config preload task
  static void registerConfigTask({
    required String name,
    required Future<void> Function() execute,
    bool isRequired = true,
    int priority = 10,
  }) {
    _tasks.add(
      PreloadTask(
        name: name,
        type: PreloadType.config,
        execute: execute,
        isRequired: isRequired,
        priority: priority,
      ),
    );
  }

  // ==================== EXECUTION ====================

  /// Run all preload tasks
  static Future<PreloadResult> init({
    void Function(double progress, String message)? onProgress,
    Duration timeout = const Duration(seconds: 30),
    bool continueOnError = true,
  }) async {
    _onProgress = onProgress;

    // Sort by priority (higher priority first)
    _tasks.sort((a, b) => b.priority.compareTo(a.priority));

    final errors = <String, dynamic>{};
    int completed = 0;

    for (final task in _tasks) {
      try {
        _updateProgress(completed, _tasks.length, 'Loading ${task.name}...');

        await task.execute().timeout(timeout);

        completed++;
      } catch (e) {
        errors[task.name] = e;

        if (task.isRequired && !continueOnError) {
          return PreloadResult(
            success: false,
            errors: errors,
            completedTasks: completed,
            totalTasks: _tasks.length,
          );
        }

        completed++;
      }
    }

    _updateProgress(_tasks.length, _tasks.length, 'Ready!');

    return PreloadResult(
      success: errors.isEmpty,
      errors: errors,
      completedTasks: completed,
      totalTasks: _tasks.length,
    );
  }

  /// Run tasks of specific type
  static Future<PreloadResult> runTasksByType(
    PreloadType type, {
    void Function(double progress, String message)? onProgress,
  }) async {
    _onProgress = onProgress;

    final typeTasks = _tasks.where((t) => t.type == type).toList();
    final errors = <String, dynamic>{};
    int completed = 0;

    for (final task in typeTasks) {
      try {
        _updateProgress(completed, typeTasks.length, 'Loading ${task.name}...');
        await task.execute();
        completed++;
      } catch (e) {
        errors[task.name] = e;
        completed++;
      }
    }

    return PreloadResult(
      success: errors.isEmpty,
      errors: errors,
      completedTasks: completed,
      totalTasks: typeTasks.length,
    );
  }

  /// Run only required tasks
  static Future<PreloadResult> runRequiredTasks({
    void Function(double progress, String message)? onProgress,
  }) async {
    _onProgress = onProgress;

    final requiredTasks = _tasks.where((t) => t.isRequired).toList();
    final errors = <String, dynamic>{};
    int completed = 0;

    for (final task in requiredTasks) {
      try {
        _updateProgress(
          completed,
          requiredTasks.length,
          'Loading ${task.name}...',
        );
        await task.execute();
        completed++;
      } catch (e) {
        errors[task.name] = e;
        completed++;
      }
    }

    return PreloadResult(
      success: errors.isEmpty,
      errors: errors,
      completedTasks: completed,
      totalTasks: requiredTasks.length,
    );
  }

  // ==================== UTILITY ====================

  static void _updateProgress(int current, int total, String message) {
    if (total == 0) return;
    final progress = (current / total) * 100;
    _onProgress?.call(progress, message);
  }

  /// Clear all registered tasks
  static void clearTasks() {
    _tasks.clear();
  }

  /// Get registered task count
  static int get taskCount => _tasks.length;

  /// Get registered tasks by type
  static int getTaskCountByType(PreloadType type) {
    return _tasks.where((t) => t.type == type).length;
  }
}

/// Preload task types
enum PreloadType { api, image, config, other }

/// Preload task definition
class PreloadTask {
  final String name;
  final PreloadType type;
  final Future<void> Function() execute;
  final bool isRequired;
  final int priority;

  const PreloadTask({
    required this.name,
    required this.type,
    required this.execute,
    this.isRequired = false,
    this.priority = 0,
  });
}

/// Preload result
class PreloadResult {
  final bool success;
  final Map<String, dynamic> errors;
  final int completedTasks;
  final int totalTasks;

  const PreloadResult({
    required this.success,
    required this.errors,
    required this.completedTasks,
    required this.totalTasks,
  });

  double get progressPercent =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  bool get hasErrors => errors.isNotEmpty;
}
