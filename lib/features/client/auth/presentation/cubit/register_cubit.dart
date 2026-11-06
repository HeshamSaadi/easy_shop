import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/utils/phone_utils.dart';
import 'package:easy_shop/features/client/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/register_client.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required this._registerClient}) : super(const RegisterState());

  final RegisterClient _registerClient;

  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field)) return;
    final updated = Map<String, List<String>>.of(state.fieldErrors)
      ..remove(field);
    emit(state.copyWith(fieldErrors: updated));
  }

  /// Called before a new submit, so an old server error cannot block validation.
  void clearFieldErrors() {
    if (state.fieldErrors.isEmpty) return;
    emit(state.copyWith(fieldErrors: const {}));
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: RegisterStatus.loading, fieldErrors: const {}));

    final params = RegisterParams(
      name: name.trim(),
      email: email.trim(),
      phone: PhoneUtils.toInternational(phone),
      password: password,
      passwordConfirmation: passwordConfirmation,
      address: _nullIfBlank(address),
      latitude: latitude,
      longitude: longitude,
    );

    final result = await _registerClient(params);
    if (isClosed) return;

    result.fold(
      (failure) => emit(_errorState(failure)),
      (_) => emit(state.copyWith(status: RegisterStatus.success)),
    );
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  RegisterState _errorState(Failure failure) {
    return state.copyWith(
      status: RegisterStatus.error,
      fieldErrors: failure.fieldErrors,
      errorMessage: failure.message,
    );
  }
}
