/// Core Permission Package
///
/// Handle app permissions with Android version-aware support.
///
/// Usage:
/// ```dart
/// import 'package:core_permission/core_permission.dart';
///
/// if (await PermissionHelper.requestCamera()) {
///   // Camera granted
/// }
/// ```
library core_permission;

export 'src/permission_helper.dart';
