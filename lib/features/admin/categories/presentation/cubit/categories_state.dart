import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// An empty [categories] list is the "empty" screen, not a separate state.
class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories, {this.actionError, this.deletingId});

  final List<CategoryEntity> categories;

  /// Set when a delete failed. The list stays on screen and the UI shows
  /// this message in a SnackBar.
  final String? actionError;

  /// Id of the category being deleted, or null when no delete is running.
  final int? deletingId;
}

class CategoriesError extends CategoriesState {
  const CategoriesError(this.message);

  final String message;
}
