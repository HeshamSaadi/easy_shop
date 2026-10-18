import 'package:easy_shop/core/location/location_messages.dart';
import 'package:easy_shop/core/location/map_constants.dart';
import 'package:easy_shop/core/location/widgets/location_pin.dart';
import 'package:easy_shop/core/location/widgets/map_bottom_panel.dart';
import 'package:easy_shop/core/location/widgets/osm_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Read-only map for a saved location ("View on Map").
class LocationViewerScreen extends StatelessWidget {
  const LocationViewerScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  static Future<void> open(
    BuildContext context, {
    required double latitude,
    required double longitude,
    String? address,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LocationViewerScreen(
          latitude: latitude,
          longitude: longitude,
          address: address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    final addressText = address;

    return Scaffold(
      appBar: AppBar(title: const Text(LocationMessages.viewerTitle)),
      body: Column(
        children: [
          Expanded(
            child: OsmMap(
              center: point,
              layers: [
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: MapConstants.pinSize,
                      height: MapConstants.pinSize,
                      // topCenter puts the pin above the point, tip on it.
                      alignment: Alignment.topCenter,
                      child: const LocationPin(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (addressText != null)
            MapBottomPanel(
              child: Text(
                addressText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}
