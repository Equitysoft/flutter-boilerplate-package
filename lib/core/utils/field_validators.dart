/// Validation Configuration - Customize validation messages per project
class ValidatorConfig {
  // Required messages
  final String requiredNull;
  final String requiredEmpty;
  final String requiredInvalid;

  // Email messages
  final String emailRequired;
  final String emailInvalid;
  final String emailNoSpaces;

  // Phone messages
  final String phoneRequired;
  final String phoneDigitsOnly;
  final String phoneNoSpecialChars;
  final String Function(int length) phoneInvalidLength;

  // Password messages
  final String passwordRequired;
  final String Function(int minLength) passwordMinLength;
  final String passwordUppercase;
  final String passwordLowercase;
  final String passwordNumber;
  final String passwordSpecialChar;

  // Confirm Password messages
  final String confirmPasswordRequired;
  final String confirmPasswordMismatch;

  // Name messages
  final String nameRequired;
  final String nameLettersOnly;
  final String nameSpacesInvalid;
  final String Function(int minLength) nameMinLength;

  // URL messages
  final String urlRequired;
  final String urlInvalid;
  final String urlProtocol;

  // Number messages
  final String numberRequired;
  final String numberInvalid;
  final String Function(num min) numberMin;
  final String Function(num max) numberMax;

  // PIN messages
  final String pinRequired;
  final String pinDigitsOnly;
  final String pinInvalidLength;

  // OTP messages
  final String otpRequired;
  final String otpDigitsOnly;
  final String otpInvalidLength;
  final String Function(int length) otpExactLength;

  // Card messages
  final String cardRequired;
  final String cardDigitsOnly;
  final String cardInvalidLength;
  final String cardInvalid;

  // CVV messages
  final String cvvRequired;
  final String cvvDigitsOnly;
  final String cvvInvalidLength;

  const ValidatorConfig({
    // Required
    this.requiredNull = 'This field is required.',
    this.requiredEmpty = 'This field cannot be empty.',
    this.requiredInvalid = 'Please enter a valid value.',
    // Email
    this.emailRequired = 'Email address is required.',
    this.emailInvalid = 'Please enter a valid email address.',
    this.emailNoSpaces = 'Email address must not contain spaces.',
    // Phone
    this.phoneRequired = 'Mobile number is required.',
    this.phoneDigitsOnly = 'Mobile number must contain digits only.',
    this.phoneNoSpecialChars =
        'Mobile number must not contain special characters.',
    this.phoneInvalidLength = _defaultPhoneLength,
    // Password
    this.passwordRequired = 'Password is required.',
    this.passwordMinLength = _defaultPasswordMinLength,
    this.passwordUppercase =
        'Password must contain at least one uppercase letter.',
    this.passwordLowercase =
        'Password must contain at least one lowercase letter.',
    this.passwordNumber = 'Password must contain at least one number.',
    this.passwordSpecialChar =
        'Password must contain at least one special character.',
    // Confirm Password
    this.confirmPasswordRequired = 'Confirm password is required.',
    this.confirmPasswordMismatch = 'Passwords do not match.',
    // Name
    this.nameRequired = 'Name is required.',
    this.nameLettersOnly = 'Name must contain letters only.',
    this.nameSpacesInvalid = 'Name can contain spaces only between words.',
    this.nameMinLength = _defaultNameMinLength,
    // URL
    this.urlRequired = 'Website URL is required.',
    this.urlInvalid = 'Please enter a valid URL.',
    this.urlProtocol = 'URL must start with http:// or https://.',
    // Number
    this.numberRequired = 'This field is required.',
    this.numberInvalid = 'Please enter a valid number.',
    this.numberMin = _defaultNumberMin,
    this.numberMax = _defaultNumberMax,
    // PIN
    this.pinRequired = 'PIN is required.',
    this.pinDigitsOnly = 'PIN must contain digits only.',
    this.pinInvalidLength = 'PIN must be 4 or 6 digits long.',
    // OTP
    this.otpRequired = 'OTP is required.',
    this.otpDigitsOnly = 'OTP must contain digits only.',
    this.otpInvalidLength = 'OTP must be between 4 and 6 digits.',
    this.otpExactLength = _defaultOtpExactLength,
    // Card
    this.cardRequired = 'Card number is required.',
    this.cardDigitsOnly = 'Card number must contain digits only.',
    this.cardInvalidLength = 'Card number must be between 13 and 19 digits.',
    this.cardInvalid = 'Please enter a valid card number.',
    // CVV
    this.cvvRequired = 'CVV is required.',
    this.cvvDigitsOnly = 'CVV must contain digits only.',
    this.cvvInvalidLength = 'CVV must be 3 or 4 digits.',
  });

