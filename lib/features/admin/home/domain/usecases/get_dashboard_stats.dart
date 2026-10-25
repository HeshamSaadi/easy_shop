import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';

class GetDashboardStats {
  const GetDashboardStats({
    required this._getCategories,
    required this._getProducts,
    required this._getOrders,
  });

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
          (orderList) => DashboardStats(
            categoriesCount: categoryList.length,
            productsCount: productList.length,
            ordersCount: orderList.length,
          ),
        ),
      ),
    );
  }
}
