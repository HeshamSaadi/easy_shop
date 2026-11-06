import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'address_resolver.dart';
import 'location_messages.dart';
import 'location_permission_status.dart';
import 'location_picker_state.dart';
import 'location_service.dart';
import 'picked_location.dart';

class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit({
    required this._locationService,
    required this._addressResolver,
    this.initialLocation,
    this._addressDebounce = defaultAddressDebounce,
  }) : super(const LocationPickerLoading());

  static const defaultAddressDebounce = Duration(milliseconds: 600);

  final LocationService _locationService;
  final AddressResolver _addressResolver;
  final Duration _addressDebounce;

  /// A location already saved (profile, order). When set, the map opens there.
  final PickedLocation? initialLocation;

  Timer? _addressTimer;

  Future<void> start() async {
    final saved = initialLocation;
    if (saved != null) {
      _showReady(saved);
      return;
    }

    if (state is! LocationPickerLoading) emit(const LocationPickerLoading());

    final status = await _locationService.requestPermission();
    if (isClosed) return;
    if (status != LocationPermissionStatus.granted) {
      emit(LocationPickerPermissionRequired(status));
      return;
    }

    final current = await _locationService.getCurrentLocation();
    if (isClosed) return;
    if (current == null) {
      emit(const LocationPickerError(LocationMessages.cannotReadLocation));
      return;
    }
    _showReady(current);
  }

  /// The button on the "permission required" message.
  Future<void> onPermissionAction() async {
    final current = state;
    if (current is! LocationPickerPermissionRequired) return;

    switch (current.status) {
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.granted:
        await start();
      case LocationPermissionStatus.deniedForever:
        await _locationService.openAppSettings();
      case LocationPermissionStatus.serviceDisabled:
        await _locationService.openLocationSettings();
    }
  }

  /// Called while the user moves the map under the fixed pin.
  void onMapMoved({required double latitude, required double longitude}) {
    final current = state;
    if (current is! LocationPickerReady) return;

    final target = current.location.moveTo(
      latitude: latitude,
      longitude: longitude,
    );
    if (target.isSamePoint(current.location)) return;

    emit(current.copyWith(location: target, isResolvingAddress: true));

    // Wait until the map stops moving before asking for an address.
    _addressTimer?.cancel();
    _addressTimer = Timer(
      _addressDebounce,
      () => unawaited(_resolveAddress(target)),
    );
  }

  void _showReady(PickedLocation location) {
    emit(LocationPickerReady(location: location, isResolvingAddress: true));
    unawaited(_resolveAddress(location));
  }

  Future<void> _resolveAddress(PickedLocation target) async {
    final address = await _addressResolver.resolve(
      latitude: target.latitude,
      longitude: target.longitude,
    );
    if (isClosed) return;

    final current = state;
    // The user may have moved the map while we were waiting.
    if (current is! LocationPickerReady ||
        !current.location.isSamePoint(target)) {
      return;
    }
    emit(
      current.copyWith(
        location: current.location.withAddress(address),
        isResolvingAddress: false,
      ),
    );
  }

  @override
  Future<void> close() {
    _addressTimer?.cancel();
    return super.close();
  }
}
