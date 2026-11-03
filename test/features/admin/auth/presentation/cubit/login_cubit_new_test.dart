import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginAdmin extends Mock implements LoginAdmin {}

const _email = 'admin@shop.com';
const _password = '12345678';

const _success = Right<Failure, Unit>(unit);
const _failure = Failure('Invalid email or password', statusCode: 401);
const _failed = Left<Failure, Unit>(_failure);

void main() {
  late MockLoginAdmin loginAdmin;

  setUp(() {
    loginAdmin = MockLoginAdmin();
  });

  When<Future<Either<Failure, Unit>>> whenLogin() => when(
    () => loginAdmin(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  );

  LoginCubit buildCubit() => LoginCubit(loginAdmin: loginAdmin);

  test('starts in the initial state', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state, isA<LoginInitial>());
  });

  blocTest<LoginCubit, LoginState>(
    'emits loading then success with the email when the login works',
    setUp: () => whenLogin().thenAnswer((_) async => _success),
    build: buildCubit,
    act: (cubit) => cubit.login(email: _email, password: _password),
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginSuccess>().having((state) => state.email, 'email', _email),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'trims the email before sending it and before putting it in the state',
    setUp: () => whenLogin().thenAnswer((_) async => _success),
    build: buildCubit,
    act: (cubit) => cubit.login(email: '  $_email  ', password: _password),
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginSuccess>().having((state) => state.email, 'email', _email),
    ],
    verify: (_) {
      verify(() => loginAdmin(email: _email, password: _password)).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'sends the password exactly as typed',
    setUp: () => whenLogin().thenAnswer((_) async => _success),
    build: buildCubit,
    act: (cubit) => cubit.login(email: _email, password: ' pass 123 '),
    verify: (_) {
      verify(() => loginAdmin(email: _email, password: ' pass 123 ')).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'emits loading then failure with the message when the login fails',
    setUp: () => whenLogin().thenAnswer((_) async => _failed),
    build: buildCubit,
    act: (cubit) => cubit.login(email: _email, password: 'wrong-password'),
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginFailure>().having(
        (state) => state.message,
        'message',
        'Invalid email or password',
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'can try again after a failure',
    setUp: () {
      var calls = 0;
      whenLogin().thenAnswer((_) async => ++calls == 1 ? _failed : _success);
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.login(email: _email, password: 'wrong-password');
      await cubit.login(email: _email, password: _password);
    },
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginFailure>(),
      isA<LoginLoading>(),
      isA<LoginSuccess>(),
    ],
  );

  group('double submit', () {
    late Completer<Either<Failure, Unit>> pending;

    blocTest<LoginCubit, LoginState>(
      'ignores a second login while the first one is still running',
      setUp: () {
        pending = Completer<Either<Failure, Unit>>();
        whenLogin().thenAnswer((_) => pending.future);
      },
      build: buildCubit,
      act: (cubit) async {
        final first = cubit.login(email: _email, password: _password);
        await cubit.login(email: _email, password: _password);
        pending.complete(_success);
        await first;
      },
      expect: () => [isA<LoginLoading>(), isA<LoginSuccess>()],
      verify: (_) {
        verify(() => loginAdmin(email: _email, password: _password)).called(1);
      },
    );
  });

  group('closed cubit', () {
    late Completer<Either<Failure, Unit>> pending;

    blocTest<LoginCubit, LoginState>(
      'does not emit when the answer arrives after the cubit is closed',
      setUp: () {
        pending = Completer<Either<Failure, Unit>>();
        whenLogin().thenAnswer((_) => pending.future);
      },
      build: buildCubit,
      act: (cubit) async {
        final running = cubit.login(email: _email, password: _password);
        await cubit.close();
        pending.complete(_success);
        await running;
      },
      expect: () => [isA<LoginLoading>()],
    );
  });
}