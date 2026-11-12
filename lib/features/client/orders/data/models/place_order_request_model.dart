import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/domain/params/place_order_params.dart';

/// The JSON body of `POST /client/orders/store`.
class PlaceOrderRequestModel {
  const PlaceOrderRequestModel(this._params);

  final PlaceOrderParams _params;

  /// `product_id`, `quantity` and `price` are parallel lists. They come from
  /// the same list of lines, so they always have the same length.
  Map<String, dynamic> toJson() {
    final lines = _params.lines;

    return {
      'product_id': [for (final line in lines) line.productId],
      'quantity': [for (final line in lines) line.quantity],
      'price': [for (final line in lines) line.price],
      'address': _params.address,
      'latitude': _params.latitude,
      'longitude': _params.longitude,
      'payment_method': _wireValue(_params.paymentMethod),
    };
  }

  /// The server accepts only lowercase `cash` and `card`.
  static String _wireValue(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => 'cash',
      PaymentMethod.card => 'card',
    };
  }
}
