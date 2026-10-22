import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/delete_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({required this._getCategories, required this._deleteCategory})
    : super(const CategoriesInitial());

  final GetCategories _getCategories;
  final DeleteCategory _deleteCategory;

  Future<void> load() async {
    emit(const CategoriesLoading());
    final result = await _getCategories();
    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  /// Pull to refresh: keeps the old list on screen while loading.
  Future<void> refresh() async {
    final result = await _getCategories();
    result.fold(
      (failure) => _keepListWithError(failure.message),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> delete(CategoryEntity category) async {
    final current = state;
    if (current is! CategoriesLoaded || current.deletingId != null) return;

    emit(CategoriesLoaded(current.categories, deletingId: category.id));

    final result = await _deleteCategory(category.slug);
    result.fold(
      (failure) => emit(
        CategoriesLoaded(current.categories, actionError: failure.message),
      ),
      (_) => emit(
        CategoriesLoaded(
          current.categories.where((c) => c.id != category.id).toList(),
        ),
      ),
    );
  }

  void _keepListWithError(String message) {
    final current = state;
    if (current is CategoriesLoaded) {
      emit(CategoriesLoaded(current.categories, actionError: message));
    } else {
      emit(CategoriesError(message));
    }
  }
}
