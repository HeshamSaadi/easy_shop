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
  // Register
  static const createAccount = 'Create Account';
  static const continueLabel = 'Continue';
  static const accountCreated = 'Account created. Sign in to continue.';
  static const stepPersonal = 'Personal';
  static const stepBusiness = 'Business';
  static const stepSecurity = 'Security';
  static const headingPersonal = 'Personal Information';
  static const headingBusiness = 'Business Information';
  static const headingSecurity = 'Security';
  static const fullName = 'Full Name';
  static const fullNameHint = 'Ahmed Khalil';
  static const phoneNumber = 'Phone Number';
  static const phoneHint = '+20 100 000 0000';
  static const nationalId = 'National ID';
  static const nationalIdHint = '14-digit national ID';
  static const businessName = 'Business Name';
  static const businessNameHint = 'My Digital Store';
  static const businessAddress = 'Business Address';
  static const businessAddressHint = 'Street, City';
  static const storeLocation = 'Store Location';
  static const tapToSetLocation = 'Tap to set store location';
  static const locationSet = 'Location set';
  static const commercialRegister = 'Commercial Register';
  static const uploadCommercialRegister = 'Upload Commercial Register';
  static const taxCard = 'Tax Card';
  static const uploadTaxCard = 'Upload Tax Card';
  static const profilePicture = 'Profile Picture';
  static const uploadPhoto = 'Upload photo';
  static const createPasswordHint = 'Create a strong password';
  static const confirmPassword = 'Confirm Password';
  static const repeatPasswordHint = 'Repeat your password';

  static String stepProgress(int current, int total, String title) =>
      'Step $current of $total — $title';
}
