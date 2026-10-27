import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/app_strings.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.icon,
    required this.onTap,
    this.value,
    this.errorText,
    this.isOptional = false,
  });

  PickerField.file({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onTap,
    String? filePath,
    this.icon = Icons.upload_file_outlined,
    this.errorText,
    this.isOptional = false,
  }) : value = filePath == null ? null : _fileName(filePath);

  static final RegExp _separators = RegExp(r'[\\/]');

  static String _fileName(String path) => path.split(_separators).last;

  final String label;
  final String placeholder;
  final IconData icon;
  final VoidCallback? onTap;
  final String? value;
  final String? errorText;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (isOptional)
                TextSpan(
                  text: ' ${AppStrings.optional}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          text: value ?? placeholder,
          icon: value == null ? icon : Icons.check_circle_outline,
          isOutlined: true,
          onPressed: onTap,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
