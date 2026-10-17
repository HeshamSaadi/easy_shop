import 'package:geolocator/geolocator.dart';

import 'location_permission_status.dart';
import 'location_service.dart';
import 'permission_status_mapper.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    return mapPermissionStatus(
      serviceEnabled: serviceEnabled,
      permission: permission,
    );
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return mapPermissionStatus(
      serviceEnabled: serviceEnabled,
      permission: permission,
    );
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
