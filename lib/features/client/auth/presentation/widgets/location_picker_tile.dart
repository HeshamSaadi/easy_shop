import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class LocationPickerTile extends StatelessWidget {
  const LocationPickerTile({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.summary,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final VoidCallback onTap;

  /// Null until a location is picked.
  final String? summary;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = summary;
    final hasValue = value != null;
    final radius = BorderRadius.circular(AppRadius.lg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: radius,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: radius,
            ),
            child: Row(
              children: [
                Icon(
                  hasValue ? Icons.check_circle : Icons.location_on_outlined,
                  color: hasValue
                      ? AppColors.clientPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: textTheme.bodyMedium?.copyWith(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
