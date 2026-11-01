import 'package:easy_shop/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('notEmpty', () {
    test('rejects null, empty and spaces only', () {
      expect(Validators.notEmpty(null), isNotNull);
      expect(Validators.notEmpty(''), isNotNull);
      expect(Validators.notEmpty('   '), isNotNull);
    });

    test('uses the field name in the message', () {
      expect(Validators.notEmpty('', fieldName: 'Name'), 'Name is required');
    });

    test('accepts a value', () => expect(Validators.notEmpty('a'), isNull));
  });

  group('email', () {
    test('accepts valid emails', () {
      expect(Validators.email('a.b+c@mail.com'), isNull);
      expect(Validators.email('  user@mail.co.uk '), isNull);
    });

    test('rejects invalid emails', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a@.com'), isNotNull);
    });
  });

  group('password', () {
    test('needs at least 8 characters', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });

    test('rejects empty and spaces only', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('        '), isNotNull);
    });
  });

  group('confirmPassword', () {
    test('must match the password', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(Validators.confirmPassword('abc12346', 'abc12345'), isNotNull);
    });

    test('rejects empty', () {
      expect(Validators.confirmPassword('', 'abc12345'), isNotNull);
    });
  });

  group('nationalId', () {
    test('needs exactly 14 digits', () {
      expect(Validators.nationalId('12345678901234'), isNull);
      expect(Validators.nationalId('1234567890123'), isNotNull);
      expect(Validators.nationalId('1234567890123a'), isNotNull);
      expect(Validators.nationalId(''), isNotNull);
    });
  });

  group('otp', () {
    test('needs exactly 6 characters', () {
      expect(Validators.otp('123456'), isNull);
      expect(Validators.otp('12345'), isNotNull);
      expect(Validators.otp(null), isNotNull);
    });
  });

  group('positiveNumber', () {
    test('accepts numbers greater than 0', () {
      expect(Validators.positiveNumber('10'), isNull);
      expect(Validators.positiveNumber('0.5'), isNull);
    });

    test('rejects 0, negatives, text and empty', () {
      expect(Validators.positiveNumber('0'), isNotNull);
      expect(Validators.positiveNumber('-1'), isNotNull);
      expect(Validators.positiveNumber('abc'), isNotNull);
      expect(Validators.positiveNumber(''), isNotNull);
    });
  });

  group('egyptianPhone', () {
    test('accepts +20 followed by 10 digits, ignoring spaces', () {
      expect(Validators.egyptianPhone('+201012345678'), isNull);
      expect(Validators.egyptianPhone('+20 101 234 5678'), isNull);
    });

    test('accepts a leading 0 after the +20 prefix', () {
      expect(Validators.egyptianPhone('01012345678'), isNull);
    });

    test('rejects other formats', () {
      expect(Validators.egyptianPhone('+20101234567'), isNotNull);
      expect(Validators.egyptianPhone(''), isNotNull);
    });
  });

  group('nonNegativeInteger', () {
    test('accepts 0 and positive whole numbers', () {
      expect(Validators.nonNegativeInteger('0'), isNull);
      expect(Validators.nonNegativeInteger('25'), isNull);
    });

    test('rejects negatives, decimals, text and empty', () {
      expect(Validators.nonNegativeInteger('-1'), isNotNull);
      expect(Validators.nonNegativeInteger('1.5'), isNotNull);
      expect(Validators.nonNegativeInteger('abc'), isNotNull);
      expect(Validators.nonNegativeInteger(''), isNotNull);
    });
  });
}
