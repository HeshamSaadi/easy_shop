import 'package:geolocator/geolocator.dart';

import 'location_permission_status.dart';

/// Turns geolocator's raw values into our four statuses.
/// A plain function, so it is easy to unit test.
LocationPermissionStatus mapPermissionStatus({
  required bool serviceEnabled,
  required LocationPermission permission,
}) {
  if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

  switch (permission) {
    case LocationPermission.whileInUse:
    case LocationPermission.always:
      return LocationPermissionStatus.granted;
    case LocationPermission.deniedForever:
      return LocationPermissionStatus.deniedForever;
    case LocationPermission.denied:
    case LocationPermission.unableToDetermine:
      return LocationPermissionStatus.denied;
  }
}
