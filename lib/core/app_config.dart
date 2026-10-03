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

  static const legalVersion = String.fromEnvironment(
    'LEGAL_VERSION',
    defaultValue: '1.0',
  );
  static const legalUpdatedAt = '2026-10-03';
  static const legalContactEmail = String.fromEnvironment(
    'LEGAL_CONTACT_EMAIL',
    defaultValue: 'contact@example.invalid',
  );
  static const legalContactPhone = String.fromEnvironment(
    'LEGAL_CONTACT_PHONE',
    defaultValue: '+216 XX XXX XXX',
  );

  // À remplacer par les coordonnées réelles de l'équipe support.
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@example.invalid',
  );
  static const supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+216 XX XXX XXX',
  );
  static const supportWhatsapp = String.fromEnvironment(
    'SUPPORT_WHATSAPP',
    defaultValue: '216XXXXXXXX',
  );
}
