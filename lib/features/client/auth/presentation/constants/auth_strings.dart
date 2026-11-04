/// Texts that belong to the Client auth screens only.
/// Texts shared by both apps live in `core/utils/app_strings.dart`.
abstract final class AuthStrings {
  // Login Screen
  static const String welcomeBack = 'Welcome Back!';
  static const String loginSubtitle = 'Sign in to continue shopping';
  static const String emailLabel = 'Email';
  static const String emailHint = 'your@email.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String signIn = 'Sign In';
  static const String newUser = 'New user?';
  static const String createAccount = 'Create account';

  // OTP Screen
  static const String verifyEmail = 'Verify Email';
  static const String checkYourEmail = 'Check your email';
  static const String otpSubtitle =
      'We sent a 6-digit verification code to your email address.';
  static const String codeExpiresIn = 'Code expires in';
  static const String codeExpired = 'Code expired. Request a new one.';
  static const String verify = 'Verify';
  static const String resendCode = 'Resend Code';
  static const String otpResent = 'A new code was sent to your email.';

  // Register Screen
  static const String createYourAccount = 'Create Your Account';
  static const String registerSubtitle = 'Join us and start shopping';
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Ahmed Khalil';
  static const String phoneNumber = 'Phone Number';
  static const String phoneHint = '+20 100 000 0000';
  static const String createPasswordHint = 'Create a strong password';
  static const String confirmPassword = 'Confirm Password';
  static const String repeatPasswordHint = 'Repeat your password';
  static const String profilePicture = 'Profile Picture (Optional)';
  static const String uploadPhoto = 'Upload photo';
  static const String register = 'Register';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signInHere = 'Sign in here';

  // Success Messages
  static const String accountCreated = 'Account created successfully!';
  static const String loginSuccess = 'Login successful!';
  static const String otpVerified = 'Email verified successfully!';
}
