abstract final class HomeStrings {
  static const String totalProducts = 'Total Products';
  static const String totalOrders = 'Total Orders';
  static const String pendingOrders = 'Pending Orders';
  static const String categories = 'Categories';

  static const String quickActions = 'Quick Actions';
  static const String addProduct = 'Add Product';
  static const String manageCategories = 'Categories';

  static const String recentOrders = 'Recent Orders';
  static const String productsOverview = 'Products Overview';
  static const String seeAll = 'See all';
  static const String noOrders = 'No orders yet';
  static const String noProducts = 'No products yet';

  static const String goodMorning = 'Good morning,';
  static const String goodAfternoon = 'Good afternoon,';
  static const String goodEvening = 'Good evening,';

  static const int _noon = 12;
  static const int _eveningStart = 18;

  static const String visible = 'Visible';
  static const String hidden = 'Hidden';

  static String quantity(int value) => 'Qty $value';

  /// Greeting line for the given hour (0-23).
  static String greetingForHour(int hour) {
    if (hour < _noon) return goodMorning;
    if (hour < _eveningStart) return goodAfternoon;
    return goodEvening;
  }
}
