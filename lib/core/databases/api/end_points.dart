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

  // Client endpoints
  static const String clientRegister = '/client/register';
  static const String clientLogin = '/client/login';
  static const String clientVerifyOtp = '/client/otp/verify';
  static const String clientResendOtp = '/client/otp/resend';
  static const String clientLogout = '/client/logout';
  static const String clientProfile = '/client/profile';
  static const String clientProfileUpdate = '/client/profile/update';

  static const String clientCategories = '/client/categories';
  static const String clientProducts = '/client/products';
  static String clientProductDetails(String slug) =>
      '/client/products/show/${Uri.encodeComponent(slug)}';
  static const String clientCart = '/client/carts';
  static const String clientCartStore = '/client/carts/store';
  static const String clientCartDestroy = '/client/carts/destroy';
  static const String clientOrders = '/client/orders';
  static const String clientOrderStore = '/client/orders/store';
  static String clientOrderDetails(String code) =>
      '/client/orders/show/${Uri.encodeComponent(code)}';
}
