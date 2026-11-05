import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this._getDashboardStats}) : super(const HomeInitial());

  final GetDashboardStats _getDashboardStats;

  Future<void> load() async {
    emit(const HomeLoading());
    final result = await _getDashboardStats();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (stats) => emit(HomeLoaded(stats)),
    );
  }

  /// Pull to refresh: keeps the old numbers on screen while loading.
  Future<void> refresh() async {
    final result = await _getDashboardStats();
    result.fold(_keepStatsWithError, (stats) => emit(HomeLoaded(stats)));
  }

  void _keepStatsWithError(Failure failure) {
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(current.stats, actionError: failure.message));
    } else {
      emit(HomeError(failure.message));
    }
  }
}
