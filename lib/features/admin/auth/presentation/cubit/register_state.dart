import 'package:easy_shop/features/admin/auth/presentation/cubit/register_draft.dart';

enum RegisterStep { personal, business, security }

enum RegisterStatus { initial, loading, success, error }

class RegisterState {
  const RegisterState({
    this.step = RegisterStep.personal,
    this.status = RegisterStatus.initial,
    this.draft = const RegisterDraft(),
    this.fieldErrors = const {},
    this.errorMessage,
  });

  final RegisterStep step;
  final RegisterStatus status;
  final RegisterDraft draft;
  final Map<String, List<String>> fieldErrors;
  final String? errorMessage;

  bool get isLoading => status == RegisterStatus.loading;

  String? fieldError(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  RegisterState copyWith({
    RegisterStep? step,
    RegisterStatus? status,
    RegisterDraft? draft,
    Map<String, List<String>>? fieldErrors,
    String? errorMessage,
  }) {
    return RegisterState(
      step: step ?? this.step,
      status: status ?? this.status,
      draft: draft ?? this.draft,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: errorMessage,
    );
  }
}
