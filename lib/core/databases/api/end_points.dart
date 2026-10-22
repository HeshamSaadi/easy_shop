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
}
