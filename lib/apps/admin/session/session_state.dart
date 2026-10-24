sealed class SessionState {
  const SessionState();
}

class SessionUnknown extends SessionState {
  const SessionUnknown();
}

class SessionAuthenticated extends SessionState {
  const SessionAuthenticated();
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated({this.expired = false});
  final bool expired;
}
