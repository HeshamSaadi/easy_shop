import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/category_form_cubit.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/category_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_shop/features/admin/categories/presentation/constants/categories_strings.dart';

/// One screen for both add and edit.
/// Pass [category] to edit, leave it null to add.
/// Pops with `true` when the category was saved.
class CategoryFormScreen extends StatelessWidget {
  const CategoryFormScreen({super.key, this.category});

  final CategoryEntity? category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CategoryFormCubit>(),
      child: _CategoryFormView(category: category),
    );
  }
}

class _CategoryFormView extends StatefulWidget {
  const _CategoryFormView({required this.category});

  final CategoryEntity? category;

  @override
  State<_CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<_CategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CategoryFormCubit>().submit(
      slug: widget.category?.slug,
      name: _nameController.text,
      description: _descriptionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEdit
            ? CategoriesStrings.editTitle
            : CategoriesStrings.addTitle,
        showBack: true,
      ),
      body: BlocConsumer<CategoryFormCubit, CategoryFormState>(
        listener: (context, state) {
          if (state is CategoryFormSuccess) {
            Navigator.pop(context, true);
          } else if (state is CategoryFormFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CategoryFormSubmitting;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: CategoriesStrings.nameLabel,
                      hint: CategoriesStrings.nameHint,
                      controller: _nameController,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.notEmpty(
                        value,
                        fieldName: CategoriesStrings.nameLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: CategoriesStrings.descriptionLabel,
                      hint: CategoriesStrings.descriptionHint,
                      controller: _descriptionController,
                      isOptional: true,
                      maxLines: 3,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      text: _isEdit
                          ? CategoriesStrings.saveChanges
                          : CategoriesStrings.addAction,
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
