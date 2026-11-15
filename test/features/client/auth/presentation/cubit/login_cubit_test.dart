import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/login_client.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../gated_client_auth_repository.dart';

void main() {
  late GatedClientAuthRepository repository;
  late LoginCubit cubit;

  setUp(() {
    repository = GatedClientAuthRepository();
    cubit = LoginCubit(loginClient: LoginClient(repository));
  });

  tearDown(() => cubit.close());

  test('starts in the initial state', () {
    expect(cubit.state, isA<LoginInitial>());
  });

  test('success emits loading, then success with the trimmed email', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<LoginLoading>(),
        isA<LoginSuccess>().having((s) => s.email, 'email', 'client@shop.com'),
      ]),
    );

    await cubit.login(email: '  client@shop.com ', password: '12345678');
    await expectation;
  });

  test('sends the trimmed email and the password as typed', () async {
    await cubit.login(email: ' client@shop.com ', password: ' 123 456 ');

    expect(repository.loginArgs, [
      (email: 'client@shop.com', password: ' 123 456 '),
    ]);
  });

  test('failure emits loading, then failure with the server message', () async {
    repository.loginResult = const Left(
      Failure('Invalid email or password', statusCode: 401),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<LoginLoading>(),
        isA<LoginFailure>().having(
          (s) => s.message,
          'message',
          'Invalid email or password',
        ),
      ]),
    );

    await cubit.login(email: 'client@shop.com', password: 'wrong');
    await expectation;
  });

  test('can try again after a failure', () async {
    repository.loginResult = const Left(Failure('Invalid email or password'));
    await cubit.login(email: 'client@shop.com', password: 'wrong');
    expect(cubit.state, isA<LoginFailure>());

    repository.loginResult = const Right(unit);
    await cubit.login(email: 'client@shop.com', password: '12345678');

    expect(cubit.state, isA<LoginSuccess>());
    expect(repository.loginArgs, hasLength(2));
  });

  test('ignores a second login while the first is running', () async {
    final gate = Completer<void>();
    repository.loginGate = gate;

    final first = cubit.login(email: 'client@shop.com', password: '12345678');
    await cubit.login(email: 'client@shop.com', password: '12345678');
    gate.complete();
    await first;

    expect(repository.loginArgs, hasLength(1));
  });
}
