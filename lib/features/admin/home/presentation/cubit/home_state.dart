import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.stats, {this.actionError});

  final DashboardStats stats;

  /// Set when a refresh failed. The old numbers stay on screen and the UI
  /// shows this message in a SnackBar.
  final String? actionError;
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}
