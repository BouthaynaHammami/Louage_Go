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
  String get bookingReviewAction => 'Vérifier la réservation';

  @override
  String get bookingReviewTitle => 'Récapitulatif de la réservation';

  @override
  String get bookingConfirmAction => 'Confirmer et réserver';

  @override
  String get bookingConfirmed => 'Réservation confirmée';

  @override
  String get bookingTicketReady => 'Votre billet est prêt';

  @override
  String get bookingReference => 'Référence';

  @override
  String get bookingSeats => 'Places';

  @override
  String get bookingDriver => 'Conducteur';

  @override
  String get bookingMatricule => 'Matricule';

  @override
  String get bookingDeparture => 'Départ';

  @override
  String get bookingTotal => 'Total';

  @override
  String get bookingPayment => 'Paiement';

  @override
  String get bookingDownloadTicket => 'Enregistrer / partager le billet PDF';

  @override
  String get bookingDetails => 'Détails de la réservation';

  @override
  String get bookingCancel => 'Annuler';

  @override
  String get bookingCancelTitle => 'Annuler la réservation ?';

  @override
  String get bookingCancelMessage =>
      'L’annulation est possible jusqu’à 2 heures avant le départ.';

  @override
  String get bookingEmpty => 'Aucune réservation pour le moment';

  @override
  String get bookingPerSeat => 'par place';

  @override
  String bookingSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Récapitulatif ($count places)',
      one: 'Récapitulatif (1 place)',
    );
    return '$_temp0';
  }

  @override
  String get bookingPaymentSimulation => 'Paiement (simulation)';

  @override
  String get bookingPaymentMethod => 'Mode de paiement';

  @override
  String get bookingPayOnBoarding => 'Paiement à l’embarquement';

  @override
  String get bookingCardSimulation => 'Carte bancaire (simulation)';

  @override
  String get bookingMobileSimulation => 'Portefeuille mobile (simulation)';

  @override
  String get bookingDriverSeat => 'Conducteur';

  @override
  String get bookingTaken => 'Occupée';

  @override
  String get bookingSelected => 'Sélectionnée';

  @override
  String get bookingFree => 'Libre';

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
  String legalUpdatedAt(String date) {
    return 'Mis à jour le $date';
  }

  @override
  String legalDocumentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get legalDemoDisclaimer =>
      'Version de démonstration : ce texte doit être validé par un juriste avant publication.';

  @override
  String get legalTableOfContents => 'Sommaire';

  @override
  String get legalContactLabel => 'Contact :';

  @override
  String get legalUpdateTitle => 'Mise à jour des conditions';

  @override
  String get legalUpdateMessage =>
      'Les conditions et la politique de confidentialité ont été mises à jour. Veuillez les lire et accepter cette version pour continuer.';

  @override
  String get legalAcceptUpdate => 'Accepter et continuer';

  @override
  String get legalSignOut => 'Se déconnecter';

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

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
  String get supportTitle => 'Support LouageGo';

  @override
  String get supportFaqTitle => 'Questions fréquentes';

  @override
  String get supportContactTitle => 'Contacter le support';

  @override
  String get supportRequestsTitle => 'Mes demandes';

  @override
  String get supportRequestDetailTitle => 'Détail de la demande';

  @override
  String get supportQuickContact => 'Contact rapide';

  @override
  String get supportCallAction => 'Appeler';

  @override
  String get supportEmailAction => 'E-mail';

  @override
  String get supportWhatsappAction => 'WhatsApp';

  @override
  String get supportContactUnavailable =>
      'Aucune application disponible pour cette action.';

  @override
  String get supportFaqSearch => 'Rechercher une question';

  @override
  String get supportClearSearch => 'Effacer la recherche';

  @override
  String get supportFaqAll => 'Toutes';

  @override
  String get supportFaqEmpty =>
      'Aucun résultat. Essayez d’autres mots-clés ou catégories.';

  @override
  String get supportCategoryBooking => 'Réservation';

  @override
  String get supportCategoryPayment => 'Paiement';

  @override
  String get supportCategoryTrip => 'Trajet et suivi';

  @override
  String get supportCategoryAccount => 'Compte';

  @override
  String get supportCategoryDrivers => 'Chauffeurs';

  @override
  String get supportCategoryBug => 'Problème technique';

  @override
  String get supportCategoryOther => 'Autre';

  @override
  String get supportCategoryLabel => 'Catégorie';

  @override
  String get supportTripReference => 'Référence du trajet (facultatif)';

  @override
  String get supportMessageLabel => 'Votre message';

  @override
  String get supportSendRequest => 'Envoyer la demande';

  @override
  String get supportRequestSent => 'Votre demande a été envoyée.';

  @override
  String get supportTooManyOpenRequests =>
      'Vous avez déjà 3 demandes de support ouvertes.';

  @override
  String get supportCategoryRequired => 'Choisissez une catégorie.';

  @override
  String get supportMessageInvalid =>
      'Le message doit contenir entre 10 et 1000 caractères.';

  @override
  String get supportSignInRequired =>
      'Connectez-vous pour envoyer ou consulter vos demandes.';

  @override
  String get supportSubmissionFailed =>
      'Impossible d’envoyer la demande. Réessayez.';

  @override
  String get supportLoadFailed => 'Impossible de charger les demandes.';

  @override
  String get supportRetry => 'Réessayer';

  @override
  String get supportRequestsEmpty => 'Vous n’avez aucune demande de support.';

  @override
  String get supportRequestNotFound => 'Cette demande est introuvable.';

  @override
  String get supportAdminReply => 'Réponse du support';

  @override
  String get supportNoAdminReply => 'Aucune réponse pour le moment.';

  @override
  String get supportStatusOpen => 'Ouverte';

  @override
  String get supportStatusInProgress => 'En cours';

  @override
  String get supportStatusResolved => 'Résolue';

  @override
  String get supportEmailSubject => 'Demande d’assistance LouageGo';

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
  String driverHomeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get driverHomeSubtitle => 'Gérez votre louage et vos départs.';

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
  String driverSeatCounts(String reserved, String free) {
    return '$reserved places occupées · $free libres';
  }

  @override
  String driverDepartureTime(String time) {
    return 'Départ à $time';
  }

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
  String get stationsTitle => 'Stations';

  @override
  String get stationsSearchLabel => 'Rechercher une station';

  @override
  String get stationsBrowsePrompt => 'Parcourez les stations de Tunisie';

  @override
  String get stationsLoadError => 'Impossible de charger les stations';

  @override
  String get stationsNoResults => 'Aucune station trouvée';

  @override
  String get stationsSearchFrom => 'Rechercher depuis cette station';

  @override
  String get locationUseMyPosition => 'Utiliser ma position';

  @override
  String get locationConsentTitle => 'Utiliser votre position ?';

  @override
  String get locationConsentMessage =>
      'Votre position sert uniquement à trouver les stations les plus proches. Elle n’est pas partagée.';

  @override
  String get locationConsentPrivacyLink =>
      'Lire la politique de confidentialité';

  @override
  String get locationConsentAccept => 'Continuer';

  @override
  String get locationDenied => 'L’accès à la position a été refusé.';

  @override
  String get locationDeniedForever =>
      'Autorisez la position dans les réglages de l’application.';

  @override
  String get locationServiceDisabled =>
      'Activez les services de localisation de votre appareil.';

  @override
  String get locationError => 'Impossible d’obtenir votre position.';

  @override
  String get locationOpenSettings => 'Ouvrir les réglages';

  @override
  String get locationNearestEmpty => 'Aucune station avec une position connue.';

  @override
  String get stationsMapTitle => 'Carte des stations';

  @override
  String get stationsMapUnavailable => 'Carte indisponible hors connexion';

  @override
  String get stationsMapRecenter => 'Recentrer la carte';

  @override
  String get stationsMapMyPosition => 'Ma position';

  @override
  String get stationsMapFavoritesSoon =>
      'Ajouter aux favoris sera bientôt disponible';

  @override
  String stationsMapRouteCount(int count) {
    return '$count lignes au départ';
  }

  @override
  String get favoriteAddRoute => 'Ajouter ce trajet aux favoris';

  @override
  String get favoriteRemoveRoute => 'Retirer ce trajet des favoris';

  @override
  String get favoriteAddStation => 'Ajouter cette station aux favoris';

  @override
  String get favoriteRemoveStation => 'Retirer cette station des favoris';

  @override
  String get favoriteUpdateError => 'Impossible de mettre à jour les favoris.';

  @override
  String get favoritesTabOffers => 'Offres';

  @override
  String get favoritesRoutesTab => 'Trajets';

  @override
  String get favoritesStationsTab => 'Stations';

  @override
  String get favoritesEmptyOffers => 'Aucune offre favorite pour le moment.';

  @override
  String get favoritesEmptyRoutes => 'Aucun trajet favori pour le moment.';

  @override
  String get favoritesEmptyStations =>
      'Aucune station favorite pour le moment.';

  @override
  String get favoritesUndo => 'Annuler';

  @override
  String get favoritesRemoved => 'Favori supprimé.';

  @override
  String get favoritesOfferAdd => 'Ajouter cette offre aux favoris';

  @override
  String get favoritesOfferRemove => 'Retirer cette offre des favoris';

  @override
  String get favoritesNoDeparture => 'Aucun départ disponible';

  @override
  String favoritesNextDeparture(String date) {
    return 'Prochain départ : $date';
  }

  @override
  String get favoritesOtherSchedules => 'Voir les autres horaires';

  @override
  String get favoritesMyOffers => 'Mes offres';

  @override
  String get filtersReset => 'Réinitialiser';

  @override
  String get filtersHideFull => 'Masquer les trajets complets';

  @override
  String filtersActiveCount(int count) {
    return '$count filtres actifs';
  }

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
  String get profileDriverReviews => 'Mes avis';

  @override
  String get profilePassengerFallback => 'Passager';

  @override
  String get profileDriverFallback => 'Chauffeur';

  @override
  String get reviewsTitle => 'Avis du chauffeur';

  @override
  String get reviewsSeeAll => 'Voir tous les avis';

  @override
  String reviewsCount(int count) {
    return '$count avis';
  }

  @override
  String get reviewsLatest => 'Avis récents';

  @override
  String get reviewsNoReviews => 'Aucun avis pour le moment';

  @override
  String get reviewsAnonymous => 'Utilisateur supprimé';

  @override
  String get reviewsWriteTitle => 'Noter ce trajet';

  @override
  String get reviewsEditTitle => 'Modifier mon avis';

  @override
  String get reviewsRatingPrompt => 'Choisissez une note';

  @override
  String get reviewsRating1 => 'Très décevant';

  @override
  String get reviewsRating2 => 'Décevant';

  @override
  String get reviewsRating3 => 'Correct';

  @override
  String get reviewsRating4 => 'Très bien';

  @override
  String get reviewsRating5 => 'Excellent';

  @override
  String reviewsStarSemantics(int count) {
    return '$count sur 5 étoiles';
  }

  @override
  String get reviewsComment => 'Commentaire (facultatif)';

  @override
  String get reviewsCommentHint => 'Partagez votre expérience';

  @override
  String get reviewsSubmit => 'Envoyer mon avis';

  @override
  String get reviewsUpdate => 'Enregistrer les modifications';

  @override
  String get reviewsDelete => 'Supprimer mon avis';

  @override
  String get reviewsDeleteConfirm => 'Voulez-vous supprimer cet avis ?';

  @override
  String get reviewsSaved => 'Votre avis a été enregistré.';

  @override
  String get reviewsUpdated => 'Votre avis a été modifié.';

  @override
  String get reviewsDeleted => 'Votre avis a été supprimé.';

  @override
  String get reviewsNotEligible =>
      'Seuls les trajets terminés que vous avez réservés peuvent être notés.';

  @override
  String get reviewsAlreadyReviewed => 'Vous avez déjà noté ce trajet.';

  @override
  String get reviewsInvalidRating => 'Choisissez une note de 1 à 5 étoiles.';

  @override
  String get reviewsInvalidComment =>
      'Le commentaire ne peut pas dépasser 300 caractères.';

  @override
  String get reviewsNotFound => 'Cet avis est introuvable.';

  @override
  String get reviewsWindowExpired =>
      'La modification est possible pendant 24 heures après la publication.';

  @override
  String get reviewsSignInRequired => 'Connectez-vous pour continuer.';

  @override
  String get reviewsLoadError => 'Impossible de charger les avis.';

  @override
  String get reviewsReport => 'Signaler cet avis';

  @override
  String get reviewsReportTitle => 'Signaler cet avis ?';

  @override
  String get reviewsReportBody =>
      'Le signalement sera transmis à l’équipe de modération.';

  @override
  String get reviewsReportSent => 'L’avis a été signalé.';

  @override
  String get reviewsDistribution => 'Répartition des notes';

  @override
  String get reviewsNoComment => 'Aucun commentaire';

  @override
  String get reviewsUnavailable =>
      'Les informations du trajet ne sont pas disponibles.';

  @override
  String get reviewsAnonymousAuthor => 'Voyageur';

  @override
  String get reviewsDeleteAction => 'Supprimer';

  @override
  String get reviewsCancelAction => 'Annuler';

  @override
  String get reviewsLoadMore => 'Voir plus';

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

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDescription =>
      'Recevoir les mises à jour importantes de vos trajets';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsChannelName => 'Notifications LouageGo';

  @override
  String get notificationsEmptyTitle => 'Aucune notification';

  @override
  String get notificationsEmptyBody =>
      'Vos mises à jour importantes apparaîtront ici.';

  @override
  String get notificationsLoadError =>
      'Impossible de charger les notifications.';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsToday => 'Aujourd’hui';

  @override
  String get notificationsYesterday => 'Hier';

  @override
  String get notificationsOlder => 'Plus ancien';

  @override
  String get notificationsDeleted => 'Notification supprimée';

  @override
  String get notificationsUnread => 'Non lue';

  @override
  String get notificationsTypeBooking => 'Réservation';

  @override
  String get notificationsTypeTrip => 'Trajet';

  @override
  String get notificationsTypePromotion => 'Promotion';

  @override
  String get notificationsTypeSystem => 'Information';

  @override
  String get notificationsPermissionTitle => 'Activer les notifications';

  @override
  String get notificationsPermissionExplanation =>
      'LouageGo peut vous envoyer des mises à jour sur vos réservations et vos trajets. Vous pourrez modifier cette autorisation dans les réglages de votre appareil.';

  @override
  String get notificationsPermissionContinue => 'Continuer';

  @override
  String get notificationsPermissionDenied =>
      'Les notifications sont désactivées dans les réglages de l’appareil.';

  @override
  String get notificationsOpenSettings => 'Ouvrir les réglages';

  @override
  String get searchHideFull => 'Masquer les trajets complets';

  @override
  String get searchUseMaximumPrice => 'Limiter le prix';

  @override
  String get searchResetFilters => 'Réinitialiser';
}
