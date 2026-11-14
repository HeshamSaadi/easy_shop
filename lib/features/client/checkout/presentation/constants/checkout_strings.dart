import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class CheckoutStrings {
  static const String title = 'Checkout';
  static const String deliveryAddress = 'Delivery Address';
  static const String noLocation = 'Choose where we should deliver your order';
  static const String chooseLocation = 'Choose Location';
  static const String changeLocation = 'Change Location';
  static const String orderItems = 'Order Items';
  static const String paymentMethod = 'Payment Method';
  static const String cashOnDelivery = 'Cash on Delivery';
  static const String card = 'Credit / Debit Card';
  static const String comingSoon = 'Coming soon';
  static const String orderSummary = 'Order Summary';
  static const String total = 'Total';
  static const String placeOrder = 'Place Order';
  static const String emptyCart = 'Your cart is empty';
  static const String fixItems =
      'Remove unavailable items from your cart to continue';
  static const String _currency = 'EGP';

  static String money(double value) =>
      '${PriceFormatter.format(value)} $_currency';

  static String itemsLabel(int count) => 'Items ($count)';

  static String quantity(int count) => 'Qty: $count';

  static const String successTitle = 'Payment Successful!';
  static const String successMessage =
      'Your order has been placed successfully.';
  static const String viewOrders = 'View Orders';
  static const String continueShopping = 'Continue Shopping';
}
