/// Core Validation Package
///
/// Provides comprehensive field validators for form validation.
///
/// Usage:
/// ```dart
/// import 'package:core_validation/core_validation.dart';
///
/// // Configure globally (optional)
/// Validator.configure(ValidatorConfig(
///   emailRequired: 'Email is mandatory',
/// ));
///
/// // Use in forms
/// TextFormField(validator: Validator.email)
/// ```
library core_validation;

export 'src/field_validators.dart';
