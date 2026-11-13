import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/features/client/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final tint = primary.withValues(alpha: AppOpacity.tint);
    final name = userName;

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                HomeStrings.greetingForHour(DateTime.now().hour).toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.mutedText,
                ),
              ),
              if (name != null)
                Text(
                  '$name ${HomeStrings.wave}',
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        IconButton.filled(
          onPressed: null,
          style: IconButton.styleFrom(
            backgroundColor: tint,
            disabledBackgroundColor: tint,
          ),
          icon: Icon(
            Icons.notifications_none,
            color: primary,
            size: AppSizes.iconMd,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _InitialsAvatar(name: name),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  static const double _size = 40;

  final String? name;

  String get _initials {
    final words = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    return words
        .map((word) => String.fromCharCode(word.runes.first))
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final initials = _initials;

    return CircleAvatar(
      radius: _size / 2,
      backgroundColor: theme.colorScheme.primary,
      child: initials.isEmpty
          ? Icon(Icons.person_outline, size: AppSizes.iconMd, color: onPrimary)
          : Text(
              initials,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
