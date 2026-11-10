import 'package:easy_shop/core/theme/app_theme_colors.dart';

import 'dart:async';

import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/client/auth/presentation/constants/auth_strings.dart';
import 'package:flutter/material.dart';

class VerifiedScreen extends StatefulWidget {
  const VerifiedScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> {
  static const Duration _delay = Duration(seconds: 2);
  static const double _iconSize = 96;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_delay, widget.onContinue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: _iconSize,
                color: AppColors.clientPrimary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                AuthStrings.verifiedTitle,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AuthStrings.verifiedSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
