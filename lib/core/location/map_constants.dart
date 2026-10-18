class MapConstants {
  const MapConstants._();

  static const tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Tells the OpenStreetMap servers which app is asking for tiles.
  static const userAgentPackageName = 'com.example.easy_shop';

  static const attributionText = 'OpenStreetMap contributors';

  static const defaultZoom = 16.0;
  static const minZoom = 3.0;
  static const maxZoom = 19.0;

  static const pinSize = 48.0;
}
