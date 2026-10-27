import 'package:easy_shop/core/utils/phone_utils.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneUtils.toLocal', () {
    test('keeps a plain 10 digit number', () {
      expect(PhoneUtils.toLocal('1013114901'), '1013114901');
    });

    test('removes a leading zero', () {
      expect(PhoneUtils.toLocal('01013114901'), '1013114901');
    });

    test('removes +20, spaces and the country code', () {
      expect(PhoneUtils.toLocal('+20 101 311 4901'), '1013114901');
      expect(PhoneUtils.toLocal('201013114901'), '1013114901');
    });

    test('does not cut a 10 digit number that starts with 20', () {
      expect(PhoneUtils.toLocal('2012345678'), '2012345678');
    });

    test('returns an empty string for null or empty input', () {
      expect(PhoneUtils.toLocal(null), '');
      expect(PhoneUtils.toLocal(''), '');
    });
  });

  group('PhoneUtils.toInternational', () {
    test('builds +20 followed by 10 digits', () {
      expect(PhoneUtils.toInternational('1013114901'), '+201013114901');
      expect(PhoneUtils.toInternational('01013114901'), '+201013114901');
    });
  });

  group('Validators.egyptianPhone', () {
    test('accepts 10 digits in the formats users type or paste', () {
      expect(Validators.egyptianPhone('1013114901'), isNull);
      expect(Validators.egyptianPhone('01013114901'), isNull);
      expect(Validators.egyptianPhone('+20 101 311 4901'), isNull);
    });

    test('rejects an empty value', () {
      expect(Validators.egyptianPhone(null), isNotNull);
      expect(Validators.egyptianPhone(''), isNotNull);
    });

    test('rejects 9 digits and 11 digits', () {
      expect(Validators.egyptianPhone('101311490'), isNotNull);
      expect(Validators.egyptianPhone('10131149011'), isNotNull);
    });
  });
}
