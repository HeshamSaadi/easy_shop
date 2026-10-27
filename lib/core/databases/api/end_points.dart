//lib\core\databases\api\end_points.dart
abstract final class EndPoints {
  static const String adminRegister = '/admin/register';
  static const String adminLogin = '/admin/login';
  static const String adminVerifyOtp = '/admin/otp/verify';
  static const String adminResendOtp = '/admin/otp/resend';
  static const String adminLogout = '/admin/logout';

  static const String adminProducts = '/admin/products';
  static const String adminProductStore = '/admin/products/store';

  static String adminProductDetails(String slug) =>
      '/admin/products/show/$slug';

  static String adminProductUpdate(String slug) =>
      '/admin/products/update/$slug';

  static String adminProductDelete(String slug) =>
      '/admin/products/destroy/$slug';

  static const String adminOrders = '/admin/orders';

  static String adminOrderDetails(String code) => '/admin/orders/show/$code';

  static const String adminCategories = '/admin/categories';
  static const String adminCategoryStore = '/admin/categories/store';
  static String adminCategoryUpdate(String slug) =>
      '/admin/categories/update/${Uri.encodeComponent(slug)}';
  static String adminCategoryDelete(String slug) =>
      '/admin/categories/destroy/${Uri.encodeComponent(slug)}';

  // profile
  static const String adminProfile = '/admin/profile';
  static const String adminProfileUpdate = '/admin/profile/update';
}
