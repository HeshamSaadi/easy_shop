import 'package:easy_shop/features/admin/categories/domain/usecases/add_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/update_category.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/category_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFormCubit extends Cubit<CategoryFormState> {
  CategoryFormCubit({required this._addCategory, required this._updateCategory})
    : super(const CategoryFormIdle());

  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;

  /// Pass [slug] to edit an existing category, leave it null to add a new one.
  Future<void> submit({
    String? slug,
    required String name,
    String? description,
  }) async {
    if (state is CategoryFormSubmitting) return;
    emit(const CategoryFormSubmitting());

    final result = slug == null
        ? await _addCategory(name: name, description: description)
        : await _updateCategory(
            slug: slug,
            name: name,
            description: description,
          );

    result.fold(
      (failure) => emit(CategoryFormFailure(failure.message)),
      (_) => emit(const CategoryFormSuccess()),
    );
  }
}
