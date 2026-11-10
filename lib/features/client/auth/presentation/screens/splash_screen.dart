import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/widgets/app_splash_view.dart';
import 'package:easy_shop/features/client/auth/presentation/constants/auth_strings.dart';
import 'package:flutter/material.dart';

/// First screen of the Client app. The router shows it while the saved
/// session is being checked.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSplashView(
      backgroundColor: AppColors.clientPrimary,
      title: AuthStrings.splashTitle,
      subtitle: AuthStrings.splashSubtitle,
    );
  }
}
