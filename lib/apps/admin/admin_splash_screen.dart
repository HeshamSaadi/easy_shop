import 'package:easy_shop/apps/admin/admin_strings.dart';
import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/widgets/app_splash_view.dart';
import 'package:flutter/material.dart';

/// First screen of the Admin app. The router shows it while the saved
/// session is being checked, then moves to login or home by itself.
class AdminSplashScreen extends StatelessWidget {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSplashView(
      backgroundColor: AppColors.primary,
      title: AdminStrings.splashTitle,
      subtitle: AdminStrings.splashSubtitle,
    );
  }
}
