import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @authInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailAlreadyUsed.
  ///
  /// In fr, this message translates to:
  /// **'Cet email est déjà utilisé'**
  String get authEmailAlreadyUsed;

  /// No description provided for @authWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible (6 caractères minimum)'**
  String get authWeakPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide'**
  String get authInvalidEmail;

  /// No description provided for @authPhoneAlreadyUsed.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro de téléphone est déjà utilisé'**
  String get authPhoneAlreadyUsed;

  /// No description provided for @authInvalidPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone invalide'**
  String get authInvalidPhone;

  /// No description provided for @authOtpInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification incorrect'**
  String get authOtpInvalid;

  /// No description provided for @authOtpExpired.
  ///
  /// In fr, this message translates to:
  /// **'Le code de vérification a expiré'**
  String get authOtpExpired;

  /// No description provided for @authOtpTooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Demandez un nouveau code'**
  String get authOtpTooManyAttempts;

  /// No description provided for @authOtpResendTooSoon.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez attendre avant de demander un nouveau code'**
  String get authOtpResendTooSoon;

  /// No description provided for @authPhoneNotRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte n’est associé à ce numéro'**
  String get authPhoneNotRegistered;

  /// No description provided for @authAccountBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est bloqué'**
  String get authAccountBlocked;

  /// No description provided for @authProfileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le profil est introuvable.'**
  String get authProfileUnavailable;

  /// No description provided for @authUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur d’authentification est survenue.'**
  String get authUnexpectedError;

  /// No description provided for @authResetCodeGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Code de réinitialisation : {code}'**
  String authResetCodeGenerated(String code);

  /// No description provided for @authInvalidResetCode.
  ///
  /// In fr, this message translates to:
  /// **'Code de réinitialisation incorrect ou expiré.'**
  String get authInvalidResetCode;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get authResetEmailLabel;

  /// No description provided for @authResetCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu'**
  String get authResetCodeLabel;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get authNewPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get authPasswordMismatch;

  /// No description provided for @authContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get authContinue;

  /// No description provided for @authCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get authCancel;

  /// No description provided for @authResetAction.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get authResetAction;

  /// No description provided for @authResetCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé'**
  String get authResetCompleted;

  /// No description provided for @splashSlogan.
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre place en un clic'**
  String get splashSlogan;

  /// No description provided for @onboardingReserveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservez votre trajet'**
  String get onboardingReserveTitle;

  /// No description provided for @onboardingReserveBody.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre destination et votre horaire en quelques instants.'**
  String get onboardingReserveBody;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre départ'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackBody.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez les informations utiles sur votre voyage au même endroit.'**
  String get onboardingTrackBody;

  /// No description provided for @onboardingPayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Payez simplement'**
  String get onboardingPayTitle;

  /// No description provided for @onboardingPayBody.
  ///
  /// In fr, this message translates to:
  /// **'Préparez votre réservation et voyagez l’esprit tranquille.'**
  String get onboardingPayBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'LouageGo'**
  String get appTitle;

  /// No description provided for @commonLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get commonLoading;

  /// No description provided for @statusWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusWaiting;

  /// No description provided for @statusFull.
  ///
  /// In fr, this message translates to:
  /// **'Complet'**
  String get statusFull;

  /// No description provided for @statusDeparted.
  ///
  /// In fr, this message translates to:
  /// **'Parti'**
  String get statusDeparted;

  /// No description provided for @statusArrived.
  ///
  /// In fr, this message translates to:
  /// **'Arrivé'**
  String get statusArrived;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get statusCancelled;

  /// No description provided for @storageUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stockage local indisponible'**
  String get storageUnavailableTitle;

  /// No description provided for @storageUnavailableBody.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les permissions et l’espace disponible, puis redémarrez l’application.'**
  String get storageUnavailableBody;

  /// No description provided for @authWelcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, {name}'**
  String authWelcomeMessage(String name);

  /// No description provided for @loginWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur LouageGo'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get loginSubtitle;

  /// No description provided for @loginMethodPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get loginMethodPhone;

  /// No description provided for @loginMethodEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginMethodEmail;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get loginPhoneLabel;

  /// No description provided for @loginSendCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code'**
  String get loginSendCode;

  /// No description provided for @loginEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @loginAccountInaccessible.
  ///
  /// In fr, this message translates to:
  /// **'Compte inaccessible ?'**
  String get loginAccountInaccessible;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginGoogleUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'La connexion Google n’est pas configurée.'**
  String get loginGoogleUnavailable;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerRolePrompt.
  ///
  /// In fr, this message translates to:
  /// **'Je suis...'**
  String get registerRolePrompt;

  /// No description provided for @registerPassengerRole.
  ///
  /// In fr, this message translates to:
  /// **'Passager'**
  String get registerPassengerRole;

  /// No description provided for @registerDriverRole.
  ///
  /// In fr, this message translates to:
  /// **'Chauffeur'**
  String get registerDriverRole;

  /// No description provided for @registerNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerNameLabel;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get registerPhoneLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailOptional.
  ///
  /// In fr, this message translates to:
  /// **'Email (facultatif)'**
  String get registerEmailOptional;

  /// No description provided for @registerUseEmail.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser un email'**
  String get registerUseEmail;

  /// No description provided for @registerUsePhone.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser un téléphone'**
  String get registerUsePhone;

  /// No description provided for @registerAcceptTerms.
  ///
  /// In fr, this message translates to:
  /// **'J’accepte'**
  String get registerAcceptTerms;

  /// No description provided for @registerTermsLink.
  ///
  /// In fr, this message translates to:
  /// **'les conditions d’utilisation'**
  String get registerTermsLink;

  /// No description provided for @registerAnd.
  ///
  /// In fr, this message translates to:
  /// **'et'**
  String get registerAnd;

  /// No description provided for @registerPrivacyLink.
  ///
  /// In fr, this message translates to:
  /// **'la politique de confidentialité'**
  String get registerPrivacyLink;

  /// No description provided for @registerConsentRequired.
  ///
  /// In fr, this message translates to:
  /// **'Acceptez les conditions et la politique pour continuer.'**
  String get registerConsentRequired;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get registerSubmit;

  /// No description provided for @registerSignInLink.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get registerSignInLink;

  /// No description provided for @registerPasswordStrengthLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité du mot de passe'**
  String get registerPasswordStrengthLabel;

  /// No description provided for @registerPasswordStrengthWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get registerPasswordStrengthWeak;

  /// No description provided for @registerPasswordStrengthMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get registerPasswordStrengthMedium;

  /// No description provided for @registerPasswordStrengthStrong.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get registerPasswordStrengthStrong;

  /// No description provided for @formRequiredFields.
  ///
  /// In fr, this message translates to:
  /// **'Remplissez tous les champs'**
  String get formRequiredFields;

  /// No description provided for @passwordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordMismatch;

  /// No description provided for @passwordReveal.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get passwordReveal;

  /// No description provided for @passwordHide.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get passwordHide;

  /// No description provided for @otpPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du code'**
  String get otpPageTitle;

  /// No description provided for @otpCodeSentTo.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code envoyé au {phone}'**
  String otpCodeSentTo(String phone);

  /// No description provided for @otpVerifyAction.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le code'**
  String get otpVerifyAction;

  /// No description provided for @otpResendAction.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get otpResendAction;

  /// No description provided for @otpResendCountdown.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds} s'**
  String otpResendCountdown(int seconds);

  /// No description provided for @otpDemoCode.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo : votre code est {code}'**
  String otpDemoCode(String code);

  /// No description provided for @otpCodeResent.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau code a été généré.'**
  String get otpCodeResent;

  /// No description provided for @otpCodeVerified.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone vérifié.'**
  String get otpCodeVerified;

  /// No description provided for @legalTermsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d’utilisation'**
  String get legalTermsTitle;

  /// No description provided for @legalTermsBody.
  ///
  /// In fr, this message translates to:
  /// **'LouageGo est un projet universitaire de réservation de louages. En créant un compte, vous confirmez l’exactitude des informations fournies et vous engagez à utiliser le service dans le respect des règles applicables.\n\nLes réservations sont soumises à la disponibilité des trajets et des places.'**
  String get legalTermsBody;

  /// No description provided for @legalUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour le 3 octobre 2026'**
  String get legalUpdatedAt;

  /// No description provided for @legalTermsSectionServiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Utilisation du service'**
  String get legalTermsSectionServiceTitle;

  /// No description provided for @legalTermsSectionServiceBody.
  ///
  /// In fr, this message translates to:
  /// **'LouageGo facilite la consultation et la réservation de trajets en louage. L’utilisateur s’engage à fournir des informations exactes, à protéger ses identifiants et à utiliser le service conformément aux lois applicables.'**
  String get legalTermsSectionServiceBody;

  /// No description provided for @legalTermsSectionBookingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservations et trajets'**
  String get legalTermsSectionBookingsTitle;

  /// No description provided for @legalTermsSectionBookingsBody.
  ///
  /// In fr, this message translates to:
  /// **'Les réservations dépendent de la disponibilité des trajets et des places. Les horaires et informations affichés peuvent être mis à jour. Toute annulation reste soumise aux conditions indiquées dans l’application.'**
  String get legalTermsSectionBookingsBody;

  /// No description provided for @legalTermsSectionDemoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Version de démonstration'**
  String get legalTermsSectionDemoTitle;

  /// No description provided for @legalTermsSectionDemoBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette application est un projet universitaire. Certaines fonctionnalités sont simulées et ne constituent pas une garantie de transport ou de paiement réel.'**
  String get legalTermsSectionDemoBody;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacyBody.
  ///
  /// In fr, this message translates to:
  /// **'Dans cette version de démonstration, les informations du compte sont stockées localement sur cet appareil. Aucun SMS réel n’est envoyé : le code de vérification est simulé.\n\nLes données ne sont pas transmises à Firebase.'**
  String get legalPrivacyBody;

  /// No description provided for @legalPrivacySectionDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données enregistrées'**
  String get legalPrivacySectionDataTitle;

  /// No description provided for @legalPrivacySectionDataBody.
  ///
  /// In fr, this message translates to:
  /// **'Les informations de profil, préférences, favoris et données nécessaires au fonctionnement des réservations sont enregistrées dans le stockage local de l’application.'**
  String get legalPrivacySectionDataBody;

  /// No description provided for @legalPrivacySectionUseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Utilisation des données'**
  String get legalPrivacySectionUseTitle;

  /// No description provided for @legalPrivacySectionUseBody.
  ///
  /// In fr, this message translates to:
  /// **'Les données servent à afficher le profil, gérer les préférences et faciliter l’utilisation des fonctions de réservation. Cette version de démonstration ne transmet pas les données à Firebase.'**
  String get legalPrivacySectionUseBody;

  /// No description provided for @legalPrivacySectionControlTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle et suppression'**
  String get legalPrivacySectionControlTitle;

  /// No description provided for @legalPrivacySectionControlBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez modifier vos informations depuis votre profil ou demander la suppression de votre compte. Les réservations et avis historiques peuvent être conservés sous forme anonymisée.'**
  String get legalPrivacySectionControlBody;

  /// No description provided for @legalPrivacySectionDemoTitle.
  ///
  /// In fr, this message translates to:
  /// **'SMS de vérification'**
  String get legalPrivacySectionDemoTitle;

  /// No description provided for @legalPrivacySectionDemoBody.
  ///
  /// In fr, this message translates to:
  /// **'Aucun SMS réel n’est envoyé dans cette version : le code de vérification est simulé.'**
  String get legalPrivacySectionDemoBody;

  /// No description provided for @settingsAccountSection.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccountSection;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In fr, this message translates to:
  /// **'Préférences de l’application'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get settingsSecuritySection;

  /// No description provided for @settingsSupportSection.
  ///
  /// In fr, this message translates to:
  /// **'Aide et informations'**
  String get settingsSupportSection;

  /// No description provided for @profileFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get profileFirstNameLabel;

  /// No description provided for @profileLastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get profileLastNameLabel;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get profileSignOutMessage;

  /// No description provided for @helpSupportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide et assistance'**
  String get helpSupportTitle;

  /// No description provided for @helpFaqSection.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes'**
  String get helpFaqSection;

  /// No description provided for @helpFaqBookingQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Comment trouver un trajet ?'**
  String get helpFaqBookingQuestion;

  /// No description provided for @helpFaqBookingAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre ville de départ et votre destination sur l’écran d’accueil. Les trajets disponibles s’affichent ensuite.'**
  String get helpFaqBookingAnswer;

  /// No description provided for @helpFaqPaymentQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Comment réserver une place ?'**
  String get helpFaqPaymentQuestion;

  /// No description provided for @helpFaqPaymentAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez un trajet disponible pour consulter ses détails et les actions de réservation proposées.'**
  String get helpFaqPaymentAnswer;

  /// No description provided for @helpFaqPhoneQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Comment modifier mon numéro ?'**
  String get helpFaqPhoneQuestion;

  /// No description provided for @helpFaqPhoneAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Dans votre profil, ouvrez Modifier le profil puis choisissez Changer de numéro. La vérification se fait par code OTP.'**
  String get helpFaqPhoneAnswer;

  /// No description provided for @helpHowItWorksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment fonctionne LouageGo'**
  String get helpHowItWorksTitle;

  /// No description provided for @helpHowItWorksBody.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre départ et votre destination, consultez les trajets disponibles puis ouvrez un trajet pour voir ses informations. Les chauffeurs peuvent gérer leur espace depuis leur profil.'**
  String get helpHowItWorksBody;

  /// No description provided for @helpContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get helpContactTitle;

  /// No description provided for @helpContactSupport.
  ///
  /// In fr, this message translates to:
  /// **'Contacter l’assistance'**
  String get helpContactSupport;

  /// No description provided for @helpEmailCopied.
  ///
  /// In fr, this message translates to:
  /// **'Adresse d’assistance copiée.'**
  String get helpEmailCopied;

  /// No description provided for @helpReportProblem.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un problème'**
  String get helpReportProblem;

  /// No description provided for @helpReportHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez le problème rencontré'**
  String get helpReportHint;

  /// No description provided for @helpCopyReport.
  ///
  /// In fr, this message translates to:
  /// **'Copier le signalement'**
  String get helpCopyReport;

  /// No description provided for @helpReportCopied.
  ///
  /// In fr, this message translates to:
  /// **'Signalement copié. Vous pouvez l’envoyer à l’assistance.'**
  String get helpReportCopied;

  /// No description provided for @profilePrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get profilePrivacy;

  /// No description provided for @profileEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEditTitle;

  /// No description provided for @profileCityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get profileCityLabel;

  /// No description provided for @profileCityNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ville'**
  String get profileCityNotSet;

  /// No description provided for @profileChooseGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get profileChooseGallery;

  /// No description provided for @profileChooseCamera.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get profileChooseCamera;

  /// No description provided for @profileChangePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get profileChangePhoto;

  /// No description provided for @profilePhotoError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de sélectionner ou d’enregistrer la photo.'**
  String get profilePhotoError;

  /// No description provided for @profilePhotoCleanupWarning.
  ///
  /// In fr, this message translates to:
  /// **'Profil enregistré, mais l’ancienne photo n’a pas pu être supprimée.'**
  String get profilePhotoCleanupWarning;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour.'**
  String get profileUpdated;

  /// No description provided for @profileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Profil indisponible.'**
  String get profileUnavailable;

  /// No description provided for @profileSaveAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get profileSaveAction;

  /// No description provided for @profilePhoneUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone mis à jour.'**
  String get profilePhoneUpdated;

  /// No description provided for @profileHelpBody.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes\n\nComment réserver un trajet ? Choisissez votre ville de départ et votre destination, puis sélectionnez un trajet disponible.\n\nComment modifier mon numéro ? Ouvrez Modifier le profil, puis choisissez Changer de numéro. Un code de vérification sera demandé.\n\nComment protéger mon compte ? Gardez votre téléphone et vos informations de connexion sous votre contrôle.'**
  String get profileHelpBody;

  /// No description provided for @deleteAccountAction.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte ?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est définitive. Vos favoris, notifications et données de profil seront supprimés. Les réservations et avis seront conservés sous forme anonymisée.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmationWord.
  ///
  /// In fr, this message translates to:
  /// **'SUPPRIMER'**
  String get deleteAccountConfirmationWord;

  /// No description provided for @deleteAccountTypeConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez {word} pour confirmer.'**
  String deleteAccountTypeConfirmation(String word);

  /// No description provided for @deleteAccountConfirmationMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Le mot saisi ne correspond pas.'**
  String get deleteAccountConfirmationMismatch;

  /// No description provided for @deleteAccountCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte a été supprimé.'**
  String get deleteAccountCompleted;

  /// No description provided for @pageNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Page introuvable'**
  String get pageNotFound;

  /// No description provided for @searchPageNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Recherche introuvable'**
  String get searchPageNotFound;

  /// No description provided for @passengerNavHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get passengerNavHome;

  /// No description provided for @passengerNavTrips.
  ///
  /// In fr, this message translates to:
  /// **'Mes voyages'**
  String get passengerNavTrips;

  /// No description provided for @passengerNavFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get passengerNavFavorites;

  /// No description provided for @passengerNavProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get passengerNavProfile;

  /// No description provided for @driverNavHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get driverNavHome;

  /// No description provided for @driverNavQueue.
  ///
  /// In fr, this message translates to:
  /// **'File'**
  String get driverNavQueue;

  /// No description provided for @driverNavScan.
  ///
  /// In fr, this message translates to:
  /// **'Scan'**
  String get driverNavScan;

  /// No description provided for @driverNavEarnings.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get driverNavEarnings;

  /// No description provided for @driverNavProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get driverNavProfile;

  /// No description provided for @adminNavDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get adminNavDashboard;

  /// No description provided for @adminNavStations.
  ///
  /// In fr, this message translates to:
  /// **'Stations'**
  String get adminNavStations;

  /// No description provided for @adminNavDrivers.
  ///
  /// In fr, this message translates to:
  /// **'Chauffeurs'**
  String get adminNavDrivers;

  /// No description provided for @adminNavUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get adminNavUsers;

  /// No description provided for @adminNavReports.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get adminNavReports;

  /// No description provided for @adminNavNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get adminNavNotifications;

  /// No description provided for @adminMenuTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminMenuTitle;

  /// No description provided for @driverQueueTitle.
  ///
  /// In fr, this message translates to:
  /// **'File de départ'**
  String get driverQueueTitle;

  /// No description provided for @driverScanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un billet'**
  String get driverScanTitle;

  /// No description provided for @driverDocumentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer les documents'**
  String get driverDocumentsTitle;

  /// No description provided for @driverEarningsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get driverEarningsTitle;

  /// No description provided for @driverProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil chauffeur'**
  String get driverProfileTitle;

  /// No description provided for @driverHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Espace chauffeur'**
  String get driverHomeTitle;

  /// No description provided for @driverProfileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Profil chauffeur indisponible'**
  String get driverProfileUnavailable;

  /// No description provided for @sessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée'**
  String get sessionExpired;

  /// No description provided for @driverStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'Compte en attente de validation'**
  String get driverStatusPending;

  /// No description provided for @driverStatusApproved.
  ///
  /// In fr, this message translates to:
  /// **'Compte validé'**
  String get driverStatusApproved;

  /// No description provided for @driverStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Compte rejeté'**
  String get driverStatusRejected;

  /// No description provided for @driverDocumentsRejectedBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre dossier nécessite une mise à jour.'**
  String get driverDocumentsRejectedBody;

  /// No description provided for @driverDocumentsPendingBody.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez vos documents pour activer votre espace chauffeur.'**
  String get driverDocumentsPendingBody;

  /// No description provided for @driverDocumentsSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer les documents'**
  String get driverDocumentsSubmit;

  /// No description provided for @driverMyLouage.
  ///
  /// In fr, this message translates to:
  /// **'Mon louage'**
  String get driverMyLouage;

  /// No description provided for @driverEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get driverEditProfile;

  /// No description provided for @driverNoLouage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun louage associé'**
  String get driverNoLouage;

  /// No description provided for @driverStationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Station actuelle indisponible'**
  String get driverStationUnavailable;

  /// No description provided for @driverSeatFill.
  ///
  /// In fr, this message translates to:
  /// **'Remplissage'**
  String get driverSeatFill;

  /// No description provided for @driverNoActiveTrip.
  ///
  /// In fr, this message translates to:
  /// **'Aucun départ actif'**
  String get driverNoActiveTrip;

  /// No description provided for @driverCurrentTrip.
  ///
  /// In fr, this message translates to:
  /// **'Voyage en cours'**
  String get driverCurrentTrip;

  /// No description provided for @driverFillUpdatesNextTrip.
  ///
  /// In fr, this message translates to:
  /// **'La jauge s’actualisera au prochain départ.'**
  String get driverFillUpdatesNextTrip;

  /// No description provided for @driverPassengersReserved.
  ///
  /// In fr, this message translates to:
  /// **'Passagers réservés'**
  String get driverPassengersReserved;

  /// No description provided for @driverNoBookings.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation'**
  String get driverNoBookings;

  /// No description provided for @driverBookingsAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Les passagers réservés apparaîtront ici.'**
  String get driverBookingsAppearHere;

  /// No description provided for @driverPassengerFallback.
  ///
  /// In fr, this message translates to:
  /// **'Passager'**
  String get driverPassengerFallback;

  /// No description provided for @driverPassengerSeats.
  ///
  /// In fr, this message translates to:
  /// **'{name} — {count} place(s)'**
  String driverPassengerSeats(Object count, Object name);

  /// No description provided for @driverBookingSeatCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} place(s)'**
  String driverBookingSeatCount(Object count);

  /// No description provided for @driverSeatWord.
  ///
  /// In fr, this message translates to:
  /// **'places'**
  String get driverSeatWord;

  /// No description provided for @driverJoinQueue.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre la file'**
  String get driverJoinQueue;

  /// No description provided for @driverLeaveQueue.
  ///
  /// In fr, this message translates to:
  /// **'Quitter la file'**
  String get driverLeaveQueue;

  /// No description provided for @driverLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get driverLogout;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoon;

  /// No description provided for @greetingPassenger.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String greetingPassenger(Object name);

  /// No description provided for @searchPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Où allez-vous ?'**
  String get searchPrompt;

  /// No description provided for @searchChooseBothCities.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le départ et la destination'**
  String get searchChooseBothCities;

  /// No description provided for @searchCitiesMustDiffer.
  ///
  /// In fr, this message translates to:
  /// **'Le départ et la destination doivent être différents'**
  String get searchCitiesMustDiffer;

  /// No description provided for @searchDeparture.
  ///
  /// In fr, this message translates to:
  /// **'Départ'**
  String get searchDeparture;

  /// No description provided for @searchDestination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get searchDestination;

  /// No description provided for @searchDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get searchDate;

  /// No description provided for @searchTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get searchTime;

  /// No description provided for @searchSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchSubmit;

  /// No description provided for @searchSwapRoute.
  ///
  /// In fr, this message translates to:
  /// **'Inverser le trajet'**
  String get searchSwapRoute;

  /// No description provided for @searchLastTrips.
  ///
  /// In fr, this message translates to:
  /// **'Derniers trajets'**
  String get searchLastTrips;

  /// No description provided for @searchFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get searchFavorites;

  /// No description provided for @searchPopularTrips.
  ///
  /// In fr, this message translates to:
  /// **'Trajets populaires'**
  String get searchPopularTrips;

  /// No description provided for @searchNoPopularTrips.
  ///
  /// In fr, this message translates to:
  /// **'Aucun trajet disponible pour le moment'**
  String get searchNoPopularTrips;

  /// No description provided for @searchNearestStation.
  ///
  /// In fr, this message translates to:
  /// **'Station la plus proche'**
  String get searchNearestStation;

  /// No description provided for @searchLocationPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'La localisation sera disponible prochainement.'**
  String get searchLocationPlaceholder;

  /// No description provided for @searchChooseCity.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une ville'**
  String get searchChooseCity;

  /// No description provided for @searchChooseCityPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une ville'**
  String get searchChooseCityPrompt;

  /// No description provided for @searchCitySearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une ville'**
  String get searchCitySearch;

  /// No description provided for @searchNoCityFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ville trouvée'**
  String get searchNoCityFound;

  /// No description provided for @searchCityPickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une ville'**
  String get searchCityPickerTitle;

  /// No description provided for @searchPricePerSeat.
  ///
  /// In fr, this message translates to:
  /// **'{amount} DT / place'**
  String searchPricePerSeat(Object amount);

  /// No description provided for @searchRoutePair.
  ///
  /// In fr, this message translates to:
  /// **'{from} → {to}'**
  String searchRoutePair(Object from, Object to);

  /// No description provided for @searchSeatAvailability.
  ///
  /// In fr, this message translates to:
  /// **'{available} places libres sur {total}'**
  String searchSeatAvailability(Object available, Object total);

  /// No description provided for @searchSeatsFree.
  ///
  /// In fr, this message translates to:
  /// **'{count} places libres'**
  String searchSeatsFree(Object count);

  /// No description provided for @searchSeatsAvailableSemantics.
  ///
  /// In fr, this message translates to:
  /// **'{available} places libres sur {total}'**
  String searchSeatsAvailableSemantics(Object available, Object total);

  /// No description provided for @searchFilterButton.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get searchFilterButton;

  /// No description provided for @searchSortLabel.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get searchSortLabel;

  /// No description provided for @searchSortTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get searchSortTime;

  /// No description provided for @searchSortPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get searchSortPrice;

  /// No description provided for @searchSortSeats.
  ///
  /// In fr, this message translates to:
  /// **'Places'**
  String get searchSortSeats;

  /// No description provided for @searchDayToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd’hui'**
  String get searchDayToday;

  /// No description provided for @searchDayTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get searchDayTomorrow;

  /// No description provided for @searchRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get searchRetry;

  /// No description provided for @searchLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les trajets'**
  String get searchLoadError;

  /// No description provided for @searchNoLouage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun louage pour ce trajet'**
  String get searchNoLouage;

  /// No description provided for @searchAfterRequestedTime.
  ///
  /// In fr, this message translates to:
  /// **'Après l’heure choisie'**
  String get searchAfterRequestedTime;

  /// No description provided for @searchReservation.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get searchReservation;

  /// No description provided for @searchFilterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get searchFilterTitle;

  /// No description provided for @searchMaxPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix maximum : {amount} DT'**
  String searchMaxPrice(Object amount);

  /// No description provided for @searchMinimumSeats.
  ///
  /// In fr, this message translates to:
  /// **'Places minimum : {count}'**
  String searchMinimumSeats(Object count);

  /// No description provided for @searchTimeRange.
  ///
  /// In fr, this message translates to:
  /// **'Horaire : {start} – {end}'**
  String searchTimeRange(Object end, Object start);

  /// No description provided for @searchApplyFilters.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get searchApplyFilters;

  /// No description provided for @louageDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail du louage'**
  String get louageDetailTitle;

  /// No description provided for @louageNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Louage introuvable'**
  String get louageNotFound;

  /// No description provided for @louageDetailUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Détail indisponible'**
  String get louageDetailUnavailable;

  /// No description provided for @louageDepartureUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Horaire indisponible'**
  String get louageDepartureUnavailable;

  /// No description provided for @louageVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicule'**
  String get louageVehicle;

  /// No description provided for @louagePricePerSeat.
  ///
  /// In fr, this message translates to:
  /// **'Prix par place'**
  String get louagePricePerSeat;

  /// No description provided for @louageSeatsFreeOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'{available} places libres sur {total}'**
  String louageSeatsFreeOfTotal(Object available, Object total);

  /// No description provided for @louageDriverRating.
  ///
  /// In fr, this message translates to:
  /// **'Note du chauffeur : {rating} / 5'**
  String louageDriverRating(String rating);

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileChangePhone.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le numéro de téléphone'**
  String get profileChangePhone;

  /// No description provided for @profileNewPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau numéro de téléphone'**
  String get profileNewPhoneLabel;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get profileHelp;

  /// No description provided for @profileTerms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d’utilisation'**
  String get profileTerms;

  /// No description provided for @profileDriverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil chauffeur'**
  String get profileDriverTitle;

  /// No description provided for @profilePassengerFallback.
  ///
  /// In fr, this message translates to:
  /// **'Passager'**
  String get profilePassengerFallback;

  /// No description provided for @profileDriverFallback.
  ///
  /// In fr, this message translates to:
  /// **'Chauffeur'**
  String get profileDriverFallback;

  /// No description provided for @widgetGalleryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue des widgets'**
  String get widgetGalleryTitle;

  /// No description provided for @widgetGalleryFields.
  ///
  /// In fr, this message translates to:
  /// **'Champs de formulaire'**
  String get widgetGalleryFields;

  /// No description provided for @widgetGalleryValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get widgetGalleryValidate;

  /// No description provided for @widgetGalleryFormValid.
  ///
  /// In fr, this message translates to:
  /// **'Formulaire valide'**
  String get widgetGalleryFormValid;

  /// No description provided for @widgetGalleryEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get widgetGalleryEmail;

  /// No description provided for @widgetGalleryPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get widgetGalleryPassword;

  /// No description provided for @widgetGalleryPasswordMin.
  ///
  /// In fr, this message translates to:
  /// **'6 caractères minimum'**
  String get widgetGalleryPasswordMin;

  /// No description provided for @widgetGalleryButtons.
  ///
  /// In fr, this message translates to:
  /// **'Boutons'**
  String get widgetGalleryButtons;

  /// No description provided for @widgetGalleryPrimary.
  ///
  /// In fr, this message translates to:
  /// **'Primaire'**
  String get widgetGalleryPrimary;

  /// No description provided for @widgetGallerySecondary.
  ///
  /// In fr, this message translates to:
  /// **'Secondaire'**
  String get widgetGallerySecondary;

  /// No description provided for @widgetGalleryAccent.
  ///
  /// In fr, this message translates to:
  /// **'Accent'**
  String get widgetGalleryAccent;

  /// No description provided for @widgetGalleryLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get widgetGalleryLoading;

  /// No description provided for @widgetGalleryStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Statuts de trajet'**
  String get widgetGalleryStatuses;

  /// No description provided for @widgetGalleryCardsSeats.
  ///
  /// In fr, this message translates to:
  /// **'Carte et places'**
  String get widgetGalleryCardsSeats;

  /// No description provided for @widgetGalleryDeparturePrice.
  ///
  /// In fr, this message translates to:
  /// **'Départ 08:00 · 18 DT'**
  String get widgetGalleryDeparturePrice;

  /// No description provided for @widgetGalleryLoadingSection.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get widgetGalleryLoadingSection;

  /// No description provided for @widgetGalleryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'État vide'**
  String get widgetGalleryEmpty;

  /// No description provided for @widgetGalleryNoSavedTrip.
  ///
  /// In fr, this message translates to:
  /// **'Aucun trajet enregistré'**
  String get widgetGalleryNoSavedTrip;

  /// No description provided for @widgetGalleryAvailableTripsAppear.
  ///
  /// In fr, this message translates to:
  /// **'Les trajets disponibles apparaîtront ici.'**
  String get widgetGalleryAvailableTripsAppear;

  /// No description provided for @widgetGallerySearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get widgetGallerySearch;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get settingsLanguageArabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
