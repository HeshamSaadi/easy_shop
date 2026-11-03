import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiConsumer extends Mock implements ApiConsumer {}

const _email = 'admin@shop.com';

void main() {
  late MockApiConsumer api;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    api = MockApiConsumer();
    dataSource = AuthRemoteDataSourceImpl(api);
  });

  void stubPost(dynamic response) {
    when(
      () => api.post(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => response);
  }

  group('login', () {
    test('posts the credentials to the login endpoint', () async {
      stubPost(<String, dynamic>{
        'data': null,
        'message': 'OTP sent to your email and phone',
      });

      await dataSource.login(email: _email, password: '12345678');

      verify(
        () => api.post(
          EndPoints.adminLogin,
          data: {'email': _email, 'password': '12345678'},
        ),
      ).called(1);
    });

    test('lets the exception from the api reach the repository', () async {
      when(
        () => api.post(any(), data: any(named: 'data')),
      ).thenThrow(const UnauthorizedException('Invalid email or password'));

      await expectLater(
        dataSource.login(email: _email, password: 'wrong-password'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('verifyOtp', () {
    test('posts the email and code, and returns the top-level token', () async {
      stubPost(<String, dynamic>{
        'data': <String, dynamic>{'id': 1},
        'message': 'OTP verified successfully',
        'token': 'jwt-token',
      });

      final token = await dataSource.verifyOtp(
        email: _email,
        otpCode: '123456',
      );

      expect(token, 'jwt-token');
      verify(
        () => api.post(
          EndPoints.adminVerifyOtp,
          data: {'email': _email, 'otp_code': '123456'},
        ),
      ).called(1);
    });

    final badResponses = <String, dynamic>{
      'has no token': <String, dynamic>{'data': null, 'message': 'ok'},
      'has an empty token': <String, dynamic>{'token': ''},
      'has a token that is not a string': <String, dynamic>{'token': 123},
      'is not a map': 'not a map',
      'is null': null,
    };
    badResponses.forEach((description, response) {
      test('throws a ServerException when the response $description', () async {
        stubPost(response);

        await expectLater(
          dataSource.verifyOtp(email: _email, otpCode: '123456'),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });

  group('resendOtp', () {
    test('posts the email to the resend endpoint', () async {
      stubPost(<String, dynamic>{'data': null, 'message': 'OTP resent'});

      await dataSource.resendOtp(email: _email);

      verify(
        () => api.post(EndPoints.adminResendOtp, data: {'email': _email}),
      ).called(1);
    });
  });

  group('logout', () {
    test('posts to the logout endpoint without a body', () async {
      when(
        () => api.post(EndPoints.adminLogout),
      ).thenAnswer((_) async => <String, dynamic>{});

      await dataSource.logout();

      verify(() => api.post(EndPoints.adminLogout)).called(1);
    });
  });

  group('register', () {
    Future<FormData> registerAndCaptureForm(RegisterParams params) async {
      stubPost(<String, dynamic>{'data': null, 'message': 'created'});

      await dataSource.register(params);

      final captured = verify(
        () => api.post(EndPoints.adminRegister, data: captureAny(named: 'data')),
      ).captured;
      return captured.single as FormData;
    }

    test('sends every field as form-data', () async {
      final form = await registerAndCaptureForm(
        const RegisterParams(
          name: 'Ahmed Hassan',
          email: 'ahmed@example.com',
          phone: '+201013114901',
          nationalId: '29001011234567',
          businessName: 'Elbatal Store',
          password: '12345678',
          passwordConfirmation: '12345678',
          address: '123 Tahrir Square',
          latitude: 30.0444,
          longitude: 31.2357,
        ),
      );

      expect(Map.fromEntries(form.fields), {
        'name': 'Ahmed Hassan',
        'email': 'ahmed@example.com',
        'phone': '+201013114901',
        'national_id': '29001011234567',
        'business_name': 'Elbatal Store',
        'password': '12345678',
        'password_confirmation': '12345678',
        'address': '123 Tahrir Square',
        'latitude': '30.0444',
        'longitude': '31.2357',
      });
      expect(form.files, isEmpty);
    });

    test('leaves out the optional fields that were not given', () async {
      final form = await registerAndCaptureForm(
        const RegisterParams(
          name: 'Ahmed Hassan',
          email: 'ahmed@example.com',
          phone: '+201013114901',
          nationalId: '29001011234567',
          businessName: 'Elbatal Store',
          password: '12345678',
          passwordConfirmation: '12345678',
        ),
      );

      final keys = form.fields.map((entry) => entry.key).toList();
      for (final optional in ['address', 'latitude', 'longitude']) {
        expect(keys, isNot(contains(optional)), reason: optional);
      }
      expect(form.files, isEmpty);
    });
  });
}
