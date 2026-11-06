import 'location_permission_status.dart';
import 'picked_location.dart';

sealed class LocationPickerState {
  const LocationPickerState();
}

/// Reading permission and GPS.
class LocationPickerLoading extends LocationPickerState {
  const LocationPickerLoading();
}

/// No map is shown. The screen explains why and offers the right action.
class LocationPickerPermissionRequired extends LocationPickerState {
  const LocationPickerPermissionRequired(this.status);

  final LocationPermissionStatus status;
}

/// The map is shown with the pin at [location].
class LocationPickerReady extends LocationPickerState {
  const LocationPickerReady({
    required this.location,
    this.isResolvingAddress = false,
  });

  final PickedLocation location;
  final bool isResolvingAddress;

  LocationPickerReady copyWith({
    PickedLocation? location,
    bool? isResolvingAddress,
  }) {
    return LocationPickerReady(
      location: location ?? this.location,
      isResolvingAddress: isResolvingAddress ?? this.isResolvingAddress,
    );
  }
}

class LocationPickerError extends LocationPickerState {
  const LocationPickerError(this.message);

  final String message;
}
