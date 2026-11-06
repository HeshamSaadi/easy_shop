import 'location_permission_status.dart';
import 'picked_location.dart';

/// Contract for permission handling. Screens and Cubits depend on this,
/// never on the geolocator package directly.
abstract class LocationService {
  /// Reads the current status without showing any dialog.
  Future<LocationPermissionStatus> checkPermission();

  /// Asks the user if needed, then returns the resulting status.
  Future<LocationPermissionStatus> requestPermission();

  /// Opens this app's page in the phone settings (for `deniedForever`).
  Future<void> openAppSettings();

  /// Opens the phone's location settings (for `serviceDisabled`).
  Future<void> openLocationSettings();

  /// Current GPS position, or null if it could not be read.
  /// Call this only after the permission is granted.
  Future<PickedLocation?> getCurrentLocation();
}
