import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';

/// Builds the dashboard from the three list endpoints, because the API has
/// no stats endpoint.
class GetDashboardStats {
  const GetDashboardStats({
    required this._getCategories,
    required this._getProducts,
    required this._getOrders,
  });

  /// How many recent orders and products the home screen previews.
  static const int previewLimit = 3;

  final GetCategories _getCategories;
  final GetProducts _getProducts;
  final GetOrders _getOrders;

  Future<Either<Failure, DashboardStats>> call() async {
    final (categories, products, orders) = await (
      _getCategories(),
      _getProducts(),
      _getOrders(),
    ).wait;

    return categories.flatMap(
      (categoryList) => products.flatMap(
        (productList) => orders.map(
          (orderList) => _build(categoryList.length, productList, orderList),
        ),
      ),
    );
  }

  DashboardStats _build(
    int categoriesCount,
    List<ProductEntity> products,
    List<OrderEntity> orders,
  ) {
    final newestFirst = [...orders]..sort(_compareNewestFirst);
    return DashboardStats(
      categoriesCount: categoriesCount,
      productsCount: products.length,
      ordersCount: orders.length,
      pendingOrdersCount: orders.where((order) => order.isPending).length,
      recentOrders: newestFirst.take(previewLimit).toList(),
      overviewProducts: products.take(previewLimit).toList(),
    );
  }

  static int _compareNewestFirst(OrderEntity a, OrderEntity b) {
    final aDate = a.createdAt;
    final bDate = b.createdAt;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }
}
