import 'package:easy_shop/core/utils/price_formatter.dart';

abstract final class HomeStrings {
  static const String searchHint = 'Search products...';
  static const String categories = 'Categories';
  static const String seeAll = 'See all';
  static const String products = 'Products';
  static const String allCategories = 'All';
  static const String outOfStock = 'Out of Stock';
  static const String noProducts = 'No products yet';
  static const String noResults = 'No products match your search';
  static const String wave = '👋';
  static const String _currency = 'EGP';

  static String greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String itemCount(int count) => count == 1 ? '1 item' : '$count items';

  static String money(double value) =>
      '${PriceFormatter.format(value)} $_currency';

  static String soldBy(String store) => 'by $store';
}
