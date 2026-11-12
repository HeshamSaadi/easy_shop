import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/checkout/presentation/cubit/checkout_state.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/domain/params/order_line.dart';
import 'package:easy_shop/features/client/orders/domain/params/place_order_params.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/place_order.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required this._getCart,
    required this._getProfile,
    required this._placeOrder,
  }) : super(const CheckoutInitial());

  final GetCart _getCart;
  final GetClientProfile _getProfile;
  final PlaceOrder _placeOrder;

  /// The cart is read from the server, not from `CartCubit`: the server
  /// trusts the price we send, so it must be fresh.
  Future<void> load() async {
    emit(const CheckoutLoading());

    final cartRequest = _getCart();
    final profileRequest = _getProfile();
    final cart = await cartRequest;
    final profile = await profileRequest;

    cart.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (items) =>
          emit(CheckoutReady(items: items, location: _savedLocation(profile))),
    );
  }

  /// Replaces the delivery point (from the map picker).
  void setLocation(PickedLocation location) {
    final current = state;
    if (current is! CheckoutReady || current.isPlacing) return;
    emit(current.copyWith(location: location));
  }

  Future<void> placeOrder() async {
    final current = state;
    if (current is! CheckoutReady || !current.canPlace) return;
    final location = current.location;
    if (location == null) return;

    emit(current.copyWith(isPlacing: true));

    final result = await _placeOrder(
      PlaceOrderParams(
        // One loop: the three lists can never differ in length, and the
        // price always comes from the cart item.
        lines: [
          for (final item in current.items)
            OrderLine(
              productId: item.product.id,
              quantity: item.quantity,
              price: item.product.price,
            ),
        ],
        address: current.deliveryAddress,
        latitude: location.latitude,
        longitude: location.longitude,
        // Card payment is not built yet (see the README).
        paymentMethod: PaymentMethod.cash,
      ),
    );

    result.fold(
      (failure) => emit(
        current.copyWith(isPlacing: false, actionError: failure.message),
      ),
      (order) => emit(CheckoutPlaced(order)),
    );
  }

  /// A failed profile request is not an error here: the user can still pick
  /// a location on the map.
  PickedLocation? _savedLocation(Either<Failure, ClientEntity> profile) {
    return profile.fold((_) => null, (client) {
      final latitude = client.latitude;
      final longitude = client.longitude;
      if (latitude == null || longitude == null) return null;

      final address = client.address?.trim();
      return PickedLocation(
        latitude: latitude,
        longitude: longitude,
        address: (address == null || address.isEmpty) ? null : address,
      );
    });
  }
}
