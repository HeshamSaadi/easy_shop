import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';

sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutReady extends CheckoutState {
  const CheckoutReady({
    required this.items,
    this.location,
    this.isPlacing = false,
    this.actionError,
  });

  static const int _coordinateDecimals = 5;

  final List<CartItemEntity> items;

  /// The delivery point. Starts as the saved profile location, if any.
  final PickedLocation? location;

  /// True while the order request runs. Blocks every button (no double submit).
  final bool isPlacing;

  /// Set when placing the order failed. The screen shows it once.
  final String? actionError;

  bool get hasLocation => location != null;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// The server accepts hidden products and quantities above stock in an
  /// order, so the app must not send them.
  bool get hasProblems =>
      items.any((item) => item.isHidden || item.exceedsStock);

  /// The text sent as `address`. Falls back to the coordinates when the
  /// address lookup found nothing.
  String get deliveryAddress {
    final place = location;
    if (place == null) return '';
    final latitude = place.latitude.toStringAsFixed(_coordinateDecimals);
    final longitude = place.longitude.toStringAsFixed(_coordinateDecimals);
    return place.address ?? '$latitude, $longitude';
  }

  bool get canPlace =>
      !isPlacing && items.isNotEmpty && !hasProblems && hasLocation;

  /// [actionError] is cleared by every copy unless a new one is passed.
  CheckoutReady copyWith({
    PickedLocation? location,
    bool? isPlacing,
    String? actionError,
  }) {
    return CheckoutReady(
      items: items,
      location: location ?? this.location,
      isPlacing: isPlacing ?? this.isPlacing,
      actionError: actionError,
    );
  }
}

/// One-time result: the screen leaves through its `onOrderPlaced` callback.
class CheckoutPlaced extends CheckoutState {
  const CheckoutPlaced(this.order);

  final OrderEntity order;
}

class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;
}
