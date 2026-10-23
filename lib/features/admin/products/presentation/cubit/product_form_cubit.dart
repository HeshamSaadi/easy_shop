import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_category_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/create_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/update_product.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit({
    required this._getCategories,
    required this._createProduct,
    required this._updateProduct,
    required this._imagePicker,
  }) : super(const ProductFormLoading());

  final GetCategories _getCategories;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final ImagePickerService _imagePicker;

  Future<void> loadCategories() async {
    emit(const ProductFormLoading());
    final result = await _getCategories();
    result.fold(
      (failure) => emit(ProductFormLoadError(failure.message)),
      (categories) => emit(
        ProductFormReady(
          categories: categories.map(_toProductCategory).toList(),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final current = state;
    if (current is! ProductFormReady || current.isSubmitting) return;

    try {
      final path = await _imagePicker.pickImage();
      if (path != null) emit(current.copyWith(imagePath: path));
    } on Exception {
      emit(current.copyWith(message: ProductsStrings.imagePickFailed));
    }
  }

  /// Pass [slug] to edit an existing product, leave it null to add a new one.
  Future<void> submit({
    String? slug,
    required String name,
    required String price,
    required String quantity,
    required int categoryId,
    required bool isVisible,
    String? description,
  }) async {
    final current = state;
    if (current is! ProductFormReady || current.isSubmitting) return;

    final priceValue = double.tryParse(price.trim());
    final quantityValue = int.tryParse(quantity.trim());
    if (priceValue == null || quantityValue == null) {
      emit(current.copyWith(message: ProductsStrings.invalidNumbers));
      return;
    }

    emit(current.copyWith(isSubmitting: true));

    final params = ProductParams(
      name: name.trim(),
      price: priceValue,
      quantity: quantityValue,
      categoryId: categoryId,
      isVisible: isVisible,
      description: description?.trim(),
      imagePath: current.imagePath,
    );
    final result = slug == null
        ? await _createProduct(params)
        : await _updateProduct(slug: slug, params: params);

    result.fold(
      (failure) => emit(current.copyWith(message: failure.message)),
      (_) => emit(const ProductFormSuccess()),
    );
  }

  ProductCategoryEntity _toProductCategory(CategoryEntity category) {
    return ProductCategoryEntity(
      id: category.id,
      name: category.name,
      slug: category.slug,
    );
  }
}
