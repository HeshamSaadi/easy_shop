import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class ProductDetailsStrings {
  static const String addToCart = 'Add to Cart';
  static const String added = 'Added to Cart!';
  static const String outOfStock = 'Out of Stock';
  static const String inStock = 'In Stock';
  static const String quantity = 'Quantity';
  static const String description = 'Description';
  static const String alreadyMax =
      'You already have all the available units in your cart';
  static const String _currency = 'EGP';

  static String soldBy(String store) => 'Sold by $store';

  static String units(int count) => count == 1 ? '1 unit' : '$count units';

  static String money(double value) =>
      '${PriceFormatter.format(value)} $_currency';
}
