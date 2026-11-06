enum EditProfileStatus { initial, saving, success, error }

class EditProfileState {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.fieldErrors = const {},
    this.errorMessage,
  });

  final EditProfileStatus status;
  final Map<String, List<String>> fieldErrors;
  final String? errorMessage;

  bool get isSaving => status == EditProfileStatus.saving;

  String? fieldError(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  EditProfileState copyWith({
    EditProfileStatus? status,
    Map<String, List<String>>? fieldErrors,
    String? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: errorMessage,
    );
  }
}
