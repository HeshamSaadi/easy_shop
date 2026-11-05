import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/get_profile.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_profile_repository.dart';

void main() {
  late FakeProfileRepository repository;
  late ProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = ProfileCubit(GetProfile(repository));
  });

  tearDown(() => cubit.close());

  test('starts in ProfileLoading', () {
    expect(cubit.state, isA<ProfileLoading>());
  });

  test('load emits ProfileLoaded with the profile', () async {
    final expectation = expectLater(
      cubit.stream,
      emits(
        isA<ProfileLoaded>().having(
          (s) => s.profile,
          'profile',
          same(testProfile),
        ),
      ),
    );

    await cubit.load();
    await expectation;
    expect(repository.getCalls, 1);
  });

  test('load emits ProfileError with the failure message', () async {
    repository.profileResult = const Left(Failure('No internet connection.'));

    final expectation = expectLater(
      cubit.stream,
      emits(
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          'No internet connection.',
        ),
      ),
    );

    await cubit.load();
    await expectation;
  });

  test('retry after an error emits Loading, then Loaded', () async {
    repository.profileResult = const Left(Failure('Server error.'));
    await cubit.load();
    expect(cubit.state, isA<ProfileError>());

    repository.profileResult = const Right(testProfile);
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<ProfileLoading>(), isA<ProfileLoaded>()]),
    );

    await cubit.load();
    await expectation;
    expect(repository.getCalls, 2);
  });

  test(
    'does not emit when the answer arrives after the cubit is closed',
    () async {
      final gate = Completer<void>();
      repository.getGate = gate;
      final states = <ProfileState>[];
      cubit.stream.listen(states.add);

      final running = cubit.load();
      await cubit.close();
      gate.complete();
      await running;

      expect(states, isEmpty);
    },
  );
}
