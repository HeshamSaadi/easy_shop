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
  static const profileEdit = 'profile-edit';
}

abstract final class ClientRoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const verified = '/verified';
  static const home = '/home';
  static const favorites = '/favorites';
  static const cart = '/cart';
  static const orders = '/orders';
  static const profile = '/profile';

  /// Relative path of the edit screen, nested under [profile].
  static const profileEdit = 'edit';

  /// Screens a signed-out user may open. `verified` is here because the
  /// session becomes "authenticated" only when the user leaves that screen.
  static const Set<String> publicRoutes = {login, register, otp, verified};
}
