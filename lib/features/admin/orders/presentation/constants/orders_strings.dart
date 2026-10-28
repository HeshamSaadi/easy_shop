abstract final class OrdersStrings {
  static const String title = 'Orders';
  static const String empty = 'No orders yet';

  static const String cash = 'Cash';
  static const String card = 'Card';
  static const String unknownPayment = 'Other';

  static const String detailsTitle = 'Order Details';
  static const String customerSection = 'Customer';
  static const String deliverySection = 'Delivery';
  static const String viewOnMap = 'View on Map';
  static const String itemsSection = 'Order Items';
  static const String paymentSection = 'Payment';
  static const String summarySection = 'Summary';
  static const String total = 'Total';

  static String items(int count) => count == 1 ? '1 item' : '$count items';
}
