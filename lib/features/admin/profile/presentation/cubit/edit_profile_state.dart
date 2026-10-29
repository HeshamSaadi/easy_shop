// lib/features/admin/profile/presentation/cubit/edit_profile_state.dart
import 'package:easy_shop/core/location/picked_location.dart';

enum EditProfileStatus { initial, loading, success, error }

class EditProfileState {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.latitude,
    this.longitude,
    this.picturePath,
    this.commercialRegisterPath,
    this.taxCardPath,
    this.fieldErrors = const {},
    this.errorMessage,
  });

  final EditProfileStatus status;
  final double? latitude;
  final double? longitude;

  final String? picturePath;
  final String? commercialRegisterPath;
  final String? taxCardPath;
  final Map<String, List<String>> fieldErrors;
  final String? errorMessage;

  bool get isLoading => status == EditProfileStatus.loading;
  bool get hasLocation => latitude != null && longitude != null;

  PickedLocation? get location {
    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return null;
    return PickedLocation(latitude: lat, longitude: lng);
  }

  String? fieldError(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  EditProfileState copyWith({
    EditProfileStatus? status,
    double? latitude,
    double? longitude,
    String? picturePath,
    String? commercialRegisterPath,
    String? taxCardPath,
    Map<String, List<String>>? fieldErrors,
    String? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      picturePath: picturePath ?? this.picturePath,
      commercialRegisterPath:
          commercialRegisterPath ?? this.commercialRegisterPath,
      taxCardPath: taxCardPath ?? this.taxCardPath,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: errorMessage,
    );
  }
}
