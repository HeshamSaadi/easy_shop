import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';
import 'package:easy_shop/core/widgets/app_avatar.dart';

//! The orange header
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, this.adminName, this.storeName});

  final String? adminName;
  final String? storeName;

  /// How far the stats card rises into the orange header.
  static const double overlap = AppSpacing.xxxxl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final softText = onPrimary.withValues(alpha: 0.85);
    final circleColor = onPrimary.withValues(alpha: 0.2);
    final topInset = MediaQuery.paddingOf(context).top;
    final name = adminName;
    final store = storeName;

    return Container(
      width: double.infinity,
      color: theme.colorScheme.primary,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxxl,
        topInset + AppSpacing.xl,
        AppSpacing.lg,
        overlap + AppSpacing.lg,
      ),
      child: Row(
        children: [
          AppAvatar(backgroundColor: circleColor, iconColor: onPrimary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HomeStrings.greetingForHour(DateTime.now().hour),
                  style: theme.textTheme.bodyMedium?.copyWith(color: softText),
                ),
                if (name != null)
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: onPrimary,
                    ),
                  ),
                if (store != null)
                  Text(
                    store,
                    style: theme.textTheme.bodySmall?.copyWith(color: softText),
                  ),
              ],
            ),
          ),
          // The bell does nothing yet: there is no notifications feature
          IconButton.filled(
            onPressed: null,
            style: IconButton.styleFrom(
              backgroundColor: circleColor,
              disabledBackgroundColor: circleColor,
            ),
            icon: Icon(Icons.notifications_none, color: onPrimary),
          ),
        ],
      ),
    );
  }
}
