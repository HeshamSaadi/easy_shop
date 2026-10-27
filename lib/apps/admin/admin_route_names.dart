abstract final class AdminRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const otp = 'otp';
  static const home = 'home';
  static const products = 'products';
  static const productDetails = 'productDetails';
  static const productForm = 'productForm';
  static const categories = 'categories';
  static const categoryForm = 'categoryForm';
  static const orders = 'orders';
  static const profile = 'profile';
  static const profileEdit = 'profileEdit';
}

abstract final class AdminRoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const home = '/home';
  static const products = '/products';
  static const orders = '/orders';
  static const profile = '/profile';

  static const publicRoutes = {login, register, otp};
}

abstract final class AdminRouteParams {
  static const slug = 'slug';
}
