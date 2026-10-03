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

  /// No description provided for @legalUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour le {date}'**
  String legalUpdatedAt(String date);

  /// No description provided for @legalDocumentVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String legalDocumentVersion(String version);

  /// No description provided for @legalDemoDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Version de démonstration : ce texte doit être validé par un juriste avant publication.'**
  String get legalDemoDisclaimer;

  /// No description provided for @legalTableOfContents.
  ///
  /// In fr, this message translates to:
  /// **'Sommaire'**
  String get legalTableOfContents;

  /// No description provided for @legalContactLabel.
  ///
  /// In fr, this message translates to:
  /// **'Contact :'**
  String get legalContactLabel;

  /// No description provided for @legalUpdateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour des conditions'**
  String get legalUpdateTitle;

  /// No description provided for @legalUpdateMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les conditions et la politique de confidentialité ont été mises à jour. Veuillez les lire et accepter cette version pour continuer.'**
  String get legalUpdateMessage;

  /// No description provided for @legalAcceptUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Accepter et continuer'**
  String get legalAcceptUpdate;

  /// No description provided for @legalSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get legalSignOut;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get legalPrivacyTitle;

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

  /// No description provided for @supportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Support LouageGo'**
  String get supportTitle;

  /// No description provided for @supportFaqTitle.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes'**
  String get supportFaqTitle;

  /// No description provided for @supportContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support'**
  String get supportContactTitle;

  /// No description provided for @supportRequestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get supportRequestsTitle;

  /// No description provided for @supportRequestDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail de la demande'**
  String get supportRequestDetailTitle;

  /// No description provided for @supportQuickContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact rapide'**
  String get supportQuickContact;

  /// No description provided for @supportCallAction.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get supportCallAction;

  /// No description provided for @supportEmailAction.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get supportEmailAction;

  /// No description provided for @supportWhatsappAction.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get supportWhatsappAction;

  /// No description provided for @supportContactUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune application disponible pour cette action.'**
  String get supportContactUnavailable;

  /// No description provided for @supportFaqSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une question'**
  String get supportFaqSearch;

  /// No description provided for @supportClearSearch.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get supportClearSearch;

  /// No description provided for @supportFaqAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get supportFaqAll;

  /// No description provided for @supportFaqEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat. Essayez d’autres mots-clés ou catégories.'**
  String get supportFaqEmpty;

  /// No description provided for @supportCategoryBooking.
  ///
  /// In fr, this message translates to:
  /// **'Réservation'**
  String get supportCategoryBooking;

  /// No description provided for @supportCategoryPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get supportCategoryPayment;

  /// No description provided for @supportCategoryTrip.
  ///
  /// In fr, this message translates to:
  /// **'Trajet et suivi'**
  String get supportCategoryTrip;

  /// No description provided for @supportCategoryAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get supportCategoryAccount;

  /// No description provided for @supportCategoryDrivers.
  ///
  /// In fr, this message translates to:
  /// **'Chauffeurs'**
  String get supportCategoryDrivers;

  /// No description provided for @supportCategoryBug.
  ///
  /// In fr, this message translates to:
  /// **'Problème technique'**
  String get supportCategoryBug;

  /// No description provided for @supportCategoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get supportCategoryOther;

  /// No description provided for @supportCategoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get supportCategoryLabel;

  /// No description provided for @supportTripReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence du trajet (facultatif)'**
  String get supportTripReference;

  /// No description provided for @supportMessageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre message'**
  String get supportMessageLabel;

  /// No description provided for @supportSendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get supportSendRequest;

  /// No description provided for @supportRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande a été envoyée.'**
  String get supportRequestSent;

  /// No description provided for @supportTooManyOpenRequests.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà 3 demandes de support ouvertes.'**
  String get supportTooManyOpenRequests;

  /// No description provided for @supportCategoryRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une catégorie.'**
  String get supportCategoryRequired;

  /// No description provided for @supportMessageInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le message doit contenir entre 10 et 1000 caractères.'**
  String get supportMessageInvalid;

  /// No description provided for @supportSignInRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour envoyer ou consulter vos demandes.'**
  String get supportSignInRequired;

  /// No description provided for @supportSubmissionFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’envoyer la demande. Réessayez.'**
  String get supportSubmissionFailed;

  /// No description provided for @supportLoadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les demandes.'**
  String get supportLoadFailed;

  /// No description provided for @supportRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get supportRetry;

  /// No description provided for @supportRequestsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Vous n’avez aucune demande de support.'**
  String get supportRequestsEmpty;

  /// No description provided for @supportRequestNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande est introuvable.'**
  String get supportRequestNotFound;

  /// No description provided for @supportAdminReply.
  ///
  /// In fr, this message translates to:
  /// **'Réponse du support'**
  String get supportAdminReply;

  /// No description provided for @supportNoAdminReply.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réponse pour le moment.'**
  String get supportNoAdminReply;

  /// No description provided for @supportStatusOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In fr, this message translates to:
  /// **'Résolue'**
  String get supportStatusResolved;

  /// No description provided for @supportEmailSubject.
  ///
  /// In fr, this message translates to:
  /// **'Demande d’assistance LouageGo'**
  String get supportEmailSubject;

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

  /// No description provided for @driverHomeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String driverHomeGreeting(String name);

  /// No description provided for @driverHomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre louage et vos départs.'**
  String get driverHomeSubtitle;

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

  /// No description provided for @driverSeatCounts.
  ///
  /// In fr, this message translates to:
  /// **'{reserved} places occupées · {free} libres'**
  String driverSeatCounts(String reserved, String free);

  /// No description provided for @driverDepartureTime.
  ///
  /// In fr, this message translates to:
  /// **'Départ à {time}'**
  String driverDepartureTime(String time);

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

  /// No description provided for @stationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stations'**
  String get stationsTitle;

  /// No description provided for @stationsSearchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une station'**
  String get stationsSearchLabel;

  /// No description provided for @stationsBrowsePrompt.
  ///
  /// In fr, this message translates to:
  /// **'Parcourez les stations de Tunisie'**
  String get stationsBrowsePrompt;

  /// No description provided for @stationsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les stations'**
  String get stationsLoadError;

  /// No description provided for @stationsNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucune station trouvée'**
  String get stationsNoResults;

  /// No description provided for @stationsSearchFrom.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher depuis cette station'**
  String get stationsSearchFrom;

  /// No description provided for @locationUseMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ma position'**
  String get locationUseMyPosition;

  /// No description provided for @locationConsentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser votre position ?'**
  String get locationConsentTitle;

  /// No description provided for @locationConsentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre position sert uniquement à trouver les stations les plus proches. Elle n’est pas partagée.'**
  String get locationConsentMessage;

  /// No description provided for @locationConsentPrivacyLink.
  ///
  /// In fr, this message translates to:
  /// **'Lire la politique de confidentialité'**
  String get locationConsentPrivacyLink;

  /// No description provided for @locationConsentAccept.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get locationConsentAccept;

  /// No description provided for @locationDenied.
  ///
  /// In fr, this message translates to:
  /// **'L’accès à la position a été refusé.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez la position dans les réglages de l’application.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Activez les services de localisation de votre appareil.'**
  String get locationServiceDisabled;

  /// No description provided for @locationError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’obtenir votre position.'**
  String get locationError;

  /// No description provided for @locationOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get locationOpenSettings;

  /// No description provided for @locationNearestEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune station avec une position connue.'**
  String get locationNearestEmpty;

  /// No description provided for @stationsMapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte des stations'**
  String get stationsMapTitle;

  /// No description provided for @stationsMapUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Carte indisponible hors connexion'**
  String get stationsMapUnavailable;

  /// No description provided for @stationsMapRecenter.
  ///
  /// In fr, this message translates to:
  /// **'Recentrer la carte'**
  String get stationsMapRecenter;

  /// No description provided for @stationsMapMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get stationsMapMyPosition;

  /// No description provided for @stationsMapFavoritesSoon.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris sera bientôt disponible'**
  String get stationsMapFavoritesSoon;

  /// No description provided for @stationsMapRouteCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} lignes au départ'**
  String stationsMapRouteCount(int count);

  /// No description provided for @favoriteAddRoute.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter ce trajet aux favoris'**
  String get favoriteAddRoute;

  /// No description provided for @favoriteRemoveRoute.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce trajet des favoris'**
  String get favoriteRemoveRoute;

  /// No description provided for @favoriteAddStation.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter cette station aux favoris'**
  String get favoriteAddStation;

  /// No description provided for @favoriteRemoveStation.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette station des favoris'**
  String get favoriteRemoveStation;

  /// No description provided for @favoriteUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de mettre à jour les favoris.'**
  String get favoriteUpdateError;

  /// No description provided for @favoritesTabOffers.
  ///
  /// In fr, this message translates to:
  /// **'Offres'**
  String get favoritesTabOffers;

  /// No description provided for @favoritesRoutesTab.
  ///
  /// In fr, this message translates to:
  /// **'Trajets'**
  String get favoritesRoutesTab;

  /// No description provided for @favoritesStationsTab.
  ///
  /// In fr, this message translates to:
  /// **'Stations'**
  String get favoritesStationsTab;

  /// No description provided for @favoritesEmptyOffers.
  ///
  /// In fr, this message translates to:
  /// **'Aucune offre favorite pour le moment.'**
  String get favoritesEmptyOffers;

  /// No description provided for @favoritesEmptyRoutes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun trajet favori pour le moment.'**
  String get favoritesEmptyRoutes;

  /// No description provided for @favoritesEmptyStations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune station favorite pour le moment.'**
  String get favoritesEmptyStations;

  /// No description provided for @favoritesUndo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get favoritesUndo;

  /// No description provided for @favoritesRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Favori supprimé.'**
  String get favoritesRemoved;

  /// No description provided for @favoritesOfferAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter cette offre aux favoris'**
  String get favoritesOfferAdd;

  /// No description provided for @favoritesOfferRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette offre des favoris'**
  String get favoritesOfferRemove;

  /// No description provided for @favoritesNoDeparture.
  ///
  /// In fr, this message translates to:
  /// **'Aucun départ disponible'**
  String get favoritesNoDeparture;

  /// No description provided for @favoritesNextDeparture.
  ///
  /// In fr, this message translates to:
  /// **'Prochain départ : {date}'**
  String favoritesNextDeparture(String date);

  /// No description provided for @favoritesOtherSchedules.
  ///
  /// In fr, this message translates to:
  /// **'Voir les autres horaires'**
  String get favoritesOtherSchedules;

  /// No description provided for @favoritesMyOffers.
  ///
  /// In fr, this message translates to:
  /// **'Mes offres'**
  String get favoritesMyOffers;

  /// No description provided for @filtersReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get filtersReset;

  /// No description provided for @filtersHideFull.
  ///
  /// In fr, this message translates to:
  /// **'Masquer les trajets complets'**
  String get filtersHideFull;

  /// No description provided for @filtersActiveCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} filtres actifs'**
  String filtersActiveCount(int count);

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

  /// No description provided for @profileDriverReviews.
  ///
  /// In fr, this message translates to:
  /// **'Mes avis'**
  String get profileDriverReviews;

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

  /// No description provided for @reviewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis du chauffeur'**
  String get reviewsTitle;

  /// No description provided for @reviewsSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous les avis'**
  String get reviewsSeeAll;

  /// No description provided for @reviewsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} avis'**
  String reviewsCount(int count);

  /// No description provided for @reviewsLatest.
  ///
  /// In fr, this message translates to:
  /// **'Avis récents'**
  String get reviewsLatest;

  /// No description provided for @reviewsNoReviews.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avis pour le moment'**
  String get reviewsNoReviews;

  /// No description provided for @reviewsAnonymous.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur supprimé'**
  String get reviewsAnonymous;

  /// No description provided for @reviewsWriteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Noter ce trajet'**
  String get reviewsWriteTitle;

  /// No description provided for @reviewsEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon avis'**
  String get reviewsEditTitle;

  /// No description provided for @reviewsRatingPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une note'**
  String get reviewsRatingPrompt;

  /// No description provided for @reviewsRating1.
  ///
  /// In fr, this message translates to:
  /// **'Très décevant'**
  String get reviewsRating1;

  /// No description provided for @reviewsRating2.
  ///
  /// In fr, this message translates to:
  /// **'Décevant'**
  String get reviewsRating2;

  /// No description provided for @reviewsRating3.
  ///
  /// In fr, this message translates to:
  /// **'Correct'**
  String get reviewsRating3;

  /// No description provided for @reviewsRating4.
  ///
  /// In fr, this message translates to:
  /// **'Très bien'**
  String get reviewsRating4;

  /// No description provided for @reviewsRating5.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get reviewsRating5;

  /// No description provided for @reviewsStarSemantics.
  ///
  /// In fr, this message translates to:
  /// **'{count} sur 5 étoiles'**
  String reviewsStarSemantics(int count);

  /// No description provided for @reviewsComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire (facultatif)'**
  String get reviewsComment;

  /// No description provided for @reviewsCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre expérience'**
  String get reviewsCommentHint;

  /// No description provided for @reviewsSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer mon avis'**
  String get reviewsSubmit;

  /// No description provided for @reviewsUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get reviewsUpdate;

  /// No description provided for @reviewsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon avis'**
  String get reviewsDelete;

  /// No description provided for @reviewsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer cet avis ?'**
  String get reviewsDeleteConfirm;

  /// No description provided for @reviewsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis a été enregistré.'**
  String get reviewsSaved;

  /// No description provided for @reviewsUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis a été modifié.'**
  String get reviewsUpdated;

  /// No description provided for @reviewsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis a été supprimé.'**
  String get reviewsDeleted;

  /// No description provided for @reviewsNotEligible.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les trajets terminés que vous avez réservés peuvent être notés.'**
  String get reviewsNotEligible;

  /// No description provided for @reviewsAlreadyReviewed.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà noté ce trajet.'**
  String get reviewsAlreadyReviewed;

  /// No description provided for @reviewsInvalidRating.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une note de 1 à 5 étoiles.'**
  String get reviewsInvalidRating;

  /// No description provided for @reviewsInvalidComment.
  ///
  /// In fr, this message translates to:
  /// **'Le commentaire ne peut pas dépasser 300 caractères.'**
  String get reviewsInvalidComment;

  /// No description provided for @reviewsNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cet avis est introuvable.'**
  String get reviewsNotFound;

  /// No description provided for @reviewsWindowExpired.
  ///
  /// In fr, this message translates to:
  /// **'La modification est possible pendant 24 heures après la publication.'**
  String get reviewsWindowExpired;

  /// No description provided for @reviewsSignInRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer.'**
  String get reviewsSignInRequired;

  /// No description provided for @reviewsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les avis.'**
  String get reviewsLoadError;

  /// No description provided for @reviewsReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler cet avis'**
  String get reviewsReport;

  /// No description provided for @reviewsReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler cet avis ?'**
  String get reviewsReportTitle;

  /// No description provided for @reviewsReportBody.
  ///
  /// In fr, this message translates to:
  /// **'Le signalement sera transmis à l’équipe de modération.'**
  String get reviewsReportBody;

  /// No description provided for @reviewsReportSent.
  ///
  /// In fr, this message translates to:
  /// **'L’avis a été signalé.'**
  String get reviewsReportSent;

  /// No description provided for @reviewsDistribution.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des notes'**
  String get reviewsDistribution;

  /// No description provided for @reviewsNoComment.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commentaire'**
  String get reviewsNoComment;

  /// No description provided for @reviewsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Les informations du trajet ne sont pas disponibles.'**
  String get reviewsUnavailable;

  /// No description provided for @reviewsAnonymousAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Voyageur'**
  String get reviewsAnonymousAuthor;

  /// No description provided for @reviewsDeleteAction.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get reviewsDeleteAction;

  /// No description provided for @reviewsCancelAction.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get reviewsCancelAction;

  /// No description provided for @reviewsLoadMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get reviewsLoadMore;

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

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir les mises à jour importantes de vos trajets'**
  String get settingsNotificationsDescription;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Notifications LouageGo'**
  String get notificationsChannelName;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos mises à jour importantes apparaîtront ici.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les notifications.'**
  String get notificationsLoadError;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd’hui'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get notificationsYesterday;

  /// No description provided for @notificationsOlder.
  ///
  /// In fr, this message translates to:
  /// **'Plus ancien'**
  String get notificationsOlder;

  /// No description provided for @notificationsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Notification supprimée'**
  String get notificationsDeleted;

  /// No description provided for @notificationsUnread.
  ///
  /// In fr, this message translates to:
  /// **'Non lue'**
  String get notificationsUnread;

  /// No description provided for @notificationsTypeBooking.
  ///
  /// In fr, this message translates to:
  /// **'Réservation'**
  String get notificationsTypeBooking;

  /// No description provided for @notificationsTypeTrip.
  ///
  /// In fr, this message translates to:
  /// **'Trajet'**
  String get notificationsTypeTrip;

  /// No description provided for @notificationsTypePromotion.
  ///
  /// In fr, this message translates to:
  /// **'Promotion'**
  String get notificationsTypePromotion;

  /// No description provided for @notificationsTypeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get notificationsTypeSystem;

  /// No description provided for @notificationsPermissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get notificationsPermissionTitle;

  /// No description provided for @notificationsPermissionExplanation.
  ///
  /// In fr, this message translates to:
  /// **'LouageGo peut vous envoyer des mises à jour sur vos réservations et vos trajets. Vous pourrez modifier cette autorisation dans les réglages de votre appareil.'**
  String get notificationsPermissionExplanation;

  /// No description provided for @notificationsPermissionContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get notificationsPermissionContinue;

  /// No description provided for @notificationsPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications sont désactivées dans les réglages de l’appareil.'**
  String get notificationsPermissionDenied;

  /// No description provided for @notificationsOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get notificationsOpenSettings;

  /// No description provided for @searchHideFull.
  ///
  /// In fr, this message translates to:
  /// **'Masquer les trajets complets'**
  String get searchHideFull;

  /// No description provided for @searchUseMaximumPrice.
  ///
  /// In fr, this message translates to:
  /// **'Limiter le prix'**
  String get searchUseMaximumPrice;

  /// No description provided for @searchResetFilters.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get searchResetFilters;
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
