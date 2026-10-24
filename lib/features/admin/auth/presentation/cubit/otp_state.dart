enum OtpStatus {
  idle,
  verifying,
  resending,
  verified,
  resendSuccess,
  verifyFailed,
  resendFailed,
}

abstract final class OtpConfig {
  static const lifetimeSeconds = 600;
  static const resendCooldownSeconds = 30;
  static const codeLength = 6;
}

class OtpState {
  const OtpState({
    required this.secondsLeft,
    required this.resendCooldownLeft,
    this.status = OtpStatus.idle,
    this.message,
  });

  final OtpStatus status;
  final int secondsLeft;
  final int resendCooldownLeft;
  final String? message;

  bool get isBusy =>
      status == OtpStatus.verifying || status == OtpStatus.resending;
  bool get isExpired => secondsLeft == 0;
  bool get canVerify => !isBusy && !isExpired;
  bool get canResend => !isBusy && resendCooldownLeft == 0;

  OtpState withTime({int? secondsLeft, int? resendCooldownLeft}) {
    return OtpState(
      status: status,
      message: message,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      resendCooldownLeft: resendCooldownLeft ?? this.resendCooldownLeft,
    );
  }

  OtpState withStatus(OtpStatus status, {String? message}) {
    return OtpState(
      status: status,
      message: message,
      secondsLeft: secondsLeft,
      resendCooldownLeft: resendCooldownLeft,
    );
  }
}
