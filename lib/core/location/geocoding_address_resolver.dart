import 'package:geocoding/geocoding.dart';

import 'address_resolver.dart';

class GeocodingAddressResolver implements AddressResolver {
  GeocodingAddressResolver({Geocoding? geocoding})
    : _geocoding = geocoding ?? Geocoding();

  final Geocoding _geocoding;
  @override
  Future<String?> resolve({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;
      return _format(placemarks.first);
    } on Exception {
      // Some devices have no geocoder. That must never break the picker.
      return null;
    }
  }

  String? _format(Placemark placemark) {
    final parts =
        <String?>[
              placemark.street,
              placemark.subLocality,
              placemark.locality,
              placemark.country,
            ]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();

    return parts.isEmpty ? null : parts.join(', ');
  }
}
