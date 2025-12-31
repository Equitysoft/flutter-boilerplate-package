# Flutter Boilerplate Packages

A collection of modular Flutter packages for common utilities.

## Packages

| Package | Description |
|---------|-------------|
| `core_validation` | Field validators for form validation |
| `core_permission` | Android/iOS permission handling |
| `core_network` | Network connectivity & retry utilities |
| `core_logger` | Centralized logging with customizable output |
| `core_datetime` | Date & time formatting and utilities |
| `core_storage` | SharedPreferences wrapper |
| `core_image` | Image handling with caching |
| `core_file` | File picker with validation |
| `core_screen` | Screen size & orientation helpers |
| `core_pagination` | Pagination for list data |
| `core_app` | App utilities (version, restart, cache) |

## Usage

Add packages as path dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  core_validation:
    path: packages/core_validation
  core_permission:
    path: packages/core_permission
  # ... add more as needed
```

## Example

```dart
import 'package:core_validation/core_validation.dart';
import 'package:core_permission/core_permission.dart';
import 'package:core_network/core_network.dart';

// Form validation
TextFormField(
  validator: Validator.email,
);

// Permission handling
if (await PermissionHelper.requestCamera()) {
  // Camera granted
}

// Network check
if (await NetworkHelper.isConnected) {
  // Make API call
}
```
