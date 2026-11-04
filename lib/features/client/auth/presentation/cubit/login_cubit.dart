import 'package:easy_shop/features/client/auth/domain/usecases/login_client.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginClient loginClient})
    : _loginClient = loginClient,
      super(const LoginInitial());

  final LoginClient _loginClient;

  Future<void> login({required String email, required String password}) async {
    // No double submit.
    if (state is LoginLoading) return;

    final cleanEmail = email.trim();
    emit(const LoginLoading());

    final result = await _loginClient(email: cleanEmail, password: password);
    if (isClosed) return;

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginSuccess(cleanEmail)),
    );
  }
}
