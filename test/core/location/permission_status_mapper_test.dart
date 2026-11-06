import 'package:easy_shop/core/location/location_permission_status.dart';
import 'package:easy_shop/core/location/permission_status_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  LocationPermissionStatus map(
    LocationPermission permission, {
    bool serviceEnabled = true,
  }) {
    return mapPermissionStatus(
      serviceEnabled: serviceEnabled,
      permission: permission,
    );
  }

  test('service off wins over any permission', () {
    expect(
      map(LocationPermission.always, serviceEnabled: false),
      LocationPermissionStatus.serviceDisabled,
    );
  });

  test('whileInUse and always are granted', () {
    expect(
      map(LocationPermission.whileInUse),
      LocationPermissionStatus.granted,
    );
    expect(map(LocationPermission.always), LocationPermissionStatus.granted);
  });

  test('denied and unableToDetermine are denied', () {
    expect(map(LocationPermission.denied), LocationPermissionStatus.denied);
    expect(
      map(LocationPermission.unableToDetermine),
      LocationPermissionStatus.denied,
    );
  });

  test('deniedForever is its own status', () {
    expect(
      map(LocationPermission.deniedForever),
      LocationPermissionStatus.deniedForever,
    );
  });
}
