import 'dart:async';

import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this._restoreSession,
    required this._logout,
    required SessionEvents sessionEvents,
  }) : super(const SessionUnknown()) {
    _expiredSub = sessionEvents.onSessionExpired.listen((_) => _onExpired());
  }

  final RestoreSession _restoreSession;
  final LogoutAdmin _logout;
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
    emit(const SessionUnauthenticated());
  }

  @override
  Future<void> close() {
    _expiredSub.cancel();
    return super.close();
  }
}
