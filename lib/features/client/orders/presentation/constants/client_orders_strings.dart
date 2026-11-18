import 'package:easy_shop/core/utils/date_formatter.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';

abstract final class ClientOrdersStrings {
  static const String title = 'My Orders';
  static const String empty = 'No orders yet';
  static const String startShopping = 'Start Shopping';

  static const String detailsTitle = 'Order Details';
  static const String deliveryAddress = 'Delivery Address';
  static const String viewOnMap = 'View on Map';
  static const String orderItems = 'Order Items';
  static const String paymentMethod = 'Payment Method';
  static const String orderSummary = 'Order Summary';
  static const String total = 'Total';

  static const String cash = 'Cash';
  static const String card = 'Card';
  static const String otherPayment = 'Other';
  static const String _currency = 'EGP';

  static String money(double value) =>
      '${PriceFormatter.format(value)} $_currency';

  static String items(int count) => count == 1 ? '1 item' : '$count items';

  static String itemsLabel(int count) => 'Items ($count)';

  /// "150 EGP × 2": the price at order time times the quantity.
  static String itemLine(double price, int quantity) =>
      '${money(price)} × $quantity';

  /// "Pending". The status is a raw server string, so it is only capitalized.
  static String status(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static String payment(PaymentMethod? method) {
    return switch (method) {
      PaymentMethod.cash => cash,
      PaymentMethod.card => card,
      null => otherPayment,
    };
  }

  /// "Aug 22, 2026" in the device time zone.
  static String date(DateTime value) => AppDateFormatter.date(value);

  /// "Aug 22, 2026  ·  02:32 PM" in the device time zone.
  static String dateTime(DateTime value) {
    return '${AppDateFormatter.date(value)}  ·  ${AppDateFormatter.time(value)}';
  }
}
