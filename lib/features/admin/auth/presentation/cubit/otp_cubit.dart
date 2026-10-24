import 'dart:async';

import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._verifyOtp, this._resendOtp, {required this.email})
    : super(
        const OtpState(
          secondsLeft: OtpConfig.lifetimeSeconds,
          resendCooldownLeft: OtpConfig.resendCooldownSeconds,
        ),
      ) {
    _startTimer(
      lifetime: OtpConfig.lifetimeSeconds,
      cooldown: OtpConfig.resendCooldownSeconds,
    );
  }

  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;
  final String email;

  Timer? _timer;
  late DateTime _expiresAt;
  late DateTime _cooldownEndsAt;

  Future<void> verify(String code) async {
    if (!state.canVerify) return;

    emit(state.withStatus(OtpStatus.verifying));
    final result = await _verifyOtp(email: email, otpCode: code);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.withStatus(OtpStatus.verifyFailed, message: failure.message),
      ),
      (_) {
        _timer?.cancel();
        emit(state.withStatus(OtpStatus.verified));
      },
    );
  }

  Future<void> resend() async {
    if (!state.canResend) return;

    emit(state.withStatus(OtpStatus.resending));
    final result = await _resendOtp(email: email);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.withStatus(OtpStatus.resendFailed, message: failure.message),
      ),
      (_) {
        _startTimer(
          lifetime: OtpConfig.lifetimeSeconds,
          cooldown: OtpConfig.resendCooldownSeconds,
        );
        emit(
          OtpState(
            status: OtpStatus.resendSuccess,
            secondsLeft: OtpConfig.lifetimeSeconds,
            resendCooldownLeft: OtpConfig.resendCooldownSeconds,
          ),
        );
      },
    );
  }

  void _startTimer({required int lifetime, required int cooldown}) {
    final now = DateTime.now();
    _expiresAt = now.add(Duration(seconds: lifetime));
    _cooldownEndsAt = now.add(Duration(seconds: cooldown));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final secondsLeft = _secondsUntil(_expiresAt, now);
    final cooldownLeft = _secondsUntil(_cooldownEndsAt, now);

    emit(
      state.withTime(
        secondsLeft: secondsLeft,
        resendCooldownLeft: cooldownLeft,
      ),
    );

    if (secondsLeft == 0 && cooldownLeft == 0) _timer?.cancel();
  }

  int _secondsUntil(DateTime end, DateTime now) {
    final ms = end.difference(now).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
