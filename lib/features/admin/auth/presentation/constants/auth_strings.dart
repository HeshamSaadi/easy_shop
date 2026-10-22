/// Texts that belong to the Admin auth screens only.
/// Texts shared by both apps live in `core/utils/app_strings.dart`.
abstract final class AuthStrings {
  static const String forBusiness = 'FOR BUSINESS';
  static const String welcomeBack = 'Welcome back';
  static const String loginSubtitle = 'Sign in to manage your store';
  static const String emailLabel = 'Email';
  static const String emailHint = 'your@business.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String signIn = 'Sign In';
  static const String newMerchant = 'New merchant?';
  static const String createMerchantAccount = 'Create merchant account';
  static const String verifyEmail = 'Verify Email';
  static const String checkYourEmail = 'Check your email';
  static const String otpSubtitle =
      'We sent a 6-digit verification code to your registered email address.';
  static const String codeExpiresIn = 'Code expires in';
  static const String codeExpired = 'Code expired. Request a new one.';
  static const String verify = 'Verify';
  static const String resendCode = 'Resend Code';
  static const String otpResent = 'A new code was sent to your email.';
}
