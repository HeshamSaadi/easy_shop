/// Turns coordinates into readable text. Returns null when nothing is found,
/// because the coordinates are what the API needs, not the text.
abstract class AddressResolver {
  Future<String?> resolve({
    required double latitude,
    required double longitude,
  });
}
