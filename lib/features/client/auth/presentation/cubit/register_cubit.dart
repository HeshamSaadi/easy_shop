import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/register_client.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required RegisterClient registerClient})
    : _registerClient = registerClient,
      super(const RegisterState());

  final RegisterClient _registerClient;

  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field)) return;
    final updated = Map<String, List<String>>.of(state.fieldErrors)
      ..remove(field);
    emit(state.copyWith(fieldErrors: updated));
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? picturePath,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: RegisterStatus.loading, fieldErrors: const {}));

    final params = RegisterParams(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password,
      passwordConfirmation: passwordConfirmation,
      picturePath: picturePath,
    );

    final result = await _registerClient(params);
    if (isClosed) return;

    result.fold(
      (failure) => emit(_errorState(failure)),
      (email) => emit(state.copyWith(status: RegisterStatus.success)),
    );
  }

  RegisterState _errorState(Failure failure) {
    return state.copyWith(
      status: RegisterStatus.error,
      fieldErrors: failure.fieldErrors,
      errorMessage: failure.message,
    );
  }
}
