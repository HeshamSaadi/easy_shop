import 'package:easy_shop/core/utils/phone_utils.dart';

/// Form validators. Each returns null when the value is valid,
/// or an error message to show under the field.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  static final RegExp _digitsRegex = RegExp(r'^[0-9]+$');

  static const int _minPasswordLength = 8;
  static const int _nationalIdLength = 14;
  static const int _otpLength = 6;

  //! Not empty

  static String? notEmpty(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  //!Email
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }
  //!Phone

  static String? phone(String? value) {
    final text = value?.replaceAll(' ', '') ?? '';
    if (text.isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(text)) return 'Enter a valid phone number';
    return null;
  } //! Password

  static String? password(String? value) {
    final text = value ?? '';
    if (text.trim().isEmpty) return 'Password is required';
    if (text.length < _minPasswordLength) {
      return 'Password must be at least $_minPasswordLength characters';
    }
    return null;
  }
  //! ConfirmPassword

  static String? confirmPassword(String? value, String password) {
    final text = value ?? '';
    if (text.trim().isEmpty) return 'Password confirmation is required';
    if (text != password) return 'Passwords do not match';
    return null;
  }
  //! national ID

  static String? nationalId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'National ID is required';
    if (text.length != _nationalIdLength || !_digitsRegex.hasMatch(text)) {
      return 'National ID must be $_nationalIdLength digits';
    }
    return null;
  }
  //! OTP

  static String? otp(String? value) {
    if (value == null || value.length != _otpLength) {
      return 'Enter the $_otpLength-digit code';
    }
    return null;
  }

  //! Positive number
  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';
    final number = num.tryParse(text);
    if (number == null || number <= 0) {
      return '$fieldName must be a number greater than 0';
    }
    return null;
  }

  static String? egyptianPhone(String? value) {
    final local = PhoneUtils.toLocal(value);
    if (local.isEmpty) return 'Phone number is required';
    if (local.length != PhoneUtils.localLength) {
      return 'Enter ${PhoneUtils.localLength} digits after ${PhoneUtils.egyptCode}';
    }
    return null;
  }

  //! Whole number, zero allowed (stock)
  static String? nonNegativeInteger(
    String? value, {
    String fieldName = 'Value',
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';
    final number = int.tryParse(text);
    if (number == null || number < 0) {
      return '$fieldName must be a whole number, 0 or more';
    }
    return null;
  }
}
