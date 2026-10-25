import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/register_admin.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_fields.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerAdmin) : super(const RegisterState());

  final RegisterAdmin _registerAdmin;

  void savePersonal({
    required String name,
    required String email,
    required String phone,
    required String nationalId,
  }) {
    emit(
      state.copyWith(
        step: RegisterStep.business,
        draft: state.draft.copyWith(
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          nationalId: nationalId.trim(),
        ),
      ),
    );
  }

  void saveBusiness({required String businessName, required String address}) {
    emit(
      state.copyWith(
        step: RegisterStep.security,
        draft: state.draft.copyWith(
          businessName: businessName.trim(),
          address: address.trim(),
        ),
      ),
    );
  }

  void setLocation({required double latitude, required double longitude}) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(latitude: latitude, longitude: longitude),
        fieldErrors: _errorsWithout([
          RegisterFields.latitude,
          RegisterFields.longitude,
        ]),
      ),
    );
  }

  void setCommercialRegister(String path) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(commercialRegisterPath: path),
        fieldErrors: _errorsWithout([RegisterFields.commercialRegister]),
      ),
    );
  }

  void setTaxCard(String path) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(taxCardPath: path),
        fieldErrors: _errorsWithout([RegisterFields.taxCard]),
      ),
    );
  }

  void setPicture(String path) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(picturePath: path),
        fieldErrors: _errorsWithout([RegisterFields.picture]),
      ),
    );
  }

  void goBack() {
    if (state.isLoading || state.step.index == 0) return;
    emit(state.copyWith(step: RegisterStep.values[state.step.index - 1]));
  }

  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(state.copyWith(fieldErrors: _errorsWithout([field])));
  }

  Map<String, List<String>> _errorsWithout(List<String> fields) {
    return Map<String, List<String>>.of(state.fieldErrors)
      ..removeWhere((field, _) => fields.contains(field));
  }

  Future<void> submit({
    required String password,
    required String passwordConfirmation,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: RegisterStatus.loading, fieldErrors: const {}));

    final result = await _registerAdmin(
      state.draft.toParams(
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(_errorState(failure)),
      (_) => emit(state.copyWith(status: RegisterStatus.success)),
    );
  }

  RegisterState _errorState(Failure failure) {
    return state.copyWith(
      status: RegisterStatus.error,
      step: _firstStepWithErrors(failure.fieldErrors),
      fieldErrors: failure.fieldErrors,
      errorMessage: failure.message,
    );
  }

  RegisterStep? _firstStepWithErrors(Map<String, List<String>> errors) {
    final steps = errors.keys
        .map((field) => RegisterFields.stepOf[field])
        .whereType<RegisterStep>();
    if (steps.isEmpty) return null;
    return steps.reduce((a, b) => a.index <= b.index ? a : b);
  }
}
