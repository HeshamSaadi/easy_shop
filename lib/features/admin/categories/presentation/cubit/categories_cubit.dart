import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
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
    try {
      emit(CategoriesLoaded(await _getCategories()));
    } on AppException catch (e) {
      emit(CategoriesError(e.message));
    } catch (_) {
      emit(const CategoriesError(ErrorMessages.unknown));
    }
  }

  /// Pull to refresh: keeps the old list on screen while loading.
  Future<void> refresh() async {
    try {
      emit(CategoriesLoaded(await _getCategories()));
    } on AppException catch (e) {
      _keepListWithError(e.message);
    } catch (_) {
      _keepListWithError(ErrorMessages.unknown);
    }
  }

  Future<void> delete(CategoryEntity category) async {
    final current = state;
    if (current is! CategoriesLoaded) return;

    try {
      await _deleteCategory(category.slug);
      emit(
        CategoriesLoaded(
          current.categories.where((c) => c.id != category.id).toList(),
        ),
      );
    } on AppException catch (e) {
      emit(CategoriesLoaded(current.categories, actionError: e.message));
    } catch (_) {
      emit(
        CategoriesLoaded(
          current.categories,
          actionError: ErrorMessages.unknown,
        ),
      );
    }
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
