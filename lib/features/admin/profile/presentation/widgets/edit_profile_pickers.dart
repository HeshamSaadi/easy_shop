import 'package:easy_shop/core/location/picked_location.dart';

typedef PickFile = Future<String?> Function();

typedef PickStoreLocation = Future<PickedLocation?> Function(
  PickedLocation? initial,
);
