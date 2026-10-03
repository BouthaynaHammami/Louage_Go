class AuthException implements Exception {
  static const invalidCredentials = 'invalid-credentials';
  static const emailAlreadyUsed = 'email-already-used';
  static const weakPassword = 'weak-password';
  static const invalidEmail = 'invalid-email';
  static const phoneAlreadyUsed = 'phone-already-used';
  static const invalidPhone = 'invalid-phone';
  static const otpInvalid = 'otp-invalid';
  static const otpExpired = 'otp-expired';
  static const otpTooManyAttempts = 'otp-too-many-attempts';
  static const otpResendTooSoon = 'otp-resend-too-soon';
  static const phoneNotRegistered = 'phone-not-registered';
  static const accountBlocked = 'account-blocked';
  static const invalidResetCode = 'invalid-reset-code';
  static const profileUnavailable = 'profile-unavailable';

  final String code;

  const AuthException(this.code);

  @override
  String toString() => 'AuthException($code)';
}
