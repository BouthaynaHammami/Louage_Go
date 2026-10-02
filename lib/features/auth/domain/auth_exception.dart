class AuthException implements Exception {
  static const invalidCredentials = 'invalid-credentials';
  static const emailAlreadyUsed = 'email-already-used';
  static const weakPassword = 'weak-password';
  static const invalidEmail = 'invalid-email';
  static const phoneAlreadyUsed = 'phone-already-used';
  static const accountBlocked = 'account-blocked';
  static const invalidResetCode = 'invalid-reset-code';

  final String code;

  const AuthException(this.code);

  @override
  String toString() => 'AuthException($code)';
}
