abstract final class AuthStrings {
  static const welcomeBack = 'Welcome back';
  static const loginSubtitle = 'Sign in to manage your store';
  static const forBusiness = 'FOR BUSINESS';
  static const email = 'Email';
  static const emailHint = 'your@business.com';
  static const password = 'Password';
  static const passwordHint = 'Enter your password';
  static const signIn = 'Sign In';
  static const newMerchant = 'New merchant? ';
  static const createMerchantAccount = 'Create merchant account';
  static const verifyEmail = 'Verify Email';
  static const checkYourEmail = 'Check your email';
  static const otpSentMessage =
      'We sent a 6-digit verification code to your registered email address.';
  static const codeExpiresIn = 'Code expires in ';
  static const codeExpired = 'Code expired. Request a new one.';
  static const verify = 'Verify';
  static const resendCode = 'Resend Code';
  static const otpResent = 'A new code was sent to your email.';
  static const enterFullCode = 'Enter the 6-digit code.';
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
