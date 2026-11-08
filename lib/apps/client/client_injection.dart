import 'package:get_it/get_it.dart';
import 'package:easy_shop/features/client/client_catalog_injection.dart';

/// Registers the Client features. Each feature adds its own
/// `registerClient...(sl)` call here (auth, catalog, cart, orders, profile).
void initClient(GetIt sl) {
  registerClientCatalog(sl);
}
