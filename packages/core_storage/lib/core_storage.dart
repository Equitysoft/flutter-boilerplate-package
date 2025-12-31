/// Core Storage Package
///
/// SharedPreferences wrapper for local storage management.
///
/// Usage:
/// ```dart
/// import 'package:core_storage/core_storage.dart';
///
/// await PrefsService.init();
/// PrefsService.instance.setAccessToken('token');
/// ```
library core_storage;

export 'src/prefs_service.dart';
