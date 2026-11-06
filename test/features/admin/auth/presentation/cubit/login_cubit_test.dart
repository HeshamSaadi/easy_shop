import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = LoginCubit(loginAdmin: LoginAdmin(repository));
  });

  tearDown(() => cubit.close());

  test('starts in LoginInitial', () {
    expect(cubit.state, isA<LoginInitial>());
  });

  test('emits Loading then Success with the trimmed email', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<LoginLoading>(),
        isA<LoginSuccess>().having((s) => s.email, 'email', 'a@b.com'),
      ]),
    );

    await cubit.login(email: '  a@b.com ', password: 'secret');
    await expectation;
  });

  test('emits Loading then Failure with the server message', () async {
    repository.loginResult = const Left(Failure('Invalid email or password'));

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

    await cubit.login(email: 'a@b.com', password: 'wrong');
    await expectation;
  });

  test('ignores a second login while the first one is loading', () async {
    final gate = Completer<void>();
    repository.loginGate = gate;

    final first = cubit.login(email: 'a@b.com', password: 'secret');
    await cubit.login(email: 'a@b.com', password: 'secret');
    gate.complete();
    await first;

    expect(repository.loginCalls, 1);
  });

  test('sends the trimmed email and the password exactly as typed', () async {
    await cubit.login(email: '  a@b.com ', password: ' pass 123 ');

    expect(repository.loginArgs, [(email: 'a@b.com', password: ' pass 123 ')]);
  });

  test('can try again after a failure', () async {
    repository.loginResult = const Left(Failure('Invalid email or password'));
    await cubit.login(email: 'a@b.com', password: 'wrong');

    repository.loginResult = const Right(unit);
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<LoginLoading>(), isA<LoginSuccess>()]),
    );

    await cubit.login(email: 'a@b.com', password: 'secret');
    await expectation;
    expect(repository.loginCalls, 2);
  });

  test(
    'does not emit when the answer arrives after the cubit is closed',
    () async {
      final gate = Completer<void>();
      repository.loginGate = gate;
      final states = <LoginState>[];
      cubit.stream.listen(states.add);

      final running = cubit.login(email: 'a@b.com', password: 'secret');
      await cubit.close();
      gate.complete();
      await running;

      expect(states.whereType<LoginSuccess>(), isEmpty);
      expect(states.whereType<LoginFailure>(), isEmpty);
    },
  );
}
