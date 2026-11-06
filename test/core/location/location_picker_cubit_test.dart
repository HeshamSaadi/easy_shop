import 'package:easy_shop/core/location/address_resolver.dart';
import 'package:easy_shop/core/location/location_permission_status.dart';
import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_state.dart';
import 'package:easy_shop/core/location/location_service.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.status = LocationPermissionStatus.granted,
    this.current,
  });

  final LocationPermissionStatus status;
  final PickedLocation? current;
  int permissionRequests = 0;

  @override
  Future<LocationPermissionStatus> checkPermission() async => status;

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    permissionRequests++;
    return status;
  }

  @override
  Future<PickedLocation?> getCurrentLocation() async => current;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

class FakeAddressResolver implements AddressResolver {
  FakeAddressResolver({this.address});

  final String? address;

  @override
  Future<String?> resolve({
    required double latitude,
    required double longitude,
  }) async => address;
}

void main() {
  const point = PickedLocation(latitude: 1.5, longitude: 2.5);

  LocationPickerCubit buildCubit({
    FakeLocationService? service,
    FakeAddressResolver? resolver,
    PickedLocation? initial,
  }) {
    return LocationPickerCubit(
      locationService: service ?? FakeLocationService(current: point),
      addressResolver: resolver ?? FakeAddressResolver(),
      initialLocation: initial,
      addressDebounce: const Duration(milliseconds: 10),
    );
  }

  test('granted permission opens the map at the current location', () async {
    final cubit = buildCubit();
    await cubit.start();

    final state = cubit.state;
    expect(state, isA<LocationPickerReady>());
    expect((state as LocationPickerReady).location.latitude, 1.5);
    await cubit.close();
  });

  test('deniedForever shows the permission message, no map', () async {
    final cubit = buildCubit(
      service: FakeLocationService(
        status: LocationPermissionStatus.deniedForever,
      ),
    );
    await cubit.start();

    final state = cubit.state;
    expect(state, isA<LocationPickerPermissionRequired>());
    expect(
      (state as LocationPickerPermissionRequired).status,
      LocationPermissionStatus.deniedForever,
    );
    await cubit.close();
  });

  test('unreadable GPS position gives an error state', () async {
    final cubit = buildCubit(service: FakeLocationService());
    await cubit.start();

    expect(cubit.state, isA<LocationPickerError>());
    await cubit.close();
  });

  test(
    'a saved location opens the map without asking for permission',
    () async {
      final service = FakeLocationService(
        status: LocationPermissionStatus.denied,
      );
      final cubit = buildCubit(service: service, initial: point);
      await cubit.start();

      expect(cubit.state, isA<LocationPickerReady>());
      expect(service.permissionRequests, 0);
      await cubit.close();
    },
  );

  test('moving the map resolves the address after the debounce', () async {
    final cubit = buildCubit(
      resolver: FakeAddressResolver(address: 'Some street'),
      initial: point,
    );
    await cubit.start();

    cubit.onMapMoved(latitude: 3, longitude: 4);
    expect((cubit.state as LocationPickerReady).isResolvingAddress, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    final ready = cubit.state as LocationPickerReady;
    expect(ready.isResolvingAddress, isFalse);
    expect(ready.location.address, 'Some street');
    expect(ready.location.latitude, 3);
    await cubit.close();
  });
}
