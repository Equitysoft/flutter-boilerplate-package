import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Background Task Helper - Periodic sync and background tasks
///
/// Usage:
/// ```dart
/// // Initialize in main()
/// await BackgroundTaskHelper.init(callbackDispatcher);
///
/// // Register periodic task
/// await BackgroundTaskHelper.registerPeriodicTask(
///   taskName: 'sync_data',
///   frequency: Duration(hours: 1),
/// );
/// ```

/// Background task callback - must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('Background task executing: $taskName');

    try {
      // Get handler from registry
      final handler = BackgroundTaskHelper._handlers[taskName];
      if (handler != null) {
        return await handler(inputData);
      }

      debugPrint('No handler found for task: $taskName');
      return true;
    } catch (e) {
      debugPrint('Background task failed: $taskName - $e');
      return false;
    }
  });
}

class BackgroundTaskHelper {
  BackgroundTaskHelper._();

  /// Task handlers registry
  static final Map<String, Future<bool> Function(Map<String, dynamic>?)>
  _handlers = {};

  /// Initialize background task manager
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  // ==================== TASK REGISTRATION ====================

  /// Register a task handler
  static void registerHandler(
    String taskName,
    Future<bool> Function(Map<String, dynamic>?) handler,
  ) {
    _handlers[taskName] = handler;
  }

  /// Register one-time task
  static Future<void> registerOneTimeTask({
    required String taskName,
    required String uniqueName,
    Duration initialDelay = Duration.zero,
    Map<String, dynamic>? inputData,
    Constraints? constraints,
    BackoffPolicy backoffPolicy = BackoffPolicy.linear,
    Duration backoffDelay = const Duration(seconds: 10),
    OutOfQuotaPolicy outOfQuotaPolicy =
        OutOfQuotaPolicy.run_as_non_expedited_work_request,
  }) async {
    await Workmanager().registerOneOffTask(
      uniqueName,
      taskName,
      initialDelay: initialDelay,
      inputData: inputData,
      constraints: constraints,
      backoffPolicy: backoffPolicy,
      backoffPolicyDelay: backoffDelay,
      outOfQuotaPolicy: outOfQuotaPolicy,
    );
    debugPrint('Registered one-time task: $taskName');
  }

  /// Register periodic task
  static Future<void> registerPeriodicTask({
    required String taskName,
    required String uniqueName,
    required Duration frequency,
    Duration initialDelay = Duration.zero,
    Map<String, dynamic>? inputData,
    Constraints? constraints,
    BackoffPolicy backoffPolicy = BackoffPolicy.linear,
    Duration backoffDelay = const Duration(seconds: 10),
    OutOfQuotaPolicy outOfQuotaPolicy =
        OutOfQuotaPolicy.run_as_non_expedited_work_request,
  }) async {
    await Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: frequency,
      initialDelay: initialDelay,
      inputData: inputData,
      constraints: constraints,
      backoffPolicy: backoffPolicy,
      backoffPolicyDelay: backoffDelay,
      outOfQuotaPolicy: outOfQuotaPolicy,
    );
    debugPrint(
      'Registered periodic task: $taskName (every ${frequency.inMinutes} minutes)',
    );
  }

  // ==================== TASK CANCELLATION ====================

  /// Cancel specific task
  static Future<void> cancelTask(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
    debugPrint('Cancelled task: $uniqueName');
  }

  /// Cancel all tasks with specific tag
  static Future<void> cancelByTag(String tag) async {
    await Workmanager().cancelByTag(tag);
    debugPrint('Cancelled tasks with tag: $tag');
  }

  /// Cancel all tasks
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    debugPrint('Cancelled all background tasks');
  }

  // ==================== COMMON TASK TYPES ====================

  /// Register data sync task (every 15 minutes)
  static Future<void> registerSyncTask({
    required Future<bool> Function(Map<String, dynamic>?) onSync,
    Duration frequency = const Duration(minutes: 15),
  }) async {
    registerHandler('data_sync', onSync);
    await registerPeriodicTask(
      taskName: 'data_sync',
      uniqueName: 'data_sync_periodic',
      frequency: frequency,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Register upload retry task (every 30 minutes)
  static Future<void> registerUploadRetryTask({
    required Future<bool> Function(Map<String, dynamic>?) onRetry,
    Duration frequency = const Duration(minutes: 30),
  }) async {
    registerHandler('upload_retry', onRetry);
    await registerPeriodicTask(
      taskName: 'upload_retry',
      uniqueName: 'upload_retry_periodic',
      frequency: frequency,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Register cache cleanup task (every 24 hours)
  static Future<void> registerCacheCleanupTask({
    required Future<bool> Function(Map<String, dynamic>?) onCleanup,
  }) async {
    registerHandler('cache_cleanup', onCleanup);
    await registerPeriodicTask(
      taskName: 'cache_cleanup',
      uniqueName: 'cache_cleanup_periodic',
      frequency: const Duration(hours: 24),
    );
  }

  /// Register notification check task (every hour)
  static Future<void> registerNotificationCheckTask({
    required Future<bool> Function(Map<String, dynamic>?) onCheck,
  }) async {
    registerHandler('notification_check', onCheck);
    await registerPeriodicTask(
      taskName: 'notification_check',
      uniqueName: 'notification_check_periodic',
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // ==================== UTILITY ====================

  /// Check if task is registered
  static bool isHandlerRegistered(String taskName) {
    return _handlers.containsKey(taskName);
  }

  /// Get all registered handlers
  static List<String> get registeredHandlers => _handlers.keys.toList();

  /// Clear all handlers
  static void clearHandlers() {
    _handlers.clear();
  }
}
