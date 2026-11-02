import 'package:easy_shop/core/errors/error_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorModel.fromJson', () {
    test('reads a plain string message', () {
      final model = ErrorModel.fromJson({
        'data': null,
        'message': 'Invalid or expired OTP',
      });

      expect(model.message, 'Invalid or expired OTP');
      expect(model.fieldErrors, isEmpty);
    });

    test('reads a validation map and keeps the errors per field', () {
      final model = ErrorModel.fromJson({
        'data': null,
        'message': {
          'email': ['The email has already been taken.'],
          'phone': ['The phone field format is invalid.'],
        },
      });

      expect(model.fieldErrors.keys, equals(['email', 'phone']));
      expect(model.fieldErrors['email'], ['The email has already been taken.']);
      expect(model.fieldErrors['phone'], ['The phone field format is invalid.']);
    });

    test('joins all field messages with a new line', () {
      final model = ErrorModel.fromJson({
        'data': null,
        'message': {
          'name': ['The name field is required.'],
          'email': ['The email field is required.'],
        },
      });

      expect(
        model.message,
        'The name field is required.\nThe email field is required.',
      );
    });

    test('ignores list items that are not strings', () {
      final model = ErrorModel.fromJson({
        'message': {
          'name': [1, 'The name field is required.'],
        },
      });

      expect(model.fieldErrors['name'], ['The name field is required.']);
    });

    test('ignores field entries that are not lists', () {
      final model = ErrorModel.fromJson({
        'message': {'name': 'oops'},
      });

      expect(model.fieldErrors, isEmpty);
      expect(model.message, isNull);
    });

    test('has no message when a field has an empty list', () {
      final model = ErrorModel.fromJson({
        'message': {'name': <String>[]},
      });

      expect(model.message, isNull);
    });

    test('treats an empty string message as no message', () {
      final model = ErrorModel.fromJson({'message': ''});

      expect(model.message, isNull);
    });

    test('returns an empty model when there is no message', () {
      final model = ErrorModel.fromJson({'data': null});

      expect(model.message, isNull);
      expect(model.fieldErrors, isEmpty);
    });

    test('returns an empty model when the message has another type', () {
      final model = ErrorModel.fromJson({'message': 42});

      expect(model.message, isNull);
      expect(model.fieldErrors, isEmpty);
    });

    test('does not crash on an HTML body (405 Method Not Allowed)', () {
      final model = ErrorModel.fromJson(
        '<html><body>405 Method Not Allowed</body></html>',
      );

      expect(model.message, isNull);
      expect(model.fieldErrors, isEmpty);
    });

    test('does not crash on null', () {
      final model = ErrorModel.fromJson(null);

      expect(model.message, isNull);
      expect(model.fieldErrors, isEmpty);
    });
  });
}