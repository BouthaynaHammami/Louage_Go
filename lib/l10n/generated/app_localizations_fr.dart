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
  String get authAccountBlocked => 'Ce compte est bloqué';

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
  String get loginWelcome => 'Bienvenue sur LouageGo';

  @override
  String get loginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

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
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerSubmit => 'Créer mon compte';

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
  String get profileTitle => 'Profil';

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
