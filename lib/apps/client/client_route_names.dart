abstract final class ClientRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const otp = 'otp';
  static const verified = 'verified';
  static const home = 'home';
  static const favorites = 'favorites';
  static const cart = 'cart';
  static const orders = 'orders';
  static const profile = 'profile';
  static const profileEdit = 'profileEdit';
}

abstract final class ClientRoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const verified = '/verified';
  static const home = '/home';
  static const favorites = '/favorites';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';

  // Screens a signed-out user may open. `verified` is not here on purpose:
  // it is shown right after the session becomes authenticated.
  static const publicRoutes = {login, register, otp};
}
