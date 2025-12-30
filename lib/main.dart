import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/network/api_config.dart';
import 'package:app_boilerplate/services/prefs_service.dart';
import 'package:app_boilerplate/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initServices();

  runApp(const MyApp());
}

/// Initialize all services before app starts
Future<void> _initServices() async {
  // Initialize SharedPreferences
  await PrefsService.init();

  // ============================================================
  // TODO: Configure your API URLs here for each environment
  // ============================================================
  EnvironmentConfig.initApiConfig(
    environment: Environment.development, // Change for staging/production
    devBaseUrl: 'https://dev-api.yourapp.com',
    stagingBaseUrl: 'https://staging-api.yourapp.com',
    prodBaseUrl: 'https://api.yourapp.com',
    apiVersion: '/api/v1',
    // Optional: Add default headers for all requests
    // defaultHeaders: {'X-App-Version': '1.0.0'},
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    // TODO: Add your firebase_options.dart
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging Service
  await FirebaseService.instance.init(
    onNotificationTapped: (data) {
      // Handle notification tap - navigate to specific screen
      debugPrint('Notification tapped with data: $data');
      _handleNotificationNavigation(data);
    },
    onForegroundMessage: (message) {
      // Handle foreground message
      debugPrint('Foreground message: ${message.notification?.title}');
    },
    onTokenRefresh: (token) {
      // Handle FCM token refresh - send to server
      debugPrint('FCM token refreshed: $token');
      _sendTokenToServer(token);
    },
  );

  // Setup API client auth error callback
  ApiClient.instance.setAuthErrorCallback(() {
    // Handle auth error - navigate to login
    debugPrint('Auth error - navigating to login');
    // Get.offAllNamed('/login');
  });
}

/// Handle notification navigation based on data
void _handleNotificationNavigation(Map<String, dynamic> data) {
  final type = data['type'] as String?;
  final id = data['id'] as String?;

  debugPrint('Navigating for type: $type, id: $id');

  switch (type) {
    case 'chat':
      // Navigate to chat screen
      // Get.toNamed('/chat', arguments: {'id': id});
      break;
    case 'order':
      // Navigate to order details
      // Get.toNamed('/order-details', arguments: {'id': id});
      break;
    default:
      // Navigate to notifications list
      // Get.toNamed('/notifications');
      break;
  }
}

/// Send FCM token to server
Future<void> _sendTokenToServer(String token) async {
  // TODO: Implement API call to update FCM token on server
  // await ApiClient.instance.post(
  //   ApiEndpoints.updateFcmToken,
  //   data: {'fcm_token': token},
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App Boilerplate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      // TODO: Setup routes
      // getPages: AppPages.routes,
      // initialRoute: AppRoutes.splash,
    );
  }
}

/// Sample Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Boilerplate'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Boilerplate Ready!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Services initialized successfully',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Included Features:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem('✓ PrefsService (SharedPreferences)'),
          _buildFeatureItem('✓ FirebaseService (FCM + Local Notifications)'),
          _buildFeatureItem('✓ ApiClient (Dio with interceptors)'),
          _buildFeatureItem('✓ Error handling & Exceptions'),
          _buildFeatureItem('✓ Token management & Auto-refresh'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