  // Default function implementations
  static String _defaultPhoneLength(int length) =>
      'Mobile number must be $length digits.';
  static String _defaultPasswordMinLength(int min) =>
      'Password must be at least $min characters long.';
  static String _defaultNameMinLength(int min) =>
      'Name must be at least $min characters long.';
  static String _defaultNumberMin(num min) =>
      'Value must be greater than or equal to $min.';
  static String _defaultNumberMax(num max) =>
      'Value must be less than or equal to $max.';
  static String _defaultOtpExactLength(int length) =>
      'OTP must be $length digits.';

  static const ValidatorConfig defaultConfig = ValidatorConfig();
}

/// Validation Types
enum ValidationType {
  required,
  email,
  phone,
  password,
  confirmPassword,
  name,
  url,
  number,
  pin,
  otp,
  cardNumber,
  cvv,
}

/// Field Validators - Comprehensive validation with configurable messages
///
/// Usage:
/// ```dart
/// // Configure globally (optional)
/// Validator.configure(ValidatorConfig(
///   emailRequired: 'Email is mandatory',
///   emailInvalid: 'Invalid email format',
/// ));
///
/// // Use in forms
/// TextFormField(validator: Validator.email)
/// ```
class Validator {
  Validator._();

  static ValidatorConfig _config = ValidatorConfig.defaultConfig;

  /// Configure validation messages globally
  static void configure(ValidatorConfig config) {
    _config = config;
  }

  /// Reset to default configuration
  static void resetConfig() {
    _config = ValidatorConfig.defaultConfig;
  }

  /// Get current configuration
  static ValidatorConfig get config => _config;

