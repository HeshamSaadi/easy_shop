import 'dart:convert';

import 'package:easy_shop/core/utils/jwt_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/jwt_helper.dart';

void main() {
  group('isJwtExpired', () {
    test('returns false for a token that expires in the future', () {
      final token = buildJwt(expiresIn: const Duration(hours: 1));

      expect(isJwtExpired(token), isFalse);
    });

    test('returns true for a token that already expired', () {
      final token = buildJwt(expiresIn: const Duration(hours: -1));

      expect(isJwtExpired(token), isTrue);
    });

    test('treats a token that expires within the leeway as expired', () {
      final token = buildJwt(expiresIn: const Duration(seconds: 10));

      expect(isJwtExpired(token), isTrue);
    });

    test('does not treat a token as expired outside the leeway', () {
      final token = buildJwt(expiresIn: const Duration(minutes: 2));

      expect(isJwtExpired(token), isFalse);
    });

    test('uses the leeway that is passed in', () {
      final token = buildJwt(expiresIn: const Duration(seconds: 10));

      expect(isJwtExpired(token, leeway: Duration.zero), isFalse);
      expect(isJwtExpired(token, leeway: const Duration(minutes: 1)), isTrue);
    });

    test('treats a token without an exp claim as not expired', () {
      expect(isJwtExpired(buildJwt()), isFalse);
    });

    test('treats a token that is not made of three parts as expired', () {
      for (final token in ['', 'not-a-jwt', 'only.two']) {
        expect(isJwtExpired(token), isTrue, reason: 'token: "$token"');
      }
    });

    test('treats a payload that is not valid base64 as expired', () {
      expect(isJwtExpired('header.%%%.signature'), isTrue);
    });

    test('treats a payload that is not JSON as expired', () {
      final payload = base64Url.encode(utf8.encode('not json'));

      expect(isJwtExpired('header.$payload.signature'), isTrue);
    });
  });
}
