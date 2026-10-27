import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';

/// Everything the admin home screen shows.
class DashboardStats {
  const DashboardStats({
    required this.categoriesCount,
    required this.productsCount,
    required this.ordersCount,
    required this.pendingOrdersCount,
    required this.recentOrders,
    required this.overviewProducts,
  });

  final int categoriesCount;
  final int productsCount;
  final int ordersCount;
  final int pendingOrdersCount;

  /// Newest first, limited to the preview size.
  final List<OrderEntity> recentOrders;

  /// The first products of the list, limited to the preview size.
  final List<ProductEntity> overviewProducts;
}
