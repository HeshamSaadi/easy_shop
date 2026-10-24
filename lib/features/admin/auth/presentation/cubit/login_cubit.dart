import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginAdmin) : super(const LoginInitial());

  final LoginAdmin _loginAdmin;

  Future<void> login({required String email, required String password}) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    final cleanEmail = email.trim();

    final result = await _loginAdmin(email: cleanEmail, password: password);

    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (_) => emit(LoginSuccess(cleanEmail)),
    );
  }
}
