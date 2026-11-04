enum RegisterStatus { initial, loading, success, error }

class RegisterState {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.fieldErrors = const {},
    this.errorMessage,
  });

  final RegisterStatus status;
  final Map<String, List<String>> fieldErrors;
  final String? errorMessage;

  bool get isLoading => status == RegisterStatus.loading;

  String? fieldError(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  RegisterState copyWith({
    RegisterStatus? status,
    Map<String, List<String>>? fieldErrors,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: errorMessage,
    );
  }
}
