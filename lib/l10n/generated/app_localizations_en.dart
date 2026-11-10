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
  String get authInvalidPhone => 'Invalid phone number';

  @override
  String get authOtpInvalid => 'Incorrect verification code';

  @override
  String get authOtpExpired => 'The verification code has expired';

  @override
  String get authOtpTooManyAttempts => 'Too many attempts. Request a new code';

  @override
  String get authOtpResendTooSoon =>
      'Please wait before requesting another code';

  @override
  String get authPhoneNotRegistered =>
      'No account is associated with this number';

  @override
  String get authAccountBlocked => 'This account is blocked';

  @override
  String get authProfileUnavailable => 'The profile could not be found.';

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
  String get bookingReviewAction => 'Review booking';

  @override
  String get bookingReviewTitle => 'Review your booking';

  @override
  String get bookingConfirmAction => 'Confirm and book';

  @override
  String get bookingConfirmed => 'Booking confirmed';

  @override
  String get bookingTicketReady => 'Your ticket is ready';

  @override
  String get bookingReference => 'Reference';

  @override
  String get bookingSeats => 'Seats';

  @override
  String get bookingDriver => 'Driver';

  @override
  String get bookingMatricule => 'Vehicle registration';

  @override
  String get bookingDeparture => 'Departure';

  @override
  String get bookingTotal => 'Total';

  @override
  String get bookingPayment => 'Payment';

  @override
  String get bookingDownloadTicket => 'Save / share PDF ticket';

  @override
  String get ticketEmailSend => 'Send by email';

  @override
  String get ticketEmailDialogTitle => 'Recipient email address';

  @override
  String get ticketEmailAddress => 'Email address';

  @override
  String get ticketEmailInvalidAddress => 'Enter a valid email address.';

  @override
  String ticketEmailSent(String email) {
    return 'Ticket sent to $email.';
  }

  @override
  String get ticketEmailNotConfigured => 'Email delivery is not configured.';

  @override
  String get ticketEmailNetworkError =>
      'Network error. Check your connection and try again.';

  @override
  String get ticketEmailTimeoutError =>
      'The email service took too long to respond.';

  @override
  String get ticketEmailInvalidKey =>
      'The email service configuration is invalid.';

  @override
  String get ticketEmailInvalidRequest =>
      'The email request or sender is invalid.';

  @override
  String get ticketEmailQuotaError =>
      'The email sending limit has been reached. Try again later.';

  @override
  String get ticketEmailServerError =>
      'The ticket could not be sent right now.';

  @override
  String get ticketEmailSubject => 'Your LouageGo ticket';

  @override
  String get ticketEmailFrom => 'From';

  @override
  String get ticketEmailTo => 'To';

  @override
  String get ticketEmailDeparture => 'Departure date and time';

  @override
  String get bookingDetails => 'Booking details';

  @override
  String get bookingCancel => 'Cancel';

  @override
  String get bookingCancelTitle => 'Cancel booking?';

  @override
  String get bookingCancelMessage =>
      'Cancellation is available until 2 hours before departure.';

  @override
  String get bookingEmpty => 'No bookings yet';

  @override
  String get bookingPerSeat => 'per seat';

  @override
  String bookingSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Summary ($count seats)',
      one: 'Summary (1 seat)',
    );
    return '$_temp0';
  }

  @override
  String get bookingChooseSeatsTitle => 'Choose my seat';

  @override
  String bookingSeatLabel(int number, String status) {
    return 'Seat $number: $status';
  }

  @override
  String get bookingSeatUnavailable =>
      'That seat was just reserved. Please choose another.';

  @override
  String get bookingNotEnoughSeats => 'There are not enough free seats.';

  @override
  String get bookingTripUnavailable => 'This trip is no longer available.';

  @override
  String get bookingLouageUnavailable => 'This louage is no longer available.';

  @override
  String get bookingPaymentSimulation => 'Payment';

  @override
  String get bookingPaymentMethod => 'Payment method';

  @override
  String get bookingPayOnBoarding => 'Pay on boarding';

  @override
  String get bookingCardSimulation => 'Bank card';

  @override
  String get bookingMobileSimulation => 'Mobile wallet';

  @override
  String get bookingDriverSeat => 'Driver';

  @override
  String get bookingTaken => 'Taken';

  @override
  String get bookingSelected => 'Selected';

  @override
  String get bookingFree => 'Free';

  @override
  String get commonLoading => 'Loading';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusConfirmed => 'Confirmed';

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
  String get loginMethodPhone => 'Phone';

  @override
  String get loginMethodEmail => 'Email';

  @override
  String get loginPhoneLabel => 'Phone';

  @override
  String get loginSendCode => 'Send me a code';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginAccountInaccessible => 'Can\'t access your account?';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginGoogleUnavailable => 'Google sign-in is not configured.';

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
  String get registerEmailOptional => 'Email (optional)';

  @override
  String get registerUseEmail => 'Use email instead';

  @override
  String get registerUsePhone => 'Use phone instead';

  @override
  String get registerAcceptTerms => 'I agree to';

  @override
  String get registerTermsLink => 'the terms of service';

  @override
  String get registerAnd => 'and';

  @override
  String get registerPrivacyLink => 'the privacy policy';

  @override
  String get registerConsentRequired =>
      'Accept the terms and privacy policy to continue.';

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
  String otpCodeSentTo(String phone) {
    return 'Enter the code sent to $phone';
  }

  @override
  String get otpVerifyAction => 'Verify code';

  @override
  String get otpResendAction => 'Resend code';

  @override
  String otpResendCountdown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String otpDemoCode(String code) {
    return 'Demo mode: your code is $code';
  }

  @override
  String get otpCodeResent => 'A new code has been generated.';

  @override
  String get otpCodeVerified => 'Phone number verified.';

  @override
  String get legalTermsTitle => 'Terms of service';

  @override
  String legalUpdatedAt(String date) {
    return 'Updated $date';
  }

  @override
  String legalDocumentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get legalDemoDisclaimer =>
      'Demonstration version: this text must be reviewed by legal counsel before publication.';

  @override
  String get legalTableOfContents => 'Table of contents';

  @override
  String get legalContactLabel => 'Contact:';

  @override
  String get legalUpdateTitle => 'Updated terms';

  @override
  String get legalUpdateMessage =>
      'The terms and privacy policy have been updated. Please read and accept this version to continue.';

  @override
  String get legalAcceptUpdate => 'Accept and continue';

  @override
  String get legalSignOut => 'Sign out';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'App preferences';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get settingsSupportSection => 'Help and information';

  @override
  String get profileFirstNameLabel => 'First name';

  @override
  String get profileLastNameLabel => 'Last name';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutMessage => 'Are you sure you want to sign out?';

  @override
  String get helpSupportTitle => 'Help & support';

  @override
  String get supportTitle => 'LouageGo support';

  @override
  String get supportFaqTitle => 'Frequently asked questions';

  @override
  String get supportContactTitle => 'Contact support';

  @override
  String get supportRequestsTitle => 'My requests';

  @override
  String get supportRequestDetailTitle => 'Request details';

  @override
  String get supportQuickContact => 'Quick contact';

  @override
  String get supportCallAction => 'Call';

  @override
  String get supportEmailAction => 'Email';

  @override
  String get supportWhatsappAction => 'WhatsApp';

  @override
  String get supportContactUnavailable =>
      'No app is available for this action.';

  @override
  String get supportFaqSearch => 'Search questions';

  @override
  String get supportClearSearch => 'Clear search';

  @override
  String get supportFaqAll => 'All';

  @override
  String get supportFaqEmpty =>
      'No results. Try different keywords or categories.';

  @override
  String get supportCategoryBooking => 'Booking';

  @override
  String get supportCategoryPayment => 'Payment';

  @override
  String get supportCategoryTrip => 'Trip and tracking';

  @override
  String get supportCategoryAccount => 'Account';

  @override
  String get supportCategoryDrivers => 'Drivers';

  @override
  String get supportCategoryBug => 'Technical issue';

  @override
  String get supportCategoryOther => 'Other';

  @override
  String get supportCategoryLabel => 'Category';

  @override
  String get supportTripReference => 'Trip reference (optional)';

  @override
  String get supportMessageLabel => 'Your message';

  @override
  String get supportSendRequest => 'Send request';

  @override
  String get supportRequestSent => 'Your request has been sent.';

  @override
  String get supportTooManyOpenRequests =>
      'You already have 3 open support requests.';

  @override
  String get supportCategoryRequired => 'Choose a category.';

  @override
  String get supportMessageInvalid =>
      'The message must contain 10 to 1000 characters.';

  @override
  String get supportSignInRequired => 'Sign in to send or view your requests.';

  @override
  String get supportSubmissionFailed =>
      'Could not send the request. Please try again.';

  @override
  String get supportLoadFailed => 'Could not load requests.';

  @override
  String get supportRetry => 'Try again';

  @override
  String get supportRequestsEmpty => 'You have no support requests.';

  @override
  String get supportRequestNotFound => 'This request could not be found.';

  @override
  String get supportAdminReply => 'Support reply';

  @override
  String get supportNoAdminReply => 'There is no reply yet.';

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusInProgress => 'In progress';

  @override
  String get supportStatusResolved => 'Resolved';

  @override
  String get supportEmailSubject => 'LouageGo support request';

  @override
  String get helpFaqSection => 'Frequently asked questions';

  @override
  String get helpFaqBookingQuestion => 'How do I find a trip?';

  @override
  String get helpFaqBookingAnswer =>
      'Choose your departure and destination cities on the home screen. Available trips will then be shown.';

  @override
  String get helpFaqPaymentQuestion => 'How do I book a seat?';

  @override
  String get helpFaqPaymentAnswer =>
      'Open an available trip to review its details and the booking actions provided.';

  @override
  String get helpFaqPhoneQuestion => 'How do I change my phone number?';

  @override
  String get helpFaqPhoneAnswer =>
      'From your profile, open Edit profile and choose Change phone number. Verification is completed with an OTP code.';

  @override
  String get helpHowItWorksTitle => 'How LouageGo works';

  @override
  String get helpHowItWorksBody =>
      'Choose your departure and destination, browse available trips, then open a trip to view its details. Drivers can manage their workspace from their profile.';

  @override
  String get helpContactTitle => 'Contact us';

  @override
  String get helpContactSupport => 'Contact support';

  @override
  String get helpEmailCopied => 'Support email copied.';

  @override
  String get helpReportProblem => 'Report a problem';

  @override
  String get helpReportHint => 'Describe the problem you encountered';

  @override
  String get helpCopyReport => 'Copy report';

  @override
  String get helpReportCopied => 'Report copied. You can send it to support.';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileCityLabel => 'City';

  @override
  String get profileCityNotSet => 'No city selected';

  @override
  String get profileChooseGallery => 'Choose from gallery';

  @override
  String get profileChooseCamera => 'Take a photo';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profilePhotoError => 'The photo could not be selected or saved.';

  @override
  String get profilePhotoCleanupWarning =>
      'Profile saved, but the previous photo could not be removed.';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get profileUnavailable => 'Profile unavailable.';

  @override
  String get profileSaveAction => 'Save';

  @override
  String get profilePhoneUpdated => 'Phone number updated.';

  @override
  String get profileHelpBody =>
      'Frequently asked questions\n\nHow do I book a trip? Choose your departure and destination cities, then select an available trip.\n\nHow do I change my phone number? Open Edit profile and select Change phone number. A verification code will be required.\n\nHow do I protect my account? Keep control of your phone and sign-in information.';

  @override
  String get deleteAccountAction => 'Delete my account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountWarning =>
      'This action is permanent. Your favorites, notifications, and profile data will be deleted. Bookings and reviews will be kept in anonymized form.';

  @override
  String get deleteAccountConfirmTitle => 'Confirm deletion';

  @override
  String get deleteAccountConfirmationWord => 'DELETE';

  @override
  String deleteAccountTypeConfirmation(String word) {
    return 'Type $word to confirm.';
  }

  @override
  String get deleteAccountConfirmationMismatch =>
      'The entered word does not match.';

  @override
  String get deleteAccountCompleted => 'Your account has been deleted.';

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
  String driverHomeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get driverHomeSubtitle => 'Manage your louage and departures.';

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
  String driverSeatCounts(String reserved, String free) {
    return '$reserved seats occupied · $free free';
  }

  @override
  String driverDepartureTime(String time) {
    return 'Departure time';
  }

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
  String get stationsTitle => 'Stations';

  @override
  String get stationsSearchLabel => 'Search stations';

  @override
  String get stationsBrowsePrompt => 'Browse stations across Tunisia';

  @override
  String get stationsLoadError => 'Could not load stations';

  @override
  String get stationsNoResults => 'No stations found';

  @override
  String get stationsSearchFrom => 'Search from this station';

  @override
  String get locationUseMyPosition => 'Use my location';

  @override
  String get locationConsentTitle => 'Use your location?';

  @override
  String get locationConsentMessage =>
      'Your location is only used to find nearby stations. It is not shared.';

  @override
  String get locationConsentPrivacyLink => 'Read the privacy policy';

  @override
  String get locationConsentAccept => 'Continue';

  @override
  String get locationDenied => 'Location access was denied.';

  @override
  String get locationDeniedForever =>
      'Allow location access in the app settings.';

  @override
  String get locationServiceDisabled =>
      'Turn on your device location services.';

  @override
  String get locationError => 'Could not get your location.';

  @override
  String get locationOpenSettings => 'Open settings';

  @override
  String get locationNearestEmpty =>
      'No stations with a known location were found.';

  @override
  String get stationsMapTitle => 'Station map';

  @override
  String get stationsMapUnavailable => 'Map unavailable offline';

  @override
  String get stationsMapRecenter => 'Recenter map';

  @override
  String get stationsMapMyPosition => 'My location';

  @override
  String get stationsMapFavoritesSoon =>
      'Adding favorites will be available soon';

  @override
  String stationsMapRouteCount(int count) {
    return '$count routes departing here';
  }

  @override
  String get favoriteAddRoute => 'Add this route to favorites';

  @override
  String get favoriteRemoveRoute => 'Remove this route from favorites';

  @override
  String get favoriteAddStation => 'Add this station to favorites';

  @override
  String get favoriteRemoveStation => 'Remove this station from favorites';

  @override
  String get favoriteUpdateError => 'Could not update favorites.';

  @override
  String get favoritesTabOffers => 'Offers';

  @override
  String get favoritesRoutesTab => 'Routes';

  @override
  String get favoritesStationsTab => 'Stations';

  @override
  String get favoritesEmptyOffers => 'No favorite offers yet.';

  @override
  String get favoritesEmptyRoutes => 'No favorite routes yet.';

  @override
  String get favoritesEmptyStations => 'No favorite stations yet.';

  @override
  String get favoritesUndo => 'Undo';

  @override
  String get favoritesRemoved => 'Favorite removed.';

  @override
  String get favoritesOfferAdd => 'Add this offer to favorites';

  @override
  String get favoritesOfferRemove => 'Remove this offer from favorites';

  @override
  String get favoritesNoDeparture => 'No departure available';

  @override
  String favoritesNextDeparture(String date) {
    return 'Next departure: $date';
  }

  @override
  String get favoritesOtherSchedules => 'See other schedules';

  @override
  String get favoritesMyOffers => 'My offers';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filtersHideFull => 'Hide full trips';

  @override
  String filtersActiveCount(int count) {
    return '$count active filters';
  }

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
  String get searchNoLouage => 'No louage available';

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
  String get driverLouageProfileTitle => 'Driver and louage profile';

  @override
  String get driverLouageProfileSubtitle => 'Enter your vehicle information.';

  @override
  String get driverVehicleModel => 'Make and model';

  @override
  String get driverMatricule => 'License plate';

  @override
  String get driverMatriculeRequired => 'Enter the vehicle license plate.';

  @override
  String get driverTotalSeats => 'Total seats';

  @override
  String get driverTotalSeatsInvalid =>
      'Enter a total seat count greater than zero.';

  @override
  String get driverAvailableSeats => 'Available seats';

  @override
  String get driverAvailableSeatsInvalid =>
      'Available seats must be between zero and the total seat count.';

  @override
  String get driverCurrentStation => 'Current station';

  @override
  String get driverStationRequired => 'Choose or enter the current station.';

  @override
  String get driverRatingAverage => 'Average rating';

  @override
  String get driverCompletedTrips => 'Completed trips';

  @override
  String get driverDashboardStatsTitle => 'Statistics';

  @override
  String get driverDashboardRevenueTitle => 'Revenue';

  @override
  String get driverRevenueToday => 'Today';

  @override
  String get driverRevenueWeek => 'This week';

  @override
  String get driverDepartureTimeLabel => 'Departure time';

  @override
  String driverScanRevenueAdded(String amount) {
    return '+$amount DT added to your earnings';
  }

  @override
  String get driverEarningsTotal => 'Total earnings';

  @override
  String get driverRevenueMonth => 'This month';

  @override
  String get driverEarningsScannedCount => 'Tickets scanned';

  @override
  String get driverEarningsChart => 'Earnings by day';

  @override
  String get driverEarningsLast7Days => '7 days';

  @override
  String get driverEarningsLast30Days => '30 days';

  @override
  String get driverEarningsRecent => 'Recent earnings';

  @override
  String get driverEarningsEmpty =>
      'No earnings recorded yet. Scan a valid ticket to get started.';

  @override
  String get driverEarningsExport => 'Export CSV';

  @override
  String get driverEarningsExportFailed => 'Couldn\'t share the CSV file.';

  @override
  String get driverEarningsUnknown => 'Unknown';

  @override
  String driverEarningsRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get driverEarningsCsvPassenger => 'Passenger';

  @override
  String get driverEarningsCsvRoute => 'Route';

  @override
  String get driverEarningsCsvAmount => 'Amount';

  @override
  String get driverEarningsCsvDate => 'Date and time';

  @override
  String get driverEarningsCsvMethod => 'Payment method';

  @override
  String get driverSaveLouage => 'Save louage';

  @override
  String get driverLouageSaved => 'Louage profile saved.';

  @override
  String get driverLouageSaveFailed =>
      'Couldn\'t save the louage. Check the details and try again.';

  @override
  String get driverChangeStatus => 'Change status';

  @override
  String get driverStatusUpdated => 'Louage status updated.';

  @override
  String get driverStatusUpdateFailed =>
      'Couldn\'t update the status. Please try again.';

  @override
  String get driverStatsUnavailable =>
      'Statistics are temporarily unavailable.';

  @override
  String get driverStatusAvailable => 'Available';

  @override
  String get driverStatusWaiting => 'Waiting';

  @override
  String get driverStatusInTransit => 'In transit';

  @override
  String get driverStatusOutOfService => 'Out of service';

  @override
  String get driverConfirmStatus => 'Confirm status change?';

  @override
  String get driverTripsTitle => 'My trips';

  @override
  String get driverTripsEmpty => 'There are no trips yet';

  @override
  String get driverTripDetail => 'Trip details';

  @override
  String get driverTripDateTime => 'Date and time';

  @override
  String get driverTripPrice => 'Price per seat';

  @override
  String get driverCurrencyDt => 'DT';

  @override
  String get driverTripPriceRequired => 'Enter a price per seat.';

  @override
  String get driverTripPriceInvalid => 'Price must be greater than 0 DT.';

  @override
  String get driverTripPriceTooHigh => 'Price cannot exceed 100 DT.';

  @override
  String get driverTripPriceDecimals =>
      'Price can have no more than two decimal places.';

  @override
  String get driverAccountNotValidated =>
      'Validate your driver account before adding a trip.';

  @override
  String get driverAddTrip => 'Add a trip';

  @override
  String get driverTripDuration => 'Duration';

  @override
  String get driverTripPreview => 'Trip preview';

  @override
  String driverTripSeatsAvailable(String available, String total) {
    return '$available / $total seats available';
  }

  @override
  String get driverCreateTripTitle => 'New trip';

  @override
  String get driverCreateTripSubtitle =>
      'Set your current station and destination.';

  @override
  String get driverDestination => 'Destination';

  @override
  String get driverDepartureDate => 'Departure date';

  @override
  String get driverPublishTrip => 'Publish trip';

  @override
  String get driverTripPublished =>
      'The trip was published and is now visible to passengers.';

  @override
  String get driverTripCreationError =>
      'Couldn\'t publish this trip. Check the details and try again.';

  @override
  String get driverTripSameStation =>
      'Current station and destination must be different.';

  @override
  String get driverLouageMissing =>
      'No louage is associated with this driver account.';

  @override
  String get driverLouageOutOfService =>
      'This louage is out of service and cannot publish trips.';

  @override
  String get driverDepartureInPast => 'Departure time must be in the future.';

  @override
  String get driverDuplicateDeparture =>
      'A trip is already scheduled at this time.';

  @override
  String get driverTripMissing => 'This trip could not be found.';

  @override
  String get driverTripNotWaiting => 'Only waiting trips can be cancelled.';

  @override
  String get driverCreateFirstTrip => 'Create my first trip';

  @override
  String get driverTripCancel => 'Cancel';

  @override
  String get driverTripCancelTitle => 'Cancel this trip?';

  @override
  String get driverTripCancelMessage =>
      'This will remove the waiting trip from the passenger list.';

  @override
  String get driverTripCancelled => 'The trip was cancelled.';

  @override
  String get driverBookingsTitle => 'Bookings and passengers';

  @override
  String driverBookingPayment(String status) {
    return 'Payment: $status';
  }

  @override
  String driverBookingStatus(String status) {
    return 'Booking: $status';
  }

  @override
  String get driverUpdateSeats => 'Update available seats';

  @override
  String get driverScanInstructions =>
      'Scan the ticket QR code for the selected trip.';

  @override
  String get driverScanSelectTrip => 'Select the trip to check';

  @override
  String get driverScanValid => 'Valid ticket — booking marked as used.';

  @override
  String get driverScanUsed => 'This ticket has already been used.';

  @override
  String get driverScanInvalid =>
      'Invalid, cancelled, or belongs to another trip.';

  @override
  String get driverRatingTitle => 'Driver average rating';

  @override
  String driverRatingsCount(String count) {
    return '$count reviews';
  }

  @override
  String get driverOperationFailed => 'The operation failed. Please try again.';

  @override
  String get driverPaymentPending => 'Pending';

  @override
  String get driverPaymentPaid => 'Paid';

  @override
  String get driverPaymentCash => 'Pay on board';

  @override
  String get driverPaymentUnknown => 'Unknown payment status';

  @override
  String get driverBookingConfirmed => 'Confirmed';

  @override
  String get driverBookingValidated => 'Validated';

  @override
  String get driverBookingCancelled => 'Cancelled';

  @override
  String get driverBookingRejected => 'Rejected';

  @override
  String get driverBookingUnknown => 'Unknown booking status';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileChangePhone => 'Change phone number';

  @override
  String get profileNewPhoneLabel => 'New phone number';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileTerms => 'Terms and conditions';

  @override
  String get profileDriverTitle => 'Driver profile';

  @override
  String get profileDriverReviews => 'My reviews';

  @override
  String get profilePassengerFallback => 'Passenger';

  @override
  String get profileDriverFallback => 'Driver';

  @override
  String get reviewsTitle => 'Driver reviews';

  @override
  String get reviewsSeeAll => 'See all reviews';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String get reviewsLatest => 'Recent reviews';

  @override
  String get reviewsNoReviews => 'No reviews yet';

  @override
  String get reviewsAnonymous => 'Deleted user';

  @override
  String get reviewsWriteTitle => 'Rate this trip';

  @override
  String get reviewsEditTitle => 'Edit my review';

  @override
  String get reviewsRatingPrompt => 'Choose a rating';

  @override
  String get reviewsRating1 => 'Very disappointing';

  @override
  String get reviewsRating2 => 'Disappointing';

  @override
  String get reviewsRating3 => 'Fair';

  @override
  String get reviewsRating4 => 'Very good';

  @override
  String get reviewsRating5 => 'Excellent';

  @override
  String reviewsStarSemantics(int count) {
    return '$count out of 5 stars';
  }

  @override
  String get reviewsComment => 'Comment (optional)';

  @override
  String get reviewsCommentHint => 'Share your experience';

  @override
  String get reviewsSubmit => 'Submit review';

  @override
  String get reviewsUpdate => 'Save changes';

  @override
  String get reviewsDelete => 'Delete my review';

  @override
  String get reviewsDeleteConfirm => 'Do you want to delete this review?';

  @override
  String get reviewsSaved => 'Your review was submitted.';

  @override
  String get reviewsUpdated => 'Your review was updated.';

  @override
  String get reviewsDeleted => 'Your review was deleted.';

  @override
  String get reviewsNotEligible =>
      'Only completed trips you booked can be reviewed.';

  @override
  String get reviewsAlreadyReviewed => 'You have already reviewed this trip.';

  @override
  String get reviewsInvalidRating => 'Choose a rating from 1 to 5 stars.';

  @override
  String get reviewsInvalidComment =>
      'The comment cannot be longer than 300 characters.';

  @override
  String get reviewsNotFound => 'This review could not be found.';

  @override
  String get reviewsWindowExpired =>
      'Reviews can be edited for 24 hours after submission.';

  @override
  String get reviewsSignInRequired => 'Sign in to continue.';

  @override
  String get reviewsLoadError => 'Couldn\'t load reviews.';

  @override
  String get reviewsReport => 'Report this review';

  @override
  String get reviewsReportTitle => 'Report this review?';

  @override
  String get reviewsReportBody =>
      'Your report will be sent to the moderation team.';

  @override
  String get reviewsReportSent => 'The review was reported.';

  @override
  String get reviewsDistribution => 'Rating breakdown';

  @override
  String get reviewsNoComment => 'No comment';

  @override
  String get reviewsUnavailable => 'Trip information is unavailable.';

  @override
  String get reviewsAnonymousAuthor => 'Traveler';

  @override
  String get reviewsDeleteAction => 'Delete';

  @override
  String get reviewsCancelAction => 'Cancel';

  @override
  String get reviewsLoadMore => 'Load more';

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

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDescription =>
      'Receive important updates about your trips';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsChannelName => 'LouageGo notifications';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyBody => 'Important updates will appear here.';

  @override
  String get notificationsLoadError => 'Could not load notifications.';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsOlder => 'Older';

  @override
  String get notificationsDeleted => 'Notification deleted';

  @override
  String get notificationsUnread => 'Unread';

  @override
  String get notificationsTypeBooking => 'Booking';

  @override
  String get notificationsTypeTrip => 'Trip';

  @override
  String get notificationsTypePromotion => 'Promotion';

  @override
  String get notificationsTypeSystem => 'Information';

  @override
  String get notificationsPermissionTitle => 'Enable notifications';

  @override
  String get notificationsPermissionExplanation =>
      'LouageGo can send you important updates about your bookings and trips. You can change this permission in your device settings.';

  @override
  String get notificationsPermissionContinue => 'Continue';

  @override
  String get notificationsPermissionDenied =>
      'Notifications are disabled in your device settings.';

  @override
  String get notificationsOpenSettings => 'Open settings';

  @override
  String get searchHideFull => 'Hide full trips';

  @override
  String get searchUseMaximumPrice => 'Set a maximum price';

  @override
  String get searchResetFilters => 'Reset';

  @override
  String get docStepAccountCreated => 'Account created';

  @override
  String get docStepDocumentsSent => 'Documents sent';

  @override
  String get docStepValidated => 'Validated';

  @override
  String get docStepCurrent => 'Current';

  @override
  String get docSectionTitle => 'Required documents';

  @override
  String get docStatusToSend => 'To send';

  @override
  String get docStatusSent => 'Sent';

  @override
  String get docStatusRejected => 'Rejected';

  @override
  String get docStatusValidated => 'Validated';

  @override
  String get docTypeNationalId => 'National ID';

  @override
  String get docTypeDriverLicense => 'Driver\'s licence';

  @override
  String get docTypeVehicleCard => 'Vehicle registration';

  @override
  String get docTypeInsurance => 'Insurance';

  @override
  String get docTypeTransportLicense => 'Transport licence';

  @override
  String get docTypeDriverPhoto => 'Driver photo';

  @override
  String get docTypeVehiclePhoto => 'Vehicle photo';

  @override
  String get docUploadTitle => 'Upload document';

  @override
  String get docUploadFromCamera => 'Take a photo';

  @override
  String get docUploadFromGallery => 'Choose from gallery';

  @override
  String get docUploadPreviewTitle => 'Preview before sending';

  @override
  String get docUploadConfirm => 'Confirm upload';

  @override
  String get docUploadCancel => 'Cancel';

  @override
  String get docUploadSuccess => 'Document uploaded.';

  @override
  String get docUploadError => 'Could not upload the document.';

  @override
  String get docResend => 'Resend';

  @override
  String get docRejectionReason => 'Rejection reason';

  @override
  String get docSubmitAll => 'Submit documents';

  @override
  String get docSubmitConfirmTitle => 'Submit all documents?';

  @override
  String get docSubmitConfirmBody =>
      'Your documents will be sent for review. This action cannot be undone.';

  @override
  String get docSubmitSuccess => 'Documents submitted successfully.';

  @override
  String get docLockedPreviewTitle => 'Driver workspace';

  @override
  String get docLockedPreviewBody =>
      'These features will be available after your account is validated.';

  @override
  String get docHelpTitle => 'Need help?';

  @override
  String get docHelpFaq => 'Frequently asked questions';

  @override
  String get docHelpContact => 'Contact support';

  @override
  String get docValidationStatusPending => 'Account pending';

  @override
  String get docValidationStatusSubmitted =>
      'Documents sent — awaiting validation';

  @override
  String get docValidationStatusApproved => 'Account validated';

  @override
  String get docValidationStatusRejected => 'Account rejected';

  @override
  String get driverDelayTitle => 'Announce a delay';

  @override
  String get driverDelayNewTime => 'New departure time';

  @override
  String get driverDelayReason => 'Reason (optional)';

  @override
  String get driverDelayConfirm => 'Announce delay';

  @override
  String get driverDelaySuccess =>
      'Passengers have been notified of the delay.';

  @override
  String get driverReportTitle => 'Report a problem';

  @override
  String get driverReportBreakdown => 'Breakdown';

  @override
  String get driverReportDelay => 'Delay';

  @override
  String get driverReportOther => 'Other';

  @override
  String get driverReportSend => 'Send report';

  @override
  String get driverReportSuccess => 'Report sent to passengers.';

  @override
  String get driverNavigateTitle => 'Route to station';

  @override
  String get driverNavigateOpen => 'Open in Maps';

  @override
  String get driverNavigateNoCoords => 'Station coordinates unavailable.';

  @override
  String get routeToStationTitle => 'Distance to departure station';

  @override
  String routeDistanceFromStation(String distance) {
    return 'You are $distance from the departure station';
  }

  @override
  String routeDurationByCar(String duration) {
    return '≈ $duration by car';
  }

  @override
  String routeDistanceMeters(String meters) {
    return '$meters m';
  }

  @override
  String routeDistanceKilometers(String kilometers) {
    return '$kilometers km';
  }

  @override
  String routeDurationMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String routeDurationHours(String hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String get routeArrivedAtStation => 'You have arrived at the station';

  @override
  String get routeErrorNetwork => 'Could not connect to the routing service.';

  @override
  String get routeErrorTimeout => 'The route calculation took too long.';

  @override
  String get routeErrorNoRoute => 'No driving route was found.';

  @override
  String get routeErrorInvalidResponse =>
      'The routing service returned an invalid response.';

  @override
  String get routeRetry => 'Retry';

  @override
  String get routeRefresh => 'Refresh';
}
