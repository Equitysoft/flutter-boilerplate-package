/// Core App Package
///
/// App utilities including version helper, restart, preload, and cache cleaner.
///
/// Usage:
/// ```dart
/// import 'package:core_app/core_app.dart';
///
/// await AppVersionHelper.init();
/// print(AppVersionHelper.version);
/// ```
library core_app;

export 'src/app_version_helper.dart';
export 'src/app_restart_helper.dart';
export 'src/app_preload_helper.dart';
export 'src/cache_cleaner_helper.dart';
