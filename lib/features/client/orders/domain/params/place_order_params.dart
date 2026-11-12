import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/domain/params/order_line.dart';

class PlaceOrderParams {
  const PlaceOrderParams({
    required this.lines,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
  });

  final List<OrderLine> lines;
  final String address;
  final double latitude;
  final double longitude;
  final PaymentMethod paymentMethod;
}
