enum OtpStatus {
  idle,
  verifying,
  verified,
  verifyFailed,
  resending,
  resent,
  resendFailed,
}

class OtpState {
  const OtpState({
    required this.remaining,
    this.status = OtpStatus.idle,
    this.message,
  });

  /// Time left before the code expires.
  final Duration remaining;
  final OtpStatus status;

  /// Error text for [OtpStatus.verifyFailed] and [OtpStatus.resendFailed].
  final String? message;

  bool get isExpired => remaining <= Duration.zero;

  bool get isBusy =>
      status == OtpStatus.verifying || status == OtpStatus.resending;

  /// The message belongs to a status, so it is cleared unless given again.
  OtpState copyWith({Duration? remaining, OtpStatus? status, String? message}) {
    return OtpState(
      remaining: remaining ?? this.remaining,
      status: status ?? this.status,
      message: message,
    );
  }
}
