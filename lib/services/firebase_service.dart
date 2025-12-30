import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_boilerplate/services/prefs_service.dart';

/// Background message handler - Must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message here
}

/// FirebaseService - Handles Firebase initialization and push notifications
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseMessaging? _messaging;
  static FlutterLocalNotificationsPlugin? _localNotifications;

  // Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  FirebaseService._();

  /// Get singleton instance
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  /// Get FirebaseMessaging instance
  FirebaseMessaging get messaging {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  /// Get FlutterLocalNotificationsPlugin instance
  FlutterLocalNotificationsPlugin get localNotifications {
    _localNotifications ??= FlutterLocalNotificationsPlugin();
    return _localNotifications!;
  }

  // ==================== Callbacks ====================
  /// Callback when notification is tapped (foreground/background)
  Function(Map<String, dynamic> data)? onNotificationTapped;

  /// Callback when notification is received in foreground
  Function(RemoteMessage message)? onForegroundMessage;

  /// Callback when FCM token is refreshed
  Function(String token)? onTokenRefresh;

  // ==================== Initialization ====================

  /// Initialize Firebase and FCM - Call this in main() after Firebase.initializeApp()
  Future<void> init({
    Function(Map<String, dynamic> data)? onNotificationTapped,
    Function(RemoteMessage message)? onForegroundMessage,
    Function(String token)? onTokenRefresh,
  }) async {
    this.onNotificationTapped = onNotificationTapped;
    this.onForegroundMessage = onForegroundMessage;
    this.onTokenRefresh = onTokenRefresh;

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initLocalNotifications();

    // Set up message handlers
    _setupMessageHandlers();

    // Get and save FCM token
    await _getAndSaveToken();

    // Listen for token refresh
    messaging.onTokenRefresh.listen((token) {
      _saveToken(token);
      onTokenRefresh?.call(token);
    });
  }

  /// Request notification permission
  Future<NotificationSettings> _requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Notification permission status: ${settings.authorizationStatus}',
    );
    return settings;
  }

  /// Initialize local notifications for foreground display
  Future<void> _initLocalNotifications() async {
    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Handle notification tap response
  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        onNotificationTapped?.call(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Set up FCM message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      onForegroundMessage?.call(message);
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.messageId}');
      onNotificationTapped?.call(message.data);
    });

    // Check for initial message (app opened from terminated state)
    _checkInitialMessage();
  }

  /// Check if app was opened from a notification
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state by notification');
      // Delay to ensure app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        onNotificationTapped?.call(initialMessage.data);
      });
    }
  }

  // ==================== Token Management ====================

  /// Get FCM token and save to prefs
  Future<String?> _getAndSaveToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token
  Future<void> _saveToken(String token) async {
    debugPrint('FCM Token: $token');
    await PrefsService.instance.setFcmToken(token);
  }

  /// Get current FCM token
  Future<String?> getFcmToken() async {
    return await messaging.getToken();
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    await messaging.deleteToken();
    await PrefsService.instance.remove('fcm_token');
  }

  // ==================== Local Notifications ====================

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Show custom local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? channelId,
    String? channelName,
  }) async {
    await localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId ?? _channel.id,
          channelName ?? _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await localNotifications.cancelAll();
  }

  // ==================== Topic Subscription ====================

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  // ==================== Permission ====================

  /// Check notification permission status
  Future<AuthorizationStatus> getPermissionStatus() async {
    NotificationSettings settings = await messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Request permission again
  Future<bool> requestPermission() async {
    NotificationSettings settings = await _requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
