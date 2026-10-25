import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_form_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_form_state.dart';
import 'package:easy_shop/features/admin/products/presentation/utils/product_formatters.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_image_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// One screen for both add and edit.
/// Pass [product] to edit, leave it null to add.
/// Pops with `true` when the product was saved.
class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key, this.product});

  final ProductEntity? product;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProductFormCubit>()..loadCategories(),
      child: _ProductFormView(product: product),
    );
  }
}

class _ProductFormView extends StatefulWidget {
  const _ProductFormView({required this.product});

  final ProductEntity? product;

  @override
  State<_ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<_ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  int? _categoryId;
  late bool _isVisible;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name);
    _priceController = TextEditingController(
      text: product == null ? null : ProductFormatters.price(product.price),
    );
    _quantityController = TextEditingController(
      text: product?.quantity.toString(),
    );
    _descriptionController = TextEditingController(text: product?.description);
    _categoryId = product?.categoryId;
    _isVisible = product?.isVisible ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final categoryId = _categoryId;
    if (categoryId == null) return;

    context.read<ProductFormCubit>().submit(
      slug: widget.product?.slug,
      name: _nameController.text,
      price: _priceController.text,
      quantity: _quantityController.text,
      categoryId: categoryId,
      isVisible: _isVisible,
      description: _descriptionController.text,
    );
  }

  void _onStateChanged(BuildContext context, ProductFormState state) {
    if (state is ProductFormSuccess) {
      Navigator.pop(context, true);
      return;
    }
    if (state is! ProductFormReady) return;
    final message = state.message;
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEdit ? ProductsStrings.editTitle : ProductsStrings.addTitle,
        showBack: true,
      ),
      body: BlocConsumer<ProductFormCubit, ProductFormState>(
        listenWhen: (_, current) =>
            current is ProductFormSuccess ||
            (current is ProductFormReady && current.message != null),
        listener: _onStateChanged,
        builder: (context, state) {
          return switch (state) {
            ProductFormLoading() || ProductFormSuccess() => const AppLoading(),
            ProductFormLoadError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<ProductFormCubit>().loadCategories(),
            ),
            final ProductFormReady ready when ready.categories.isEmpty =>
              const AppEmpty(
                message: ProductsStrings.noCategories,
                icon: Icons.category_outlined,
              ),
            final ProductFormReady ready => _buildForm(context, ready),
          };
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProductFormReady ready) {
    final isSubmitting = ready.isSubmitting;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageField(
                imagePath: ready.imagePath,
                imageUrl: widget.product?.imageUrl,
                enabled: !isSubmitting,
                onTap: () => context.read<ProductFormCubit>().pickImage(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: ProductsStrings.nameLabel,
                hint: ProductsStrings.nameHint,
                controller: _nameController,
                enabled: !isSubmitting,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.notEmpty(
                  value,
                  fieldName: ProductsStrings.nameLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildCategoryField(ready),
              const SizedBox(height: AppSpacing.lg),
              _buildPriceAndQuantity(isSubmitting),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: ProductsStrings.descriptionLabel,
                hint: ProductsStrings.descriptionHint,
                controller: _descriptionController,
                isOptional: true,
                maxLines: 3,
                enabled: !isSubmitting,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(ProductsStrings.visibleTitle),
                subtitle: const Text(ProductsStrings.visibleSubtitle),
                value: _isVisible,
                onChanged: isSubmitting
                    ? null
                    : (value) => setState(() => _isVisible = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: _isEdit
                    ? ProductsStrings.saveChanges
                    : ProductsStrings.addSubmit,
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryField(ProductFormReady ready) {
    final textTheme = Theme.of(context).textTheme;
    // An edited product may point to a category that no longer exists
    final hasSelected = ready.categories.any((c) => c.id == _categoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ProductsStrings.categoryLabel,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int>(
          initialValue: hasSelected ? _categoryId : null,
          isExpanded: true,
          hint: const Text(ProductsStrings.categoryHint),
          items: [
            for (final category in ready.categories)
              DropdownMenuItem(value: category.id, child: Text(category.name)),
          ],
          onChanged: ready.isSubmitting
              ? null
              : (value) => setState(() => _categoryId = value),
          validator: (value) =>
              value == null ? ProductsStrings.categoryRequired : null,
        ),
      ],
    );
  }

  Widget _buildPriceAndQuantity(bool isSubmitting) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: ProductsStrings.priceLabel,
            hint: ProductsStrings.priceHint,
            controller: _priceController,
            enabled: !isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.positiveNumber(
              value,
              fieldName: ProductsStrings.priceLabel,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            label: ProductsStrings.quantityLabel,
            hint: ProductsStrings.quantityHint,
            controller: _quantityController,
            enabled: !isSubmitting,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.nonNegativeInteger(
              value,
              fieldName: ProductsStrings.quantityLabel,
            ),
          ),
        ),
      ],
    );
  }
}
