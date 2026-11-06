import 'dart:async';

class SessionEvents {
  final _controller = StreamController<void>.broadcast();
  bool _expiredNotified = false;

  Stream<void> get onSessionExpired => _controller.stream;

  void notifySessionExpired() {
    if (_controller.isClosed || _expiredNotified) return;
    _expiredNotified = true;
    _controller.add(null);
  }

  void reset() => _expiredNotified = false;

  void dispose() => _controller.close();
}
