import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

/// "Good morning," with the admin name and store name when they are known.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, this.adminName, this.storeName});

  final String? adminName;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = adminName;
    final store = storeName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeStrings.greetingForHour(DateTime.now().hour),
          style: theme.textTheme.bodyMedium,
        ),
        if (name != null) Text(name, style: theme.textTheme.headlineMedium),
        if (store != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(store, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
