/// Form validators. Each returns null when the value is valid,
/// or an error message to show under the field.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
  );
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );
  static final RegExp _digitsRegex = RegExp(
    r'^[0-9]+$',
  );

  static const int _minPasswordLength = 8;
  static const int _nationalIdLength = 14;
  static const int _otpLength = 6;

  static String? notEmpty(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value ==
            null ||
        value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(
    String? value,
  ) {
    final empty = notEmpty(
      value,
      fieldName: 'Email',
    );
    if (empty !=
        null)
      return empty;
    if (!_emailRegex.hasMatch(
      value!.trim(),
    )) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(
    String? value,
  ) {
    final empty = notEmpty(
      value,
      fieldName: 'Phone number',
    );
    if (empty !=
        null)
      return empty;
    final cleaned = value!.replaceAll(
      ' ',
      '',
    );
    if (!_phoneRegex.hasMatch(
      cleaned,
    )) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(
    String? value,
  ) {
    final empty = notEmpty(
      value,
      fieldName: 'Password',
    );
    if (empty !=
        null)
      return empty;
    if (value!.length <
        _minPasswordLength) {
      return 'Password must be at least $_minPasswordLength characters';
    }
    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
  ) {
    final empty = notEmpty(
      value,
      fieldName: 'Password confirmation',
    );
    if (empty !=
        null)
      return empty;
    if (value !=
        password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? nationalId(
    String? value,
  ) {
    final empty = notEmpty(
      value,
      fieldName: 'National ID',
    );
    if (empty !=
        null)
      return empty;
    final trimmed = value!.trim();
    if (trimmed.length !=
            _nationalIdLength ||
        !_digitsRegex.hasMatch(
          trimmed,
        )) {
      return 'National ID must be $_nationalIdLength digits';
    }
    return null;
  }

  static String? otp(
    String? value,
  ) {
    if (value ==
            null ||
        value.length !=
            _otpLength) {
      return 'Enter the $_otpLength-digit code';
    }
    return null;
  }

  /// For price and quantity in the product form.
  static String? positiveNumber(
    String? value, {
    String fieldName = 'Value',
  }) {
    final empty = notEmpty(
      value,
      fieldName: fieldName,
    );
    if (empty !=
        null)
      return empty;
    final number = num.tryParse(
      value!.trim(),
    );
    if (number ==
            null ||
        number <=
            0) {
      return '$fieldName must be a number greater than 0';
    }
    return null;
  }
}
