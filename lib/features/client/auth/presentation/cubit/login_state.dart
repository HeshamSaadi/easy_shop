sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.email);

  final String email;
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;
}
