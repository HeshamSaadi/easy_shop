import 'package:easy_shop/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.notEmpty', () {
    test('rejects null, empty and blank values', () {
      for (final value in <String?>[null, '', '   ']) {
        expect(
          Validators.notEmpty(value),
          'This field is required',
          reason: 'value: "$value"',
        );
      }
    });

    test('puts the field name in the message', () {
      expect(
        Validators.notEmpty('', fieldName: 'Business name'),
        'Business name is required',
      );
    });

    test('accepts any real text', () {
      expect(Validators.notEmpty('Elbatal Store'), isNull);
    });
  });

  group('Validators.email', () {
    const valid = [
      'admin@shop.com',
      ' admin@shop.com ',
      'first.last+tag@mail.example.com',
    ];
    for (final value in valid) {
      test('accepts "$value"', () {
        expect(Validators.email(value), isNull);
      });
    }

    test('asks for a value when it is missing', () {
      for (final value in <String?>[null, '', '   ']) {
        expect(
          Validators.email(value),
          'Email is required',
          reason: 'value: "$value"',
        );
      }
    });

    const invalid = [
      'admin',
      'admin@shop',
      '@shop.com',
      'admin@.com',
      'ad min@shop.com',
    ];
    for (final value in invalid) {
      test('rejects "$value"', () {
        expect(Validators.email(value), 'Enter a valid email address');
      });
    }
  });

  group('Validators.phone', () {
    const valid = ['+201013114901', '+20 101 311 4901'];
    for (final value in valid) {
      test('accepts "$value"', () {
        expect(Validators.phone(value), isNull);
      });
    }

    test('asks for a value when it is missing', () {
      for (final value in <String?>[null, '', '   ']) {
        expect(
          Validators.phone(value),
          'Phone number is required',
          reason: 'value: "$value"',
        );
      }
    });

    const invalid = ['12345', '+20abc', '0101-311-4002', '1234567890123456'];
    for (final value in invalid) {
      test('rejects "$value"', () {
        expect(Validators.phone(value), 'Enter a valid phone number');
      });
    }
  });

  group('Validators.password', () {
    test('asks for a value when it is missing or only spaces', () {
      for (final value in <String?>[null, '', '        ']) {
        expect(
          Validators.password(value),
          'Password is required',
          reason: 'value: "$value"',
        );
      }
    });

    test('rejects a password shorter than 8 characters', () {
      expect(
        Validators.password('1234567'),
        'Password must be at least 8 characters',
      );
    });

    test('accepts a password of 8 characters or more', () {
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password('a much longer password'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('asks for a value when it is missing', () {
      expect(
        Validators.confirmPassword(null, '12345678'),
        'Password confirmation is required',
      );
      expect(
        Validators.confirmPassword('', '12345678'),
        'Password confirmation is required',
      );
    });

    test('rejects a different password', () {
      expect(
        Validators.confirmPassword('abcdefgh', '12345678'),
        'Passwords do not match',
      );
    });

    test('accepts the same password', () {
      expect(Validators.confirmPassword('12345678', '12345678'), isNull);
    });
  });

  group('Validators.nationalId', () {
    const valid = ['29001011234567', '  29001011234567  '];
    for (final value in valid) {
      test('accepts "$value"', () {
        expect(Validators.nationalId(value), isNull);
      });
    }

    test('asks for a value when it is missing', () {
      for (final value in <String?>[null, '', '   ']) {
        expect(
          Validators.nationalId(value),
          'National ID is required',
          reason: 'value: "$value"',
        );
      }
    });

    const invalid = [
      '2900101123456', // 13 digits
      '290010112345678', // 15 digits
      '2900101123456a', // 14 characters, one is a letter
      '2900101 123456', // 14 characters, one is a space
    ];
    for (final value in invalid) {
      test('rejects "$value"', () {
        expect(Validators.nationalId(value), 'National ID must be 14 digits');
      });
    }
  });

  group('Validators.otp', () {
    test('accepts exactly 6 characters', () {
      expect(Validators.otp('123456'), isNull);
    });

    test('rejects missing, short and long codes', () {
      for (final value in <String?>[null, '', '12345', '1234567']) {
        expect(
          Validators.otp(value),
          'Enter the 6-digit code',
          reason: 'value: "$value"',
        );
      }
    });
  });

  group('Validators.positiveNumber', () {
    test('asks for a value when it is missing', () {
      expect(
        Validators.positiveNumber('', fieldName: 'Price'),
        'Price is required',
      );
      expect(Validators.positiveNumber(null), 'Value is required');
    });

    test('rejects text, zero and negative numbers', () {
      for (final value in ['abc', '0', '-5']) {
        expect(
          Validators.positiveNumber(value, fieldName: 'Price'),
          'Price must be a number greater than 0',
          reason: 'value: "$value"',
        );
      }
    });

    test('accepts whole and decimal numbers above zero', () {
      expect(Validators.positiveNumber('150'), isNull);
      expect(Validators.positiveNumber('12.5'), isNull);
      expect(Validators.positiveNumber('0.5'), isNull);
    });
  });

  group('Validators.nonNegativeInteger', () {
    test('asks for a value when it is missing', () {
      expect(
        Validators.nonNegativeInteger('', fieldName: 'Stock'),
        'Stock is required',
      );
    });

    test('rejects text, decimals and negative numbers', () {
      for (final value in ['abc', '1.5', '-1']) {
        expect(
          Validators.nonNegativeInteger(value, fieldName: 'Stock'),
          'Stock must be a whole number, 0 or more',
          reason: 'value: "$value"',
        );
      }
    });

    test('accepts zero and positive whole numbers', () {
      expect(Validators.nonNegativeInteger('0'), isNull);
      expect(Validators.nonNegativeInteger('10'), isNull);
    });
  });
}