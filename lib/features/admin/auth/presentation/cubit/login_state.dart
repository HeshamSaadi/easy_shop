//lib/features/admin/auth/presentation/cubit/login_state.dart
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

/// The server sent an OTP to [email]. The next screen needs it.
class LoginSuccess extends LoginState {
  const LoginSuccess(this.email);

  final String email;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;
}
