import 'package:easy_shop/core/utils/phone_utils.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneUtils.toLocal', () {
    const sameLocalNumber = {
      '+201013114901': '+20 and 10 digits',
      '+20 101 311 4901': '+20 with spaces',
      '201013114901': '20 without the plus',
      '01013114901': 'local format with the leading zero',
      '1013114901': 'only the 10 digits',
      '+20 (0) 101 311 4901': 'a zero after the country code',
    };
    sameLocalNumber.forEach((input, description) {
      test('returns the 10 digits for $description', () {
        expect(PhoneUtils.toLocal(input), '1013114901');
      });
    });

    test('returns an empty string for null, empty and non-digit input', () {
      expect(PhoneUtils.toLocal(null), '');
      expect(PhoneUtils.toLocal(''), '');
      expect(PhoneUtils.toLocal('abc'), '');
    });

    test('does not cut a leading 20 from a 10-digit number', () {
      expect(PhoneUtils.toLocal('2012345678'), '2012345678');
    });
  });

  group('PhoneUtils.toInternational', () {
    test('adds +20 in front of the local number', () {
      expect(PhoneUtils.toInternational('01013114901'), '+201013114901');
    });

    test('does not repeat the country code', () {
      expect(
        PhoneUtils.toInternational('+20 101 311 4901'),
        '+201013114901',
      );
    });
  });

  group('Validators.egyptianPhone', () {
    test('asks for a value when it is missing', () {
      for (final value in <String?>[null, '', '   ']) {
        expect(
          Validators.egyptianPhone(value),
          'Phone number is required',
          reason: 'value: "$value"',
        );
      }
    });

    test('accepts the number in every supported format', () {
      for (final value in [
        '+201013114901',
        '+20 101 311 4901',
        '01013114901',
        '101 311 4901',
      ]) {
        expect(
          Validators.egyptianPhone(value),
          isNull,
          reason: 'value: "$value"',
        );
      }
    });

    test('rejects a number with too few or too many digits', () {
      for (final value in ['+20 101 311 490', '0101311490', '+20 1013114901 5']) {
        expect(
          Validators.egyptianPhone(value),
          'Enter 10 digits after +20',
          reason: 'value: "$value"',
        );
      }
    });
  });
}
