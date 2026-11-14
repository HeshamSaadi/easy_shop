import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/place_order.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client checkout feature. Call from `initClient`.
/// It has no data layer of its own: it combines the cart, profile and
/// orders use cases. A factory, so each checkout starts fresh.
void registerClientCheckout(GetIt sl) {
  sl.registerFactory(
    () => CheckoutCubit(
      getCart: sl<GetCart>(),
      getProfile: sl<GetClientProfile>(),
      placeOrder: sl<PlaceOrder>(),
    ),
  );
}
