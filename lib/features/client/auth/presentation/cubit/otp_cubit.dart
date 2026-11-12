import 'dart:async';

import 'package:easy_shop/features/client/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.email,
    required this._verifyOtp,
    required this._resendOtp,
    this.tickInterval = const Duration(seconds: 1),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(const OtpState(remaining: validity));

  static const Duration validity = Duration(minutes: 10);

  final String email;
  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;
  final Duration tickInterval;
  final DateTime Function() _now;

  Timer? _timer;
  late DateTime _expiresAt;

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
    _expiresAt = _now().add(validity);
    _timer = Timer.periodic(tickInterval, (_) => _onTick());
  }

  void _onTick() {
    final left = _expiresAt.difference(_now());
    if (left <= Duration.zero) {
      _timer?.cancel();
      emit(state.copyWith(remaining: Duration.zero));
      return;
    }
    emit(state.copyWith(remaining: left));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}