import 'package:easy_shop/core/location/map_constants.dart';
import 'package:flutter/material.dart';

class LocationPin extends StatelessWidget {
  const LocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: MapConstants.pinSize,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
