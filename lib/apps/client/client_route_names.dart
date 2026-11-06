abstract final class ClientRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const otp = 'otp';
  static const home = 'home';
  static const categories = 'categories';
  static const products = 'products';
  static const productDetails = 'productDetails';
  static const cart = 'cart';
  static const checkout = 'checkout';
  static const orders = 'orders';
  static const orderDetails = 'orderDetails';
  static const profile = 'profile';
  static const profileEdit = 'profileEdit';
  static const String verified = 'verified';
}

abstract final class ClientRoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const home = '/home';
  static const categories = '/categories';
  static const products = '/products';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';
  static const String verified = '/verified';

  static const publicRoutes = {login, register, otp};
}

abstract final class ClientRouteParams {
  static const id = 'id';
}
