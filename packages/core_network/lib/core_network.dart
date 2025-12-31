/// Core Network Package
///
/// Network connectivity and retry utilities.
///
/// Usage:
/// ```dart
/// import 'package:core_network/core_network.dart';
///
/// if (await NetworkHelper.isConnected) {
///   // Make API call
/// }
/// ```
library core_network;

export 'src/network_helper.dart';
export 'src/api_retry_helper.dart';
