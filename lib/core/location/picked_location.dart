/// A place chosen on the map. Pure Dart, so any layer can use it.
class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;

  /// Readable text such as "Street, City, Country". Null if the lookup failed.
  final String? address;

  /// A new point has no address until it is looked up again.
  PickedLocation moveTo({required double latitude, required double longitude}) {
    return PickedLocation(latitude: latitude, longitude: longitude);
  }

  PickedLocation withAddress(String? address) {
    return PickedLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  bool isSamePoint(PickedLocation other) {
    return latitude == other.latitude && longitude == other.longitude;
  }
}
