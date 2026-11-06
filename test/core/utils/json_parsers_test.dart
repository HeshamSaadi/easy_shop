import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseInt', () {
    test('reads numbers and numeric strings', () {
      expect(parseInt(10), 10);
      expect(parseInt('10'), 10);
      expect(parseInt(10.0), 10);
    });

    test('returns the fallback for null or text', () {
      expect(parseInt(null), 0);
      expect(parseInt('abc'), 0);
      expect(parseInt('abc', fallback: -1), -1);
    });
  });

  group('parseDouble', () {
    test('reads numbers and numeric strings', () {
      expect(parseDouble(150), 150.0);
      expect(parseDouble('150'), 150.0);
      expect(parseDouble('30.033333'), 30.033333);
    });

    test('returns the fallback for null or text', () {
      expect(parseDouble(null), 0.0);
      expect(parseDouble('abc'), 0.0);
    });
  });

  group('parseNullableDouble', () {
    test('keeps null as null', () {
      expect(parseNullableDouble(null), isNull);
      expect(parseNullableDouble('abc'), isNull);
    });

    test('reads latitude as number or string', () {
      expect(parseNullableDouble(30.033333), 30.033333);
      expect(parseNullableDouble('30.033333'), 30.033333);
    });
  });

  group('parseBool', () {
    test('reads 1, "1" and true as true', () {
      expect(parseBool(1), isTrue);
      expect(parseBool('1'), isTrue);
      expect(parseBool(true), isTrue);
    });

    test('reads 0, "0" and false as false', () {
      expect(parseBool(0), isFalse);
      expect(parseBool('0'), isFalse);
      expect(parseBool(false), isFalse);
    });

    test('returns the fallback for anything else', () {
      expect(parseBool(null), isFalse);
      expect(parseBool('maybe', fallback: true), isTrue);
    });
  });
}
