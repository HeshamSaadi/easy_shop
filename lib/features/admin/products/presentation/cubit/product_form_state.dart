import 'package:easy_shop/features/admin/products/domain/entities/product_category_entity.dart';

sealed class ProductFormState {
  const ProductFormState();
}

/// Loading the categories for the dropdown.
class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

class ProductFormLoadError extends ProductFormState {
  const ProductFormLoadError(this.message);

  final String message;
}

/// The form is on screen. Submitting stays in this state with
/// [isSubmitting] true, so the fields do not disappear while saving.
class ProductFormReady extends ProductFormState {
  const ProductFormReady({
    required this.categories,
    this.imagePath,
    this.isSubmitting = false,
    this.message,
  });

  final List<ProductCategoryEntity> categories;

  /// A newly picked image. Null means "keep the current one".
  final String? imagePath;
  final bool isSubmitting;

  /// One-time message (a failed save or pick). The UI shows it in a SnackBar.
  final String? message;

  /// [message] is not carried over, so it is shown only once.
  ProductFormReady copyWith({
    String? imagePath,
    bool? isSubmitting,
    String? message,
  }) {
    return ProductFormReady(
      categories: categories,
      imagePath: imagePath ?? this.imagePath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
    );
  }
}

class ProductFormSuccess extends ProductFormState {
  const ProductFormSuccess();
}
