/// The numbers shown on the admin home screen.
class DashboardStats {
  const DashboardStats({
    required this.categoriesCount,
    required this.productsCount,
    required this.ordersCount,
  });

  final int categoriesCount;
  final int productsCount;
  final int ordersCount;
}
