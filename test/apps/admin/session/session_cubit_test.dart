import 'package:dartz/dartz.dart';
import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/apps/admin/session/session_state.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../features/admin/auth/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late SessionEvents sessionEvents;
  late SessionCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    sessionEvents = SessionEvents();
    cubit = SessionCubit(
      restoreSession: RestoreSession(repository),
      logout: LogoutAdmin(repository),
      sessionEvents: sessionEvents,
    );
  });

  tearDown(() async {
    await cubit.close();
    sessionEvents.dispose();
  });

  Future<void> expireSession() async {
    sessionEvents.notifySessionExpired();
    await Future<void>.delayed(Duration.zero);
  }

  test('starts in SessionUnknown', () {
    expect(cubit.state, isA<SessionUnknown>());
  });

  group('restore', () {
    test('emits SessionAuthenticated when the session is valid', () async {
      repository.sessionResult = true;

      await cubit.restore();

      expect(cubit.state, isA<SessionAuthenticated>());
    });

    test(
      'emits SessionUnauthenticated when there is no valid session',
      () async {
        repository.sessionResult = false;

        await cubit.restore();

        expect(
          cubit.state,
          isA<SessionUnauthenticated>().having(
            (s) => s.expired,
            'expired',
            false,
          ),
        );
      },
    );
  });

  test('signedIn emits SessionAuthenticated', () {
    cubit.signedIn();

    expect(cubit.state, isA<SessionAuthenticated>());
  });

  group('session expired event', () {
    test('signs the user out and marks the session as expired', () async {
      cubit.signedIn();

      await expireSession();

      expect(
        cubit.state,
        isA<SessionUnauthenticated>().having((s) => s.expired, 'expired', true),
      );
    });

    test('is ignored while the user is not signed in', () async {
      repository.sessionResult = false;
      await cubit.restore();
      final before = cubit.state;

      await expireSession();

      expect(cubit.state, same(before));
    });

    test('is ignored after the cubit is closed', () async {
      cubit.signedIn();
      await cubit.close();

      await expireSession();

      expect(cubit.state, isA<SessionAuthenticated>());
    });
  });

  group('logout', () {
    test('calls the use case, then emits SessionUnauthenticated', () async {
      cubit.signedIn();

      await cubit.logout();

      expect(repository.logoutCalls, 1);
      expect(
        cubit.state,
        isA<SessionUnauthenticated>().having(
          (s) => s.expired,
          'expired',
          false,
        ),
      );
    });

    test('still signs the user out when the server logout fails', () async {
      repository.logoutResult = const Left(Failure('No internet connection.'));
      cubit.signedIn();

      await cubit.logout();

      expect(cubit.state, isA<SessionUnauthenticated>());
    });
  });
}
