import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/picker_field.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditDocumentFields extends StatelessWidget {
  const EditDocumentFields({
    super.key,
    required this.profile,
    required this.pickDocument,
  });

  final ProfileEntity profile;
  final PickFile pickDocument;

  Future<void> _pickCommercialRegister(BuildContext context) async {
    final cubit = context.read<EditProfileCubit>();
    final path = await pickDocument();
    if (path == null || !context.mounted) return;
    cubit.setCommercialRegister(path);
  }

  Future<void> _pickTaxCard(BuildContext context) async {
    final cubit = context.read<EditProfileCubit>();
    final path = await pickDocument();
    if (path == null || !context.mounted) return;
    cubit.setTaxCard(path);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((EditProfileCubit c) => c.state.isLoading);
    final commercialRegister = context.select(
      (EditProfileCubit c) => c.state.commercialRegisterPath,
    );
    final taxCard = context.select((EditProfileCubit c) => c.state.taxCardPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        PickerField.file(
          label: ProfileStrings.commercialRegister,
          placeholder: profile.hasCommercialRegister
              ? ProfileStrings.replaceCommercialRegister
              : ProfileStrings.uploadCommercialRegister,
          isOptional: true,
          filePath: commercialRegister,
          onTap: isLoading ? null : () => _pickCommercialRegister(context),
        ),
        PickerField.file(
          label: ProfileStrings.taxCard,
          placeholder: profile.hasTaxCard
              ? ProfileStrings.replaceTaxCard
              : ProfileStrings.uploadTaxCard,
          isOptional: true,
          filePath: taxCard,
          onTap: isLoading ? null : () => _pickTaxCard(context),
        ),
      ],
    );
  }
}
