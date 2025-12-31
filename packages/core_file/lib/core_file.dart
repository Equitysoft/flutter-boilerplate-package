/// Core File Package
///
/// File picker utilities with validation.
///
/// Usage:
/// ```dart
/// import 'package:core_file/core_file.dart';
///
/// final file = await FilePickerHelper.pickImage(maxSizeMB: 5);
/// final files = await FilePickerHelper.pickMultipleImages(maxFiles: 5);
/// ```
library core_file;

export 'src/file_picker_helper.dart';
