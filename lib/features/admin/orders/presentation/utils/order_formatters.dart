import 'package:easy_shop/core/utils/date_formatter.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/admin/orders/presentation/constants/orders_strings.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class OrderFormatters {
  /// "Pending". The status is a raw server string, so it is only capitalized.
  static String status(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static String payment(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => OrdersStrings.cash,
      PaymentMethod.card => OrdersStrings.card,
      PaymentMethod.unknown => OrdersStrings.unknownPayment,
    };
  }

  /// "Jan 15, 2024 · 02:32 PM" in the device time zone.
  static String dateTime(DateTime value) {
    return '${AppDateFormatter.date(value)}  ·  ${AppDateFormatter.time(value)}';
  }

  /// "599 × 2": the price at order time times the quantity.
  static String itemLine(double price, int quantity) {
    return '${PriceFormatter.format(price)} × $quantity';
  }
}
