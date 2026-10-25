import 'dart:async';

import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.email,
    required this._verifyOtp,
    required this._resendOtp,
    this._tickInterval = const Duration(seconds: 1),
  }) : super(const OtpState(remaining: validity));

  /// The OTP is valid for 10 minutes (see the project brief).
  static const Duration validity = Duration(minutes: 10);

  static const Duration _step = Duration(seconds: 1);

  final String email;
  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;
  final Duration _tickInterval;

  Timer? _timer;

  void start() => _startCountdown();

  Future<void> verify(String code) async {
    // No double submit, and no point sending an expired code.
    if (state.isBusy || state.isExpired) return;

    emit(state.copyWith(status: OtpStatus.verifying));
    final result = await _verifyOtp(email: email, otpCode: code);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OtpStatus.verifyFailed,
          message: failure.message,
        ),
      ),
      (_) {
        _timer?.cancel();
        emit(state.copyWith(status: OtpStatus.verified));
      },
    );
  }

  Future<void> resend() async {
    if (state.isBusy) return;

    emit(state.copyWith(status: OtpStatus.resending));
    final result = await _resendOtp(email: email);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OtpStatus.resendFailed,
          message: failure.message,
        ),
      ),
      (_) {
        _startCountdown();
        emit(state.copyWith(status: OtpStatus.resent, remaining: validity));
      },
    );
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickInterval, _onTick);
  }

  void _onTick(Timer timer) {
    final next = state.remaining - _step;
    if (next <= Duration.zero) {
      timer.cancel();
      emit(state.copyWith(remaining: Duration.zero));
      return;
    }
    emit(state.copyWith(remaining: next));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
