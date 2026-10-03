// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get authInvalidCredentials => 'Email ou mot de passe incorrect';

  @override
  String get authEmailAlreadyUsed => 'Cet email est déjà utilisé';

  @override
  String get authWeakPassword =>
      'Mot de passe trop faible (6 caractères minimum)';

  @override
  String get authInvalidEmail => 'Adresse email invalide';

  @override
  String get authPhoneAlreadyUsed => 'Ce numéro de téléphone est déjà utilisé';

  @override
  String get authInvalidPhone => 'Numéro de téléphone invalide';

  @override
  String get authOtpInvalid => 'Code de vérification incorrect';

  @override
  String get authOtpExpired => 'Le code de vérification a expiré';

  @override
  String get authOtpTooManyAttempts =>
      'Trop de tentatives. Demandez un nouveau code';

  @override
  String get authOtpResendTooSoon =>
      'Veuillez attendre avant de demander un nouveau code';

  @override
  String get authPhoneNotRegistered => 'Aucun compte n’est associé à ce numéro';

  @override
  String get authAccountBlocked => 'Ce compte est bloqué';

  @override
  String get authProfileUnavailable => 'Le profil est introuvable.';

  @override
  String get authUnexpectedError =>
      'Une erreur d’authentification est survenue.';

  @override
  String authResetCodeGenerated(String code) {
    return 'Code de réinitialisation : $code';
  }

  @override
  String get authInvalidResetCode =>
      'Code de réinitialisation incorrect ou expiré.';

  @override
  String get authResetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get authResetEmailLabel => 'Adresse e-mail';

  @override
  String get authResetCodeLabel => 'Code reçu';

  @override
  String get authNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authContinue => 'Continuer';

  @override
  String get authCancel => 'Annuler';

  @override
  String get authResetAction => 'Réinitialiser';

  @override
  String get authResetCompleted => 'Mot de passe réinitialisé';

  @override
  String get splashSlogan => 'Réservez votre place en un clic';

  @override
  String get onboardingReserveTitle => 'Réservez votre trajet';

  @override
  String get onboardingReserveBody =>
      'Choisissez votre destination et votre horaire en quelques instants.';

  @override
  String get onboardingTrackTitle => 'Suivez votre départ';

  @override
  String get onboardingTrackBody =>
      'Retrouvez les informations utiles sur votre voyage au même endroit.';

  @override
  String get onboardingPayTitle => 'Payez simplement';

  @override
  String get onboardingPayBody =>
      'Préparez votre réservation et voyagez l’esprit tranquille.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get appTitle => 'LouageGo';

  @override
  String get commonLoading => 'Chargement';

  @override
  String get statusWaiting => 'En attente';

  @override
  String get statusFull => 'Complet';

  @override
  String get statusDeparted => 'Parti';

  @override
  String get statusArrived => 'Arrivé';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get storageUnavailableTitle => 'Stockage local indisponible';

  @override
  String get storageUnavailableBody =>
      'Vérifiez les permissions et l’espace disponible, puis redémarrez l’application.';

  @override
  String authWelcomeMessage(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get loginWelcome => 'Bienvenue sur LouageGo';

  @override
  String get loginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get loginMethodPhone => 'Téléphone';

  @override
  String get loginMethodEmail => 'Email';

  @override
  String get loginPhoneLabel => 'Téléphone';

  @override
  String get loginSendCode => 'Recevoir le code';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginAccountInaccessible => 'Compte inaccessible ?';

  @override
  String get loginContinueWithGoogle => 'Continuer avec Google';

  @override
  String get loginGoogleUnavailable =>
      'La connexion Google n’est pas configurée.';

  @override
  String get loginNoAccount => 'Pas de compte ?';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerRolePrompt => 'Je suis...';

  @override
  String get registerPassengerRole => 'Passager';

  @override
  String get registerDriverRole => 'Chauffeur';

  @override
  String get registerNameLabel => 'Nom complet';

  @override
  String get registerPhoneLabel => 'Téléphone';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailOptional => 'Email (facultatif)';

  @override
  String get registerUseEmail => 'Utiliser un email';

  @override
  String get registerUsePhone => 'Utiliser un téléphone';

  @override
  String get registerAcceptTerms => 'J’accepte';

  @override
  String get registerTermsLink => 'les conditions d’utilisation';

  @override
  String get registerAnd => 'et';

  @override
  String get registerPrivacyLink => 'la politique de confidentialité';

  @override
  String get registerConsentRequired =>
      'Acceptez les conditions et la politique pour continuer.';

  @override
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerSubmit => 'Créer mon compte';

  @override
  String get registerSignInLink => 'Déjà un compte ? Se connecter';

  @override
  String get registerPasswordStrengthLabel => 'Sécurité du mot de passe';

  @override
  String get registerPasswordStrengthWeak => 'Faible';

  @override
  String get registerPasswordStrengthMedium => 'Moyen';

  @override
  String get registerPasswordStrengthStrong => 'Fort';

  @override
  String get formRequiredFields => 'Remplissez tous les champs';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordReveal => 'Afficher le mot de passe';

  @override
  String get passwordHide => 'Masquer le mot de passe';

  @override
  String get otpPageTitle => 'Vérification du code';

  @override
  String otpCodeSentTo(String phone) {
    return 'Saisissez le code envoyé au $phone';
  }

  @override
  String get otpVerifyAction => 'Vérifier le code';

  @override
  String get otpResendAction => 'Renvoyer le code';

  @override
  String otpResendCountdown(int seconds) {
    return 'Renvoyer dans $seconds s';
  }

  @override
  String otpDemoCode(String code) {
    return 'Mode démo : votre code est $code';
  }

  @override
  String get otpCodeResent => 'Un nouveau code a été généré.';

  @override
  String get otpCodeVerified => 'Numéro de téléphone vérifié.';

  @override
  String get legalTermsTitle => 'Conditions d’utilisation';

  @override
  String get legalTermsBody =>
      'LouageGo est un projet universitaire de réservation de louages. En créant un compte, vous confirmez l’exactitude des informations fournies et vous engagez à utiliser le service dans le respect des règles applicables.\n\nLes réservations sont soumises à la disponibilité des trajets et des places.';

  @override
  String get legalUpdatedAt => 'Mis à jour le 3 octobre 2026';

  @override
  String get legalTermsSectionServiceTitle => 'Utilisation du service';

  @override
  String get legalTermsSectionServiceBody =>
      'LouageGo facilite la consultation et la réservation de trajets en louage. L’utilisateur s’engage à fournir des informations exactes, à protéger ses identifiants et à utiliser le service conformément aux lois applicables.';

  @override
  String get legalTermsSectionBookingsTitle => 'Réservations et trajets';

  @override
  String get legalTermsSectionBookingsBody =>
      'Les réservations dépendent de la disponibilité des trajets et des places. Les horaires et informations affichés peuvent être mis à jour. Toute annulation reste soumise aux conditions indiquées dans l’application.';

  @override
  String get legalTermsSectionDemoTitle => 'Version de démonstration';

  @override
  String get legalTermsSectionDemoBody =>
      'Cette application est un projet universitaire. Certaines fonctionnalités sont simulées et ne constituent pas une garantie de transport ou de paiement réel.';

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get legalPrivacyBody =>
      'Dans cette version de démonstration, les informations du compte sont stockées localement sur cet appareil. Aucun SMS réel n’est envoyé : le code de vérification est simulé.\n\nLes données ne sont pas transmises à Firebase.';

  @override
  String get legalPrivacySectionDataTitle => 'Données enregistrées';

  @override
  String get legalPrivacySectionDataBody =>
      'Les informations de profil, préférences, favoris et données nécessaires au fonctionnement des réservations sont enregistrées dans le stockage local de l’application.';

  @override
  String get legalPrivacySectionUseTitle => 'Utilisation des données';

  @override
  String get legalPrivacySectionUseBody =>
      'Les données servent à afficher le profil, gérer les préférences et faciliter l’utilisation des fonctions de réservation. Cette version de démonstration ne transmet pas les données à Firebase.';

  @override
  String get legalPrivacySectionControlTitle => 'Contrôle et suppression';

  @override
  String get legalPrivacySectionControlBody =>
      'Vous pouvez modifier vos informations depuis votre profil ou demander la suppression de votre compte. Les réservations et avis historiques peuvent être conservés sous forme anonymisée.';

  @override
  String get legalPrivacySectionDemoTitle => 'SMS de vérification';

  @override
  String get legalPrivacySectionDemoBody =>
      'Aucun SMS réel n’est envoyé dans cette version : le code de vérification est simulé.';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsPreferencesSection => 'Préférences de l’application';

  @override
  String get settingsSecuritySection => 'Sécurité';

  @override
  String get settingsSupportSection => 'Aide et informations';

  @override
  String get profileFirstNameLabel => 'Prénom';

  @override
  String get profileLastNameLabel => 'Nom';

  @override
  String get profileSignOutTitle => 'Se déconnecter ?';

  @override
  String get profileSignOutMessage => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get helpSupportTitle => 'Aide et assistance';

  @override
  String get helpFaqSection => 'Questions fréquentes';

  @override
  String get helpFaqBookingQuestion => 'Comment trouver un trajet ?';

  @override
  String get helpFaqBookingAnswer =>
      'Choisissez votre ville de départ et votre destination sur l’écran d’accueil. Les trajets disponibles s’affichent ensuite.';

  @override
  String get helpFaqPaymentQuestion => 'Comment réserver une place ?';

  @override
  String get helpFaqPaymentAnswer =>
      'Ouvrez un trajet disponible pour consulter ses détails et les actions de réservation proposées.';

  @override
  String get helpFaqPhoneQuestion => 'Comment modifier mon numéro ?';

  @override
  String get helpFaqPhoneAnswer =>
      'Dans votre profil, ouvrez Modifier le profil puis choisissez Changer de numéro. La vérification se fait par code OTP.';

  @override
  String get helpHowItWorksTitle => 'Comment fonctionne LouageGo';

  @override
  String get helpHowItWorksBody =>
      'Choisissez votre départ et votre destination, consultez les trajets disponibles puis ouvrez un trajet pour voir ses informations. Les chauffeurs peuvent gérer leur espace depuis leur profil.';

  @override
  String get helpContactTitle => 'Nous contacter';

  @override
  String get helpContactSupport => 'Contacter l’assistance';

  @override
  String get helpEmailCopied => 'Adresse d’assistance copiée.';

  @override
  String get helpReportProblem => 'Signaler un problème';

  @override
  String get helpReportHint => 'Décrivez le problème rencontré';

  @override
  String get helpCopyReport => 'Copier le signalement';

  @override
  String get helpReportCopied =>
      'Signalement copié. Vous pouvez l’envoyer à l’assistance.';

  @override
  String get profilePrivacy => 'Confidentialité';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileCityLabel => 'Ville';

  @override
  String get profileCityNotSet => 'Aucune ville';

  @override
  String get profileChooseGallery => 'Choisir dans la galerie';

  @override
  String get profileChooseCamera => 'Prendre une photo';

  @override
  String get profileChangePhoto => 'Changer la photo';

  @override
  String get profilePhotoError =>
      'Impossible de sélectionner ou d’enregistrer la photo.';

  @override
  String get profilePhotoCleanupWarning =>
      'Profil enregistré, mais l’ancienne photo n’a pas pu être supprimée.';

  @override
  String get profileUpdated => 'Profil mis à jour.';

  @override
  String get profileUnavailable => 'Profil indisponible.';

  @override
  String get profileSaveAction => 'Enregistrer';

  @override
  String get profilePhoneUpdated => 'Numéro de téléphone mis à jour.';

  @override
  String get profileHelpBody =>
      'Questions fréquentes\n\nComment réserver un trajet ? Choisissez votre ville de départ et votre destination, puis sélectionnez un trajet disponible.\n\nComment modifier mon numéro ? Ouvrez Modifier le profil, puis choisissez Changer de numéro. Un code de vérification sera demandé.\n\nComment protéger mon compte ? Gardez votre téléphone et vos informations de connexion sous votre contrôle.';

  @override
  String get deleteAccountAction => 'Supprimer mon compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountWarning =>
      'Cette action est définitive. Vos favoris, notifications et données de profil seront supprimés. Les réservations et avis seront conservés sous forme anonymisée.';

  @override
  String get deleteAccountConfirmTitle => 'Confirmer la suppression';

  @override
  String get deleteAccountConfirmationWord => 'SUPPRIMER';

  @override
  String deleteAccountTypeConfirmation(String word) {
    return 'Saisissez $word pour confirmer.';
  }

  @override
  String get deleteAccountConfirmationMismatch =>
      'Le mot saisi ne correspond pas.';

  @override
  String get deleteAccountCompleted => 'Votre compte a été supprimé.';

  @override
  String get pageNotFound => 'Page introuvable';

  @override
  String get searchPageNotFound => 'Recherche introuvable';

  @override
  String get passengerNavHome => 'Accueil';

  @override
  String get passengerNavTrips => 'Mes voyages';

  @override
  String get passengerNavFavorites => 'Favoris';

  @override
  String get passengerNavProfile => 'Profil';

  @override
  String get driverNavHome => 'Accueil';

  @override
  String get driverNavQueue => 'File';

  @override
  String get driverNavScan => 'Scan';

  @override
  String get driverNavEarnings => 'Revenus';

  @override
  String get driverNavProfile => 'Profil';

  @override
  String get adminNavDashboard => 'Tableau de bord';

  @override
  String get adminNavStations => 'Stations';

  @override
  String get adminNavDrivers => 'Chauffeurs';

  @override
  String get adminNavUsers => 'Utilisateurs';

  @override
  String get adminNavReports => 'Signalements';

  @override
  String get adminNavNotifications => 'Notifications';

  @override
  String get adminMenuTitle => 'Administration';

  @override
  String get driverQueueTitle => 'File de départ';

  @override
  String get driverScanTitle => 'Scanner un billet';

  @override
  String get driverDocumentsTitle => 'Envoyer les documents';

  @override
  String get driverEarningsTitle => 'Revenus';

  @override
  String get driverProfileTitle => 'Profil chauffeur';

  @override
  String get driverHomeTitle => 'Espace chauffeur';

  @override
  String get driverProfileUnavailable => 'Profil chauffeur indisponible';

  @override
  String get sessionExpired => 'Session expirée';

  @override
  String get driverStatusPending => 'Compte en attente de validation';

  @override
  String get driverStatusApproved => 'Compte validé';

  @override
  String get driverStatusRejected => 'Compte rejeté';

  @override
  String get driverDocumentsRejectedBody =>
      'Votre dossier nécessite une mise à jour.';

  @override
  String get driverDocumentsPendingBody =>
      'Envoyez vos documents pour activer votre espace chauffeur.';

  @override
  String get driverDocumentsSubmit => 'Envoyer les documents';

  @override
  String get driverMyLouage => 'Mon louage';

  @override
  String get driverEditProfile => 'Profil';

  @override
  String get driverNoLouage => 'Aucun louage associé';

  @override
  String get driverStationUnavailable => 'Station actuelle indisponible';

  @override
  String get driverSeatFill => 'Remplissage';

  @override
  String get driverNoActiveTrip => 'Aucun départ actif';

  @override
  String get driverCurrentTrip => 'Voyage en cours';

  @override
  String get driverFillUpdatesNextTrip =>
      'La jauge s’actualisera au prochain départ.';

  @override
  String get driverPassengersReserved => 'Passagers réservés';

  @override
  String get driverNoBookings => 'Aucune réservation';

  @override
  String get driverBookingsAppearHere =>
      'Les passagers réservés apparaîtront ici.';

  @override
  String get driverPassengerFallback => 'Passager';

  @override
  String driverPassengerSeats(Object count, Object name) {
    return '$name — $count place(s)';
  }

  @override
  String driverBookingSeatCount(Object count) {
    return '$count place(s)';
  }

  @override
  String get driverSeatWord => 'places';

  @override
  String get driverJoinQueue => 'Rejoindre la file';

  @override
  String get driverLeaveQueue => 'Quitter la file';

  @override
  String get driverLogout => 'Déconnexion';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String greetingPassenger(Object name) {
    return 'Bonjour $name';
  }

  @override
  String get searchPrompt => 'Où allez-vous ?';

  @override
  String get searchChooseBothCities => 'Choisissez le départ et la destination';

  @override
  String get searchCitiesMustDiffer =>
      'Le départ et la destination doivent être différents';

  @override
  String get searchDeparture => 'Départ';

  @override
  String get searchDestination => 'Destination';

  @override
  String get searchDate => 'Date';

  @override
  String get searchTime => 'Heure';

  @override
  String get searchSubmit => 'Rechercher';

  @override
  String get searchSwapRoute => 'Inverser le trajet';

  @override
  String get searchLastTrips => 'Derniers trajets';

  @override
  String get searchFavorites => 'Favoris';

  @override
  String get searchPopularTrips => 'Trajets populaires';

  @override
  String get searchNoPopularTrips => 'Aucun trajet disponible pour le moment';

  @override
  String get searchNearestStation => 'Station la plus proche';

  @override
  String get searchLocationPlaceholder =>
      'La localisation sera disponible prochainement.';

  @override
  String get searchChooseCity => 'Choisir une ville';

  @override
  String get searchChooseCityPrompt => 'Choisir une ville';

  @override
  String get searchCitySearch => 'Rechercher une ville';

  @override
  String get searchNoCityFound => 'Aucune ville trouvée';

  @override
  String get searchCityPickerTitle => 'Choisir une ville';

  @override
  String searchPricePerSeat(Object amount) {
    return '$amount DT / place';
  }

  @override
  String searchRoutePair(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String searchSeatAvailability(Object available, Object total) {
    return '$available places libres sur $total';
  }

  @override
  String searchSeatsFree(Object count) {
    return '$count places libres';
  }

  @override
  String searchSeatsAvailableSemantics(Object available, Object total) {
    return '$available places libres sur $total';
  }

  @override
  String get searchFilterButton => 'Filtres';

  @override
  String get searchSortLabel => 'Trier par';

  @override
  String get searchSortTime => 'Heure';

  @override
  String get searchSortPrice => 'Prix';

  @override
  String get searchSortSeats => 'Places';

  @override
  String get searchDayToday => 'Aujourd’hui';

  @override
  String get searchDayTomorrow => 'Demain';

  @override
  String get searchRetry => 'Réessayer';

  @override
  String get searchLoadError => 'Impossible de charger les trajets';

  @override
  String get searchNoLouage => 'Aucun louage pour ce trajet';

  @override
  String get searchAfterRequestedTime => 'Après l’heure choisie';

  @override
  String get searchReservation => 'Réserver';

  @override
  String get searchFilterTitle => 'Filtres';

  @override
  String searchMaxPrice(Object amount) {
    return 'Prix maximum : $amount DT';
  }

  @override
  String searchMinimumSeats(Object count) {
    return 'Places minimum : $count';
  }

  @override
  String searchTimeRange(Object end, Object start) {
    return 'Horaire : $start – $end';
  }

  @override
  String get searchApplyFilters => 'Appliquer';

  @override
  String get louageDetailTitle => 'Détail du louage';

  @override
  String get louageNotFound => 'Louage introuvable';

  @override
  String get louageDetailUnavailable => 'Détail indisponible';

  @override
  String get louageDepartureUnavailable => 'Horaire indisponible';

  @override
  String get louageVehicle => 'Véhicule';

  @override
  String get louagePricePerSeat => 'Prix par place';

  @override
  String louageSeatsFreeOfTotal(Object available, Object total) {
    return '$available places libres sur $total';
  }

  @override
  String louageDriverRating(String rating) {
    return 'Note du chauffeur : $rating / 5';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileChangePhone => 'Modifier le numéro de téléphone';

  @override
  String get profileNewPhoneLabel => 'Nouveau numéro de téléphone';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileTerms => 'Conditions d’utilisation';

  @override
  String get profileDriverTitle => 'Profil chauffeur';

  @override
  String get profilePassengerFallback => 'Passager';

  @override
  String get profileDriverFallback => 'Chauffeur';

  @override
  String get widgetGalleryTitle => 'Catalogue des widgets';

  @override
  String get widgetGalleryFields => 'Champs de formulaire';

  @override
  String get widgetGalleryValidate => 'Valider';

  @override
  String get widgetGalleryFormValid => 'Formulaire valide';

  @override
  String get widgetGalleryEmail => 'Adresse e-mail';

  @override
  String get widgetGalleryPassword => 'Mot de passe';

  @override
  String get widgetGalleryPasswordMin => '6 caractères minimum';

  @override
  String get widgetGalleryButtons => 'Boutons';

  @override
  String get widgetGalleryPrimary => 'Primaire';

  @override
  String get widgetGallerySecondary => 'Secondaire';

  @override
  String get widgetGalleryAccent => 'Accent';

  @override
  String get widgetGalleryLoading => 'Chargement';

  @override
  String get widgetGalleryStatuses => 'Statuts de trajet';

  @override
  String get widgetGalleryCardsSeats => 'Carte et places';

  @override
  String get widgetGalleryDeparturePrice => 'Départ 08:00 · 18 DT';

  @override
  String get widgetGalleryLoadingSection => 'Chargement';

  @override
  String get widgetGalleryEmpty => 'État vide';

  @override
  String get widgetGalleryNoSavedTrip => 'Aucun trajet enregistré';

  @override
  String get widgetGalleryAvailableTripsAppear =>
      'Les trajets disponibles apparaîtront ici.';

  @override
  String get widgetGallerySearch => 'Rechercher';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsThemeLabel => 'Thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguageLabel => 'Langue';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'Anglais';

  @override
  String get settingsLanguageArabic => 'Arabe';
}
