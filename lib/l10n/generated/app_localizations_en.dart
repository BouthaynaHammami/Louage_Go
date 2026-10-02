// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authInvalidCredentials => 'Incorrect email or password';

  @override
  String get authEmailAlreadyUsed => 'This email is already in use';

  @override
  String get authWeakPassword => 'Password too weak (minimum 6 characters)';

  @override
  String get authInvalidEmail => 'Invalid email address';

  @override
  String get authPhoneAlreadyUsed => 'This phone number is already in use';

  @override
  String get authAccountBlocked => 'This account is blocked';

  @override
  String get authUnexpectedError => 'An authentication error occurred.';

  @override
  String authResetCodeGenerated(String code) {
    return 'Password reset code: $code';
  }

  @override
  String get authInvalidResetCode =>
      'The reset code is incorrect or has expired.';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetEmailLabel => 'Email address';

  @override
  String get authResetCodeLabel => 'Verification code';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authContinue => 'Continue';

  @override
  String get authCancel => 'Cancel';

  @override
  String get authResetAction => 'Reset password';

  @override
  String get authResetCompleted => 'Password reset successfully';

  @override
  String get splashSlogan => 'Book your seat in one tap';

  @override
  String get onboardingReserveTitle => 'Book your trip';

  @override
  String get onboardingReserveBody =>
      'Choose your destination and departure time in just a few moments.';

  @override
  String get onboardingTrackTitle => 'Track your departure';

  @override
  String get onboardingTrackBody =>
      'Find the details you need for your trip in one place.';

  @override
  String get onboardingPayTitle => 'Pay with ease';

  @override
  String get onboardingPayBody =>
      'Get your booking ready and travel with peace of mind.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get appTitle => 'LouageGo';

  @override
  String get commonLoading => 'Loading';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusFull => 'Full';

  @override
  String get statusDeparted => 'Departed';

  @override
  String get statusArrived => 'Arrived';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get storageUnavailableTitle => 'Local storage unavailable';

  @override
  String get storageUnavailableBody =>
      'Check permissions and available storage, then restart the app.';

  @override
  String authWelcomeMessage(String name) {
    return 'Welcome, $name';
  }

  @override
  String get loginWelcome => 'Welcome to LouageGo';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerRolePrompt => 'I am a...';

  @override
  String get registerPassengerRole => 'Passenger';

  @override
  String get registerDriverRole => 'Driver';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerPhoneLabel => 'Phone';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerSubmit => 'Create my account';

  @override
  String get registerSignInLink => 'Already have an account? Sign in';

  @override
  String get registerPasswordStrengthLabel => 'Password strength';

  @override
  String get registerPasswordStrengthWeak => 'Weak';

  @override
  String get registerPasswordStrengthMedium => 'Medium';

  @override
  String get registerPasswordStrengthStrong => 'Strong';

  @override
  String get formRequiredFields => 'Please fill in all fields';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordReveal => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get otpPageTitle => 'Verify your code';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get searchPageNotFound => 'Search not found';

  @override
  String get passengerNavHome => 'Home';

  @override
  String get passengerNavTrips => 'My trips';

  @override
  String get passengerNavFavorites => 'Favorites';

  @override
  String get passengerNavProfile => 'Profile';

  @override
  String get driverNavHome => 'Home';

  @override
  String get driverNavQueue => 'Queue';

  @override
  String get driverNavScan => 'Scan';

  @override
  String get driverNavEarnings => 'Earnings';

  @override
  String get driverNavProfile => 'Profile';

  @override
  String get adminNavDashboard => 'Dashboard';

  @override
  String get adminNavStations => 'Stations';

  @override
  String get adminNavDrivers => 'Drivers';

  @override
  String get adminNavUsers => 'Users';

  @override
  String get adminNavReports => 'Reports';

  @override
  String get adminNavNotifications => 'Notifications';

  @override
  String get adminMenuTitle => 'Administration';

  @override
  String get driverQueueTitle => 'Departure queue';

  @override
  String get driverScanTitle => 'Scan a ticket';

  @override
  String get driverDocumentsTitle => 'Submit documents';

  @override
  String get driverEarningsTitle => 'Earnings';

  @override
  String get driverProfileTitle => 'Driver profile';

  @override
  String get driverHomeTitle => 'Driver area';

  @override
  String get driverProfileUnavailable => 'Driver profile unavailable';

  @override
  String get sessionExpired => 'Your session has expired';

  @override
  String get driverStatusPending => 'Account awaiting approval';

  @override
  String get driverStatusApproved => 'Account approved';

  @override
  String get driverStatusRejected => 'Account rejected';

  @override
  String get driverDocumentsRejectedBody => 'Your application needs an update.';

  @override
  String get driverDocumentsPendingBody =>
      'Submit your documents to activate your driver account.';

  @override
  String get driverDocumentsSubmit => 'Submit documents';

  @override
  String get driverMyLouage => 'My louage';

  @override
  String get driverEditProfile => 'Profile';

  @override
  String get driverNoLouage => 'No louage assigned';

  @override
  String get driverStationUnavailable => 'Current station unavailable';

  @override
  String get driverSeatFill => 'Seats filled';

  @override
  String get driverNoActiveTrip => 'No active departure';

  @override
  String get driverCurrentTrip => 'Current trip';

  @override
  String get driverFillUpdatesNextTrip =>
      'The gauge will update when the next trip is available.';

  @override
  String get driverPassengersReserved => 'Booked passengers';

  @override
  String get driverNoBookings => 'No bookings yet';

  @override
  String get driverBookingsAppearHere => 'Booked passengers will appear here.';

  @override
  String get driverPassengerFallback => 'Passenger';

  @override
  String driverPassengerSeats(Object count, Object name) {
    return '$name — $count seat(s)';
  }

  @override
  String driverBookingSeatCount(Object count) {
    return '$count seat(s)';
  }

  @override
  String get driverSeatWord => 'seats';

  @override
  String get driverJoinQueue => 'Join the queue';

  @override
  String get driverLeaveQueue => 'Leave the queue';

  @override
  String get driverLogout => 'Sign out';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String greetingPassenger(Object name) {
    return 'Hello, $name';
  }

  @override
  String get searchPrompt => 'Where are you going?';

  @override
  String get searchChooseBothCities =>
      'Choose both a departure and destination';

  @override
  String get searchCitiesMustDiffer =>
      'Departure and destination must be different';

  @override
  String get searchDeparture => 'Departure';

  @override
  String get searchDestination => 'Destination';

  @override
  String get searchDate => 'Date';

  @override
  String get searchTime => 'Time';

  @override
  String get searchSubmit => 'Search';

  @override
  String get searchSwapRoute => 'Swap departure and destination';

  @override
  String get searchLastTrips => 'Recent routes';

  @override
  String get searchFavorites => 'Favorites';

  @override
  String get searchPopularTrips => 'Popular routes';

  @override
  String get searchNoPopularTrips => 'No routes are available right now';

  @override
  String get searchNearestStation => 'Nearest station';

  @override
  String get searchLocationPlaceholder =>
      'Location services will be available soon.';

  @override
  String get searchChooseCity => 'Choose a city';

  @override
  String get searchChooseCityPrompt => 'Choose a city';

  @override
  String get searchCitySearch => 'Search for a city';

  @override
  String get searchNoCityFound => 'No city found';

  @override
  String get searchCityPickerTitle => 'Choose a city';

  @override
  String searchPricePerSeat(Object amount) {
    return '$amount TND / seat';
  }

  @override
  String searchRoutePair(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String searchSeatAvailability(Object available, Object total) {
    return '$available of $total seats available';
  }

  @override
  String searchSeatsFree(Object count) {
    return '$count seats available';
  }

  @override
  String searchSeatsAvailableSemantics(Object available, Object total) {
    return '$available of $total seats available';
  }

  @override
  String get searchFilterButton => 'Filters';

  @override
  String get searchSortLabel => 'Sort by';

  @override
  String get searchSortTime => 'Time';

  @override
  String get searchSortPrice => 'Price';

  @override
  String get searchSortSeats => 'Seats';

  @override
  String get searchDayToday => 'Today';

  @override
  String get searchDayTomorrow => 'Tomorrow';

  @override
  String get searchRetry => 'Retry';

  @override
  String get searchLoadError => 'Couldn\'t load the trips';

  @override
  String get searchNoLouage => 'No louage for this route';

  @override
  String get searchAfterRequestedTime => 'After your selected time';

  @override
  String get searchReservation => 'Book';

  @override
  String get searchFilterTitle => 'Filters';

  @override
  String searchMaxPrice(Object amount) {
    return 'Maximum price: $amount TND';
  }

  @override
  String searchMinimumSeats(Object count) {
    return 'Minimum available seats: $count';
  }

  @override
  String searchTimeRange(Object end, Object start) {
    return 'Departure time: $start – $end';
  }

  @override
  String get searchApplyFilters => 'Apply filters';

  @override
  String get louageDetailTitle => 'Louage details';

  @override
  String get louageNotFound => 'Louage not found';

  @override
  String get louageDetailUnavailable => 'Details unavailable';

  @override
  String get louageDepartureUnavailable => 'Departure time unavailable';

  @override
  String get louageVehicle => 'Vehicle';

  @override
  String get louagePricePerSeat => 'Price per seat';

  @override
  String louageSeatsFreeOfTotal(Object available, Object total) {
    return '$available of $total seats available';
  }

  @override
  String louageDriverRating(String rating) {
    return 'Driver rating: $rating / 5';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileTerms => 'Terms and conditions';

  @override
  String get profileDriverTitle => 'Driver profile';

  @override
  String get profilePassengerFallback => 'Passenger';

  @override
  String get profileDriverFallback => 'Driver';

  @override
  String get widgetGalleryTitle => 'Widget gallery';

  @override
  String get widgetGalleryFields => 'Form fields';

  @override
  String get widgetGalleryValidate => 'Validate';

  @override
  String get widgetGalleryFormValid => 'Form is valid';

  @override
  String get widgetGalleryEmail => 'Email address';

  @override
  String get widgetGalleryPassword => 'Password';

  @override
  String get widgetGalleryPasswordMin => 'At least 6 characters';

  @override
  String get widgetGalleryButtons => 'Buttons';

  @override
  String get widgetGalleryPrimary => 'Primary';

  @override
  String get widgetGallerySecondary => 'Secondary';

  @override
  String get widgetGalleryAccent => 'Accent';

  @override
  String get widgetGalleryLoading => 'Loading';

  @override
  String get widgetGalleryStatuses => 'Trip statuses';

  @override
  String get widgetGalleryCardsSeats => 'Card and seats';

  @override
  String get widgetGalleryDeparturePrice => 'Departure 08:00 · 18 TND';

  @override
  String get widgetGalleryLoadingSection => 'Loading';

  @override
  String get widgetGalleryEmpty => 'Empty state';

  @override
  String get widgetGalleryNoSavedTrip => 'No saved trips';

  @override
  String get widgetGalleryAvailableTripsAppear =>
      'Available trips will appear here.';

  @override
  String get widgetGallerySearch => 'Search';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageFrench => 'French';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'Arabic';
}
