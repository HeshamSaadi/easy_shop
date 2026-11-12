import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class CartStrings {
  static const String title = 'My Cart';
  static const String empty = 'Your cart is empty';
  static const String startShopping = 'Start shopping';
  static const String subtotal = 'Subtotal';
  static const String total = 'Total';
  static const String checkout = 'Proceed to Checkout';
  static const String fixItems = 'Remove unavailable items to continue';
  static const String unavailable = 'No longer available';
  static const String outOfStock = 'Out of stock';
  static const String removeTitle = 'Remove item';
  static const String removeConfirm = 'Remove';
  static const String _currency = 'EGP';

  static String money(double value) =>
      '${PriceFormatter.format(value)} $_currency';

  static String itemCount(int count) => count == 1 ? '1 item' : '$count items';

  static String stockLimit(int stock) => 'Only $stock in stock';

  static String removeMessage(String name) => 'Remove $name from your cart?';
}
