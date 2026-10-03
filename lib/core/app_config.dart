class AppConfig {
  const AppConfig._();

  static const showDemoOtp = bool.fromEnvironment(
    'SHOW_DEMO_OTP',
    defaultValue: true,
  );

  static const googleSignInEnabled = bool.fromEnvironment(
    'GOOGLE_SIGN_IN_ENABLED',
    defaultValue: false,
  );
}
