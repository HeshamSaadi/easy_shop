import 'dart:async';

import 'package:easy_shop/apps/client/session/session_state.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/logout_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/restore_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required RestoreSession restoreSession,
    required LogoutClient logout,
    required SessionEvents sessionEvents,
  }) : _restoreSession = restoreSession, // ignore: prefer_initializing_formals
       _logout = logout, // ignore: prefer_initializing_formals
       super(const SessionUnknown()) {
    _expiredSub = sessionEvents.onSessionExpired.listen((_) => _onExpired());
  }

  final RestoreSession _restoreSession;
  final LogoutClient _logout;
  late final StreamSubscription<void> _expiredSub;

  Future<void> restore() async {
    final valid = await _restoreSession();
    if (isClosed) return;
    emit(valid ? const SessionAuthenticated() : const SessionUnauthenticated());
  }

  void signedIn() => emit(const SessionAuthenticated());

  void _onExpired() {
    if (state is SessionAuthenticated) {
      emit(const SessionUnauthenticated(expired: true));
    }
  }

  Future<void> logout() async {
    await _logout();
    if (isClosed) return;
    emit(const SessionUnauthenticated());
  }

  @override
  Future<void> close() {
    _expiredSub.cancel();
    return super.close();
  }
}
