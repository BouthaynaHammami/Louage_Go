import '../../../l10n/generated/app_localizations.dart';
import '../domain/auth_exception.dart';

String authErrorMessage(AppLocalizations l10n, String code) {
  switch (code) {
    case AuthException.invalidCredentials:
    case 'invalid-credential':
    case 'user-not-found':
    case 'wrong-password':
      return l10n.authInvalidCredentials;
    case AuthException.emailAlreadyUsed:
    case 'email-already-in-use':
      return l10n.authEmailAlreadyUsed;
    case AuthException.weakPassword:
      return l10n.authWeakPassword;
    case AuthException.invalidEmail:
      return l10n.authInvalidEmail;
    case AuthException.phoneAlreadyUsed:
      return l10n.authPhoneAlreadyUsed;
    case AuthException.invalidPhone:
      return l10n.authInvalidPhone;
    case AuthException.otpInvalid:
      return l10n.authOtpInvalid;
    case AuthException.otpExpired:
      return l10n.authOtpExpired;
    case AuthException.otpTooManyAttempts:
      return l10n.authOtpTooManyAttempts;
    case AuthException.otpResendTooSoon:
      return l10n.authOtpResendTooSoon;
    case AuthException.phoneNotRegistered:
      return l10n.authPhoneNotRegistered;
    case AuthException.accountBlocked:
      return l10n.authAccountBlocked;
    case AuthException.invalidResetCode:
      return l10n.authInvalidResetCode;
    case AuthException.profileUnavailable:
      return l10n.authProfileUnavailable;
    default:
      return l10n.authUnexpectedError;
  }
}
