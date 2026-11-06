import 'package:easy_shop/core/location/location_messages.dart';
import 'package:easy_shop/core/location/location_permission_status.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/app_strings.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Shown instead of the map when location cannot be used.
class PermissionPrompt extends StatelessWidget {
  const PermissionPrompt({
    super.key,
    required this.status,
    required this.onPrimaryPressed,
    required this.onRetryPressed,
  });

  final LocationPermissionStatus status;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // After the user fixes things in settings, they come back and retry.
    final showRetry = status != LocationPermissionStatus.denied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: AppSizes.iconXl,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(text: _primaryLabel, onPressed: onPrimaryPressed),
            if (showRetry) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: AppStrings.tryAgain,
                isOutlined: true,
                onPressed: onRetryPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _message => switch (status) {
    LocationPermissionStatus.denied ||
    LocationPermissionStatus.granted => LocationMessages.permissionDenied,
    LocationPermissionStatus.deniedForever =>
      LocationMessages.permissionDeniedForever,
    LocationPermissionStatus.serviceDisabled =>
      LocationMessages.serviceDisabled,
  };

  String get _primaryLabel => switch (status) {
    LocationPermissionStatus.denied ||
    LocationPermissionStatus.granted => LocationMessages.permissionAllow,
    LocationPermissionStatus.deniedForever => LocationMessages.openSettings,
    LocationPermissionStatus.serviceDisabled =>
      LocationMessages.openLocationSettings,
  };
}
