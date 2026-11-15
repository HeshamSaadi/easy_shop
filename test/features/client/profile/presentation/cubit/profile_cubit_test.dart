import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_client_profile_repository.dart';
import '../../gated_client_profile_repository.dart';

void main() {
  late GatedClientProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = GatedClientProfileRepository();
    cubit = ProfileCubit(getClientProfile: GetClientProfile(repository));
  });

  tearDown(() => cubit.close());

  test('starts in the initial state', () {
    expect(cubit.state, isA<ProfileInitial>());
  });

  test('success emits loading, then loaded with the client', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having(
          (s) => s.client.name,
          'name',
          buildClient().name,
        ),
      ]),
    );

    await cubit.loadProfile();
    await expectation;
  });

  test('failure emits loading, then error with the message', () async {
    repository.profileResult = const Left(Failure('No internet connection.'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<ProfileLoading>(),
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          'No internet connection.',
        ),
      ]),
    );

    await cubit.loadProfile();
    await expectation;
  });

  test('can load again after an error', () async {
    repository.profileResult = const Left(Failure('Server error.'));
    await cubit.loadProfile();
    expect(cubit.state, isA<ProfileError>());

    repository.profileResult = Right(buildClient());
    await cubit.loadProfile();

    expect(cubit.state, isA<ProfileLoaded>());
    expect(repository.getCalls, 2);
  });

  test('ignores a second load while the first is running', () async {
    final gate = Completer<void>();
    repository.getGate = gate;

    final first = cubit.loadProfile();
    await cubit.loadProfile();
    gate.complete();
    await first;

    expect(repository.getCalls, 1);
  });
}