  // ==================== 1. REQUIRED ====================
  static String? required(String? value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null
          ? '$fieldName is required.'
          : _config.requiredNull;
    }
    if (value.isEmpty) {
      return fieldName != null
          ? '$fieldName cannot be empty.'
          : _config.requiredEmpty;
    }
    if (value.trim().isEmpty) {
      return _config.requiredInvalid;
    }
    return null;
  }

  // ==================== 2. EMAIL ====================
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return _config.emailRequired;
    }
    if (value.contains(' ')) {
      return _config.emailNoSpaces;
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim().toLowerCase())) {
      return _config.emailInvalid;
    }
    return null;
  }

  // ==================== 3. PHONE ====================
  static String? phone(String? value, {int length = 10}) {
    if (value == null || value.isEmpty) {
      return _config.phoneRequired;
    }
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return _config.phoneNoSpecialChars;
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length !=
        value.replaceAll(' ', '').replaceAll('-', '').length) {
      return _config.phoneDigitsOnly;
    }
    if (digitsOnly.length != length) {
      return _config.phoneInvalidLength(length);
    }
    return null;
  }

  // ==================== 4. PASSWORD ====================
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return _config.passwordRequired;
    }
    if (value.length < minLength) {
      return _config.passwordMinLength(minLength);
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return _config.passwordUppercase;
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return _config.passwordLowercase;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return _config.passwordNumber;
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return _config.passwordSpecialChar;
    }
    return null;
  }

  // ==================== 5. CONFIRM PASSWORD ====================
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return _config.confirmPasswordRequired;
    }
    if (value != password) {
      return _config.confirmPasswordMismatch;
    }
    return null;
  }

  // ==================== 6. NAME ====================
  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.isEmpty) {
      return _config.nameRequired;
    }
    if (value.trim().length < minLength) {
      return _config.nameMinLength(minLength);
    }
    if (!RegExp(r'^[a-zA-Z]+(\s[a-zA-Z]+)*$').hasMatch(value.trim())) {
      if (RegExp(r'[^a-zA-Z\s]').hasMatch(value)) {
        return _config.nameLettersOnly;
      }
      return _config.nameSpacesInvalid;
    }
    return null;
  }

  // ==================== 7. URL ====================
  static String? url(String? value, {bool isRequired = true}) {
    if (value == null || value.isEmpty) {
      if (isRequired) return _config.urlRequired;
      return null;
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return _config.urlProtocol;
    }
    final regex = RegExp(
      r'^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!regex.hasMatch(value.trim())) {
      return _config.urlInvalid;
    }
    return null;
  }

  // ==================== 8. NUMBER ====================
  static String? number(String? value, {num? minValue, num? maxValue}) {
    if (value == null || value.isEmpty) {
      return _config.numberRequired;
    }
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return _config.numberInvalid;
    }
    if (minValue != null && numValue < minValue) {
      return _config.numberMin(minValue);
    }
    if (maxValue != null && numValue > maxValue) {
      return _config.numberMax(maxValue);
    }
    return null;
  }

  // ==================== 9. PIN ====================
  static String? pin(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) {
      return _config.pinRequired;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return _config.pinDigitsOnly;
    }
    if (value.length != 4 && value.length != 6) {
      return _config.pinInvalidLength;
    }
    return null;
  }

  // ==================== 10. OTP ====================
  static String? otp(String? value, {int? exactLength}) {
    if (value == null || value.isEmpty) {
      return _config.otpRequired;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return _config.otpDigitsOnly;
    }
    if (exactLength != null) {
      if (value.length != exactLength) {
        return _config.otpExactLength(exactLength);
      }
    } else {
      if (value.length < 4 || value.length > 6) {
        return _config.otpInvalidLength;
      }
    }
    return null;
  }

  // ==================== 11. CARD NUMBER ====================
  static String? cardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return _config.cardRequired;
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return _config.cardDigitsOnly;
    }
    if (cleaned.length < 13 || cleaned.length > 19) {
      return _config.cardInvalidLength;
    }
    if (!_luhnCheck(cleaned)) {
      return _config.cardInvalid;
    }
    return null;
  }

  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  // ==================== 12. CVV ====================
  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return _config.cvvRequired;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return _config.cvvDigitsOnly;
    }
    if (value.length != 3 && value.length != 4) {
      return _config.cvvInvalidLength;
    }
    return null;
  }

  // ==================== GENERIC VALIDATE METHOD ====================
  static String? validate(
    String? value,
    ValidationType type, {
    String? confirmValue,
    String? fieldName,
    int? minLength,
    int? length,
    num? minValue,
    num? maxValue,
    bool isRequired = true,
  }) {
    switch (type) {
      case ValidationType.required:
        return required(value, fieldName: fieldName);
      case ValidationType.email:
        return email(value);
      case ValidationType.phone:
        return phone(value, length: length ?? 10);
      case ValidationType.password:
        return password(value, minLength: minLength ?? 6);
      case ValidationType.confirmPassword:
        return confirmPassword(value, confirmValue);
      case ValidationType.name:
        return name(value, minLength: minLength ?? 2);
      case ValidationType.url:
        return url(value, isRequired: isRequired);
      case ValidationType.number:
        return number(value, minValue: minValue, maxValue: maxValue);
      case ValidationType.pin:
        return pin(value, length: length ?? 4);
      case ValidationType.otp:
        return otp(value, exactLength: length);
      case ValidationType.cardNumber:
        return cardNumber(value);
      case ValidationType.cvv:
        return cvv(value);
    }
  }
}
