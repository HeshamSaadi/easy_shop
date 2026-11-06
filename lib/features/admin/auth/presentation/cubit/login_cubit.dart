import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this._loginAdmin}) : super(const LoginInitial());

  final LoginAdmin _loginAdmin;

  Future<void> login({required String email, required String password}) async {
    // No double submit.
    if (state is LoginLoading) return;

    final cleanEmail = email.trim();
    emit(const LoginLoading());

    final result = await _loginAdmin(email: cleanEmail, password: password);
    if (isClosed) return;

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginSuccess(cleanEmail)),
    );
  }
}
