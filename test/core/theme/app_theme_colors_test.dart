import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_theme.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mutedText follows the mode', () {
    expect(AppTheme.lightTheme.mutedText, AppColors.textSecondary);
    expect(AppTheme.darkTheme.mutedText, AppColors.darkTextSecondary);
  });

  test('client themes keep the same muted text', () {
    expect(AppTheme.clientLightTheme.mutedText, AppColors.textSecondary);
    expect(AppTheme.clientDarkTheme.mutedText, AppColors.darkTextSecondary);
  });
}
