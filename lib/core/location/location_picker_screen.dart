import 'package:easy_shop/core/location/location_messages.dart';
import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_state.dart';
import 'package:easy_shop/core/location/map_constants.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/location/widgets/location_pin.dart';
import 'package:easy_shop/core/location/widgets/map_bottom_panel.dart';
import 'package:easy_shop/core/location/widgets/osm_map.dart';
import 'package:easy_shop/core/location/widgets/permission_prompt.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

/// Full-screen picker. Pops with the chosen [PickedLocation], or null on back.
class LocationPickerScreen extends StatelessWidget {
  const LocationPickerScreen({super.key, required this.createCubit});

  final LocationPickerCubit Function() createCubit;

  static Future<PickedLocation?> open(
    BuildContext context, {
    required LocationPickerCubit Function() createCubit,
  }) {
    return Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(createCubit: createCubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit()..start(),
      child: Scaffold(
        appBar: AppBar(title: const Text(LocationMessages.pickerTitle)),
        body: const _PickerBody(),
      ),
    );
  }
}

class _PickerBody extends StatelessWidget {
  const _PickerBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LocationPickerCubit>();

    return BlocBuilder<LocationPickerCubit, LocationPickerState>(
      builder: (context, state) => switch (state) {
        LocationPickerLoading() => const AppLoading(),
        LocationPickerPermissionRequired(:final status) => PermissionPrompt(
          status: status,
          onPrimaryPressed: cubit.onPermissionAction,
          onRetryPressed: cubit.start,
        ),
        LocationPickerError(:final message) => AppError(
          message: message,
          onRetry: cubit.start,
        ),
        LocationPickerReady ready => _PickerMap(state: ready),
      },
    );
  }
}

class _PickerMap extends StatefulWidget {
  const _PickerMap({required this.state});

  final LocationPickerReady state;

  @override
  State<_PickerMap> createState() => _PickerMapState();
}

class _PickerMapState extends State<_PickerMap> {
  // The map opens here once. After that, the user moves it.
  late final LatLng _startCenter = LatLng(
    widget.state.location.latitude,
    widget.state.location.longitude,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LocationPickerCubit>();
    final ready = widget.state;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              OsmMap(
                center: _startCenter,
                onPositionChanged: (camera, hasGesture) {
                  // Ignore moves we did not cause by hand (first layout).
                  if (!hasGesture) return;
                  cubit.onMapMoved(
                    latitude: camera.center.latitude,
                    longitude: camera.center.longitude,
                  );
                },
              ),
              // The padding lifts the icon so its tip sits on the map center.
              const IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: MapConstants.pinSize),
                    child: LocationPin(),
                  ),
                ),
              ),
            ],
          ),
        ),
        MapBottomPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _addressText(ready),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: LocationMessages.confirm,
                // Wait for the address lookup, so it is not lost.
                onPressed: ready.isResolvingAddress
                    ? null
                    : () => Navigator.of(context).pop(ready.location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _addressText(LocationPickerReady ready) {
    if (ready.isResolvingAddress) return LocationMessages.findingAddress;
    return ready.location.address ?? LocationMessages.addressNotFound;
  }
}
