import 'package:easy_shop/core/location/map_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap with the project's settings. Used by the picker and viewer.
class OsmMap extends StatelessWidget {
  const OsmMap({
    super.key,
    required this.center,
    this.onPositionChanged,
    this.layers = const [],
  });

  /// Only used when the map first opens. Later moves come from the user.
  final LatLng center;
  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;
  final List<Widget> layers;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: MapConstants.defaultZoom,
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
        onPositionChanged: onPositionChanged,
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.drag |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: MapConstants.tileUrlTemplate,
          userAgentPackageName: MapConstants.userAgentPackageName,
        ),
        ...layers,
        const SimpleAttributionWidget(
          source: Text(MapConstants.attributionText),
        ),
      ],
    );
  }
}
