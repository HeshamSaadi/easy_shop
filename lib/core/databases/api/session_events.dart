import 'dart:async';

class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _controller.stream;

  void notifySessionExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
