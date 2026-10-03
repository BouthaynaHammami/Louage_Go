// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authEmailAlreadyUsed => 'هذا البريد الإلكتروني مستخدم بالفعل';

  @override
  String get authWeakPassword => 'كلمة المرور ضعيفة جدًا (6 أحرف على الأقل)';

  @override
  String get authInvalidEmail => 'عنوان البريد الإلكتروني غير صالح';

  @override
  String get authPhoneAlreadyUsed => 'رقم الهاتف هذا مستخدم بالفعل';

  @override
  String get authInvalidPhone => 'رقم الهاتف غير صالح';

  @override
  String get authOtpInvalid => 'رمز التحقق غير صحيح';

  @override
  String get authOtpExpired => 'انتهت صلاحية رمز التحقق';

  @override
  String get authOtpTooManyAttempts => 'محاولات كثيرة جدًا. اطلب رمزًا جديدًا';

  @override
  String get authOtpResendTooSoon => 'يرجى الانتظار قبل طلب رمز جديد';

  @override
  String get authPhoneNotRegistered => 'لا يوجد حساب مرتبط بهذا الرقم';

  @override
  String get authAccountBlocked => 'هذا الحساب محظور';

  @override
  String get authProfileUnavailable => 'تعذر العثور على الملف الشخصي.';

  @override
  String get authUnexpectedError => 'حدث خطأ أثناء تسجيل الدخول.';

  @override
  String authResetCodeGenerated(String code) {
    return 'رمز إعادة تعيين كلمة المرور: $code';
  }

  @override
  String get authInvalidResetCode =>
      'رمز إعادة التعيين غير صحيح أو انتهت صلاحيته.';

  @override
  String get authResetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetEmailLabel => 'البريد الإلكتروني';

  @override
  String get authResetCodeLabel => 'رمز التحقق';

  @override
  String get authNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authCancel => 'إلغاء';

  @override
  String get authResetAction => 'إعادة التعيين';

  @override
  String get authResetCompleted => 'تم تغيير كلمة المرور';

  @override
  String get splashSlogan => 'احجز مقعدك بلمسة واحدة';

  @override
  String get onboardingReserveTitle => 'احجز رحلتك';

  @override
  String get onboardingReserveBody => 'اختر وجهتك وموعد الانطلاق في لحظات.';

  @override
  String get onboardingTrackTitle => 'تابع موعد انطلاقك';

  @override
  String get onboardingTrackBody =>
      'اعثر على معلومات رحلتك المهمة في مكان واحد.';

  @override
  String get onboardingPayTitle => 'ادفع بسهولة';

  @override
  String get onboardingPayBody => 'أكمل حجزك وسافر براحة واطمئنان.';

  @override
  String get onboardingSkip => 'تخطٍّ';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ الآن';

  @override
  String get appTitle => 'لواج غو';

  @override
  String get commonLoading => 'جارٍ التحميل';

  @override
  String get statusWaiting => 'بانتظار الانطلاق';

  @override
  String get statusFull => 'مكتمل';

  @override
  String get statusDeparted => 'انطلق';

  @override
  String get statusArrived => 'وصل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get storageUnavailableTitle => 'التخزين المحلي غير متاح';

  @override
  String get storageUnavailableBody =>
      'تحقق من الأذونات والمساحة المتاحة، ثم أعد تشغيل التطبيق.';

  @override
  String authWelcomeMessage(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get loginWelcome => 'مرحبًا بك في لواج غو';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get loginMethodPhone => 'الهاتف';

  @override
  String get loginMethodEmail => 'البريد الإلكتروني';

  @override
  String get loginPhoneLabel => 'الهاتف';

  @override
  String get loginSendCode => 'أرسل لي رمزًا';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginAccountInaccessible => 'لا يمكنك الوصول إلى حسابك؟';

  @override
  String get loginContinueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get loginGoogleUnavailable => 'تسجيل الدخول باستخدام Google غير مُعد.';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟';

  @override
  String get loginCreateAccount => 'إنشاء حساب';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerRolePrompt => 'أنا...';

  @override
  String get registerPassengerRole => 'مسافر';

  @override
  String get registerDriverRole => 'سائق';

  @override
  String get registerNameLabel => 'الاسم الكامل';

  @override
  String get registerPhoneLabel => 'رقم الهاتف';

  @override
  String get registerEmailLabel => 'البريد الإلكتروني';

  @override
  String get registerEmailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get registerUseEmail => 'استخدام البريد الإلكتروني';

  @override
  String get registerUsePhone => 'استخدام الهاتف';

  @override
  String get registerAcceptTerms => 'أوافق على';

  @override
  String get registerTermsLink => 'شروط الاستخدام';

  @override
  String get registerAnd => 'و';

  @override
  String get registerPrivacyLink => 'سياسة الخصوصية';

  @override
  String get registerConsentRequired =>
      'يرجى الموافقة على الشروط وسياسة الخصوصية للمتابعة.';

  @override
  String get registerPasswordLabel => 'كلمة المرور';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerSubmit => 'إنشاء حسابي';

  @override
  String get registerSignInLink => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get registerPasswordStrengthLabel => 'قوة كلمة المرور';

  @override
  String get registerPasswordStrengthWeak => 'ضعيفة';

  @override
  String get registerPasswordStrengthMedium => 'متوسطة';

  @override
  String get registerPasswordStrengthStrong => 'قوية';

  @override
  String get formRequiredFields => 'يرجى ملء جميع الحقول';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordReveal => 'إظهار كلمة المرور';

  @override
  String get passwordHide => 'إخفاء كلمة المرور';

  @override
  String get otpPageTitle => 'التحقق من الرمز';

  @override
  String otpCodeSentTo(String phone) {
    return 'أدخل الرمز المرسل إلى $phone';
  }

  @override
  String get otpVerifyAction => 'تحقق من الرمز';

  @override
  String get otpResendAction => 'إعادة إرسال الرمز';

  @override
  String otpResendCountdown(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String otpDemoCode(String code) {
    return 'وضع تجريبي: رمزك هو $code';
  }

  @override
  String get otpCodeResent => 'تم إنشاء رمز جديد.';

  @override
  String get otpCodeVerified => 'تم التحقق من رقم الهاتف.';

  @override
  String get legalTermsTitle => 'شروط الاستخدام';

  @override
  String get legalTermsBody =>
      'لواج غو مشروع جامعي لحجز سيارات الأجرة المشتركة. بإنشاء حساب، تؤكد صحة المعلومات المقدمة وتوافق على استخدام الخدمة وفقًا للقواعد المعمول بها.\n\nتخضع الحجوزات لتوفر الرحلات والمقاعد.';

  @override
  String get legalUpdatedAt => 'آخر تحديث: 3 أكتوبر 2026';

  @override
  String get legalTermsSectionServiceTitle => 'استخدام الخدمة';

  @override
  String get legalTermsSectionServiceBody =>
      'يساعد تطبيق لواج غو المستخدمين على تصفح رحلات سيارات الأجرة المشتركة وحجزها. يلتزم المستخدم بتقديم معلومات صحيحة وحماية بيانات تسجيل الدخول واستخدام الخدمة وفق القوانين المعمول بها.';

  @override
  String get legalTermsSectionBookingsTitle => 'الحجوزات والرحلات';

  @override
  String get legalTermsSectionBookingsBody =>
      'تعتمد الحجوزات على توفر الرحلات والمقاعد. قد تتغير الجداول والمعلومات المعروضة. تخضع الإلغاءات للشروط الموضحة في التطبيق.';

  @override
  String get legalTermsSectionDemoTitle => 'النسخة التجريبية';

  @override
  String get legalTermsSectionDemoBody =>
      'هذا التطبيق مشروع جامعي. بعض الميزات تجريبية ولا تضمن النقل أو الدفع الفعلي.';

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get legalPrivacyBody =>
      'في هذه النسخة التجريبية، تُخزّن معلومات الحساب محليًا على هذا الجهاز. لا تُرسل رسائل نصية حقيقية؛ رمز التحقق تجريبي.\n\nلا تُرسل بياناتك إلى Firebase.';

  @override
  String get legalPrivacySectionDataTitle => 'المعلومات المخزنة';

  @override
  String get legalPrivacySectionDataBody =>
      'تُخزّن معلومات الملف الشخصي والتفضيلات والمفضلة والبيانات اللازمة لدعم ميزات الحجز محليًا في التطبيق.';

  @override
  String get legalPrivacySectionUseTitle => 'كيفية استخدام المعلومات';

  @override
  String get legalPrivacySectionUseBody =>
      'تُستخدم المعلومات لعرض ملفك الشخصي وحفظ التفضيلات ودعم ميزات الحجز. لا ترسل هذه النسخة التجريبية البيانات إلى Firebase.';

  @override
  String get legalPrivacySectionControlTitle => 'خياراتك وحذف الحساب';

  @override
  String get legalPrivacySectionControlBody =>
      'يمكنك تعديل ملفك الشخصي أو طلب حذف حسابك. قد تُحفظ الحجوزات والتقييمات السابقة بعد إخفاء الهوية.';

  @override
  String get legalPrivacySectionDemoTitle => 'رسائل التحقق';

  @override
  String get legalPrivacySectionDemoBody =>
      'لا تُرسل رسائل SMS حقيقية في هذه النسخة؛ رموز التحقق تجريبية.';

  @override
  String get settingsAccountSection => 'الحساب';

  @override
  String get settingsPreferencesSection => 'تفضيلات التطبيق';

  @override
  String get settingsSecuritySection => 'الأمان';

  @override
  String get settingsSupportSection => 'المساعدة والمعلومات';

  @override
  String get profileFirstNameLabel => 'الاسم الأول';

  @override
  String get profileLastNameLabel => 'اسم العائلة';

  @override
  String get profileSignOutTitle => 'تسجيل الخروج؟';

  @override
  String get profileSignOutMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get helpSupportTitle => 'المساعدة والدعم';

  @override
  String get helpFaqSection => 'الأسئلة الشائعة';

  @override
  String get helpFaqBookingQuestion => 'كيف أجد رحلة؟';

  @override
  String get helpFaqBookingAnswer =>
      'اختر مدينة الانطلاق والوجهة من الشاشة الرئيسية، ثم ستظهر الرحلات المتاحة.';

  @override
  String get helpFaqPaymentQuestion => 'كيف أحجز مقعدًا؟';

  @override
  String get helpFaqPaymentAnswer =>
      'افتح رحلة متاحة للاطلاع على تفاصيلها وإجراءات الحجز المتوفرة.';

  @override
  String get helpFaqPhoneQuestion => 'كيف أغيّر رقم هاتفي؟';

  @override
  String get helpFaqPhoneAnswer =>
      'من ملفك الشخصي، افتح تعديل الملف الشخصي ثم اختر تغيير رقم الهاتف. يتم التحقق باستخدام رمز OTP.';

  @override
  String get helpHowItWorksTitle => 'كيف يعمل لواج غو';

  @override
  String get helpHowItWorksBody =>
      'اختر نقطة الانطلاق والوجهة، وتصفح الرحلات المتاحة، ثم افتح الرحلة لعرض تفاصيلها. يمكن للسائقين إدارة حسابهم من ملفهم الشخصي.';

  @override
  String get helpContactTitle => 'تواصل معنا';

  @override
  String get helpContactSupport => 'التواصل مع الدعم';

  @override
  String get helpEmailCopied => 'تم نسخ بريد الدعم.';

  @override
  String get helpReportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get helpReportHint => 'صف المشكلة التي واجهتها';

  @override
  String get helpCopyReport => 'نسخ البلاغ';

  @override
  String get helpReportCopied => 'تم نسخ البلاغ. يمكنك إرساله إلى الدعم.';

  @override
  String get profilePrivacy => 'الخصوصية';

  @override
  String get profileEditTitle => 'تعديل الملف الشخصي';

  @override
  String get profileCityLabel => 'المدينة';

  @override
  String get profileCityNotSet => 'لم يتم اختيار مدينة';

  @override
  String get profileChooseGallery => 'الاختيار من المعرض';

  @override
  String get profileChooseCamera => 'التقاط صورة';

  @override
  String get profileChangePhoto => 'تغيير الصورة';

  @override
  String get profilePhotoError => 'تعذر اختيار الصورة أو حفظها.';

  @override
  String get profilePhotoCleanupWarning =>
      'تم حفظ الملف الشخصي، لكن تعذّر حذف الصورة السابقة.';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي.';

  @override
  String get profileUnavailable => 'الملف الشخصي غير متاح.';

  @override
  String get profileSaveAction => 'حفظ';

  @override
  String get profilePhoneUpdated => 'تم تحديث رقم الهاتف.';

  @override
  String get profileHelpBody =>
      'الأسئلة الشائعة\n\nكيف أحجز رحلة؟ اختر مدينة الانطلاق والوجهة، ثم حدد رحلة متاحة.\n\nكيف أغيّر رقم هاتفي؟ افتح تعديل الملف الشخصي ثم اختر تغيير رقم الهاتف. سيُطلب رمز تحقق.\n\nكيف أحمي حسابي؟ حافظ على التحكم بهاتفك ومعلومات تسجيل الدخول.';

  @override
  String get deleteAccountAction => 'حذف حسابي';

  @override
  String get deleteAccountTitle => 'حذف الحساب؟';

  @override
  String get deleteAccountWarning =>
      'هذا الإجراء نهائي. سيتم حذف المفضلة والإشعارات وبيانات الملف الشخصي. ستُحفظ الحجوزات والتقييمات بعد إخفاء الهوية.';

  @override
  String get deleteAccountConfirmTitle => 'تأكيد الحذف';

  @override
  String get deleteAccountConfirmationWord => 'حذف';

  @override
  String deleteAccountTypeConfirmation(String word) {
    return 'اكتب $word للتأكيد.';
  }

  @override
  String get deleteAccountConfirmationMismatch => 'الكلمة المدخلة غير مطابقة.';

  @override
  String get deleteAccountCompleted => 'تم حذف حسابك.';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get searchPageNotFound => 'تعذر العثور على البحث';

  @override
  String get passengerNavHome => 'الرئيسية';

  @override
  String get passengerNavTrips => 'رحلاتي';

  @override
  String get passengerNavFavorites => 'المفضلة';

  @override
  String get passengerNavProfile => 'الملف الشخصي';

  @override
  String get driverNavHome => 'الرئيسية';

  @override
  String get driverNavQueue => 'الصف';

  @override
  String get driverNavScan => 'المسح';

  @override
  String get driverNavEarnings => 'الأرباح';

  @override
  String get driverNavProfile => 'الملف الشخصي';

  @override
  String get adminNavDashboard => 'لوحة التحكم';

  @override
  String get adminNavStations => 'المحطات';

  @override
  String get adminNavDrivers => 'السائقون';

  @override
  String get adminNavUsers => 'المستخدمون';

  @override
  String get adminNavReports => 'البلاغات';

  @override
  String get adminNavNotifications => 'الإشعارات';

  @override
  String get adminMenuTitle => 'الإدارة';

  @override
  String get driverQueueTitle => 'صف الانطلاق';

  @override
  String get driverScanTitle => 'مسح التذكرة';

  @override
  String get driverDocumentsTitle => 'إرسال الوثائق';

  @override
  String get driverEarningsTitle => 'الأرباح';

  @override
  String get driverProfileTitle => 'ملف السائق';

  @override
  String get driverHomeTitle => 'مساحة السائق';

  @override
  String get driverProfileUnavailable => 'ملف السائق غير متاح';

  @override
  String get sessionExpired => 'انتهت الجلسة';

  @override
  String get driverStatusPending => 'الحساب بانتظار التحقق';

  @override
  String get driverStatusApproved => 'تم التحقق من الحساب';

  @override
  String get driverStatusRejected => 'تم رفض الحساب';

  @override
  String get driverDocumentsRejectedBody =>
      'يرجى تحديث ملفك وإعادة إرسال الوثائق.';

  @override
  String get driverDocumentsPendingBody => 'أرسل وثائقك لتفعيل حساب السائق.';

  @override
  String get driverDocumentsSubmit => 'إرسال الوثائق';

  @override
  String get driverMyLouage => 'اللواج الخاص بي';

  @override
  String get driverEditProfile => 'الملف الشخصي';

  @override
  String get driverNoLouage => 'لا يوجد لواج مرتبط بحسابك';

  @override
  String get driverStationUnavailable => 'المحطة الحالية غير متاحة';

  @override
  String get driverSeatFill => 'عدد المقاعد المحجوزة';

  @override
  String get driverNoActiveTrip => 'لا توجد رحلة نشطة';

  @override
  String get driverCurrentTrip => 'الرحلة الحالية';

  @override
  String get driverFillUpdatesNextTrip =>
      'سيتم تحديث المؤشر عند توفر الرحلة التالية.';

  @override
  String get driverPassengersReserved => 'المسافرون أصحاب الحجوزات';

  @override
  String get driverNoBookings => 'لا توجد حجوزات بعد';

  @override
  String get driverBookingsAppearHere => 'ستظهر حجوزات المسافرين هنا.';

  @override
  String get driverPassengerFallback => 'مسافر';

  @override
  String driverPassengerSeats(Object count, Object name) {
    return '$name — $count مقعد';
  }

  @override
  String driverBookingSeatCount(Object count) {
    return '$count مقعد';
  }

  @override
  String get driverSeatWord => 'مقاعد';

  @override
  String get driverJoinQueue => 'الانضمام إلى الصف';

  @override
  String get driverLeaveQueue => 'مغادرة الصف';

  @override
  String get driverLogout => 'تسجيل الخروج';

  @override
  String get comingSoon => 'ستتوفر هذه الخدمة قريبًا';

  @override
  String greetingPassenger(Object name) {
    return 'مرحبًا، $name';
  }

  @override
  String get searchPrompt => 'إلى أين تريد الذهاب؟';

  @override
  String get searchChooseBothCities => 'اختر مدينة الانطلاق ومدينة الوصول';

  @override
  String get searchCitiesMustDiffer =>
      'يجب أن تختلف مدينة الانطلاق عن مدينة الوصول';

  @override
  String get searchDeparture => 'الانطلاق';

  @override
  String get searchDestination => 'الوصول';

  @override
  String get searchDate => 'التاريخ';

  @override
  String get searchTime => 'الوقت';

  @override
  String get searchSubmit => 'ابحث عن رحلة';

  @override
  String get searchSwapRoute => 'تبديل مدينتي الانطلاق والوصول';

  @override
  String get searchLastTrips => 'المسارات الأخيرة';

  @override
  String get searchFavorites => 'المفضلة';

  @override
  String get searchPopularTrips => 'مسارات شائعة';

  @override
  String get searchNoPopularTrips => 'لا توجد مسارات متاحة حاليًا';

  @override
  String get searchNearestStation => 'أقرب محطة';

  @override
  String get searchLocationPlaceholder => 'ستتوفر خدمة تحديد الموقع قريبًا.';

  @override
  String get searchChooseCity => 'اختر مدينة';

  @override
  String get searchChooseCityPrompt => 'اختر مدينة';

  @override
  String get searchCitySearch => 'ابحث عن مدينة';

  @override
  String get searchNoCityFound => 'لم يتم العثور على مدينة';

  @override
  String get searchCityPickerTitle => 'اختر مدينة';

  @override
  String searchPricePerSeat(Object amount) {
    return '$amount دينار تونسي / مقعد';
  }

  @override
  String searchRoutePair(Object from, Object to) {
    return '$from ← $to';
  }

  @override
  String searchSeatAvailability(Object available, Object total) {
    return 'المقاعد المتاحة: $available من أصل $total';
  }

  @override
  String searchSeatsFree(Object count) {
    return 'المقاعد المتاحة: $count';
  }

  @override
  String searchSeatsAvailableSemantics(Object available, Object total) {
    return 'المقاعد المتاحة: $available من أصل $total';
  }

  @override
  String get searchFilterButton => 'تصفية';

  @override
  String get searchSortLabel => 'ترتيب حسب';

  @override
  String get searchSortTime => 'الوقت';

  @override
  String get searchSortPrice => 'السعر';

  @override
  String get searchSortSeats => 'المقاعد';

  @override
  String get searchDayToday => 'اليوم';

  @override
  String get searchDayTomorrow => 'غدًا';

  @override
  String get searchRetry => 'إعادة المحاولة';

  @override
  String get searchLoadError => 'تعذر تحميل الرحلات';

  @override
  String get searchNoLouage => 'لا يوجد لواج على هذا المسار';

  @override
  String get searchAfterRequestedTime => 'بعد الوقت الذي اخترته';

  @override
  String get searchReservation => 'احجز';

  @override
  String get searchFilterTitle => 'خيارات التصفية';

  @override
  String searchMaxPrice(Object amount) {
    return 'السعر الأقصى: $amount دينار تونسي';
  }

  @override
  String searchMinimumSeats(Object count) {
    return 'الحد الأدنى للمقاعد المتاحة: $count';
  }

  @override
  String searchTimeRange(Object end, Object start) {
    return 'وقت الانطلاق: $start – $end';
  }

  @override
  String get searchApplyFilters => 'تطبيق التصفية';

  @override
  String get louageDetailTitle => 'تفاصيل اللواج';

  @override
  String get louageNotFound => 'لم يتم العثور على اللواج';

  @override
  String get louageDetailUnavailable => 'التفاصيل غير متاحة';

  @override
  String get louageDepartureUnavailable => 'موعد الانطلاق غير متاح';

  @override
  String get louageVehicle => 'المركبة';

  @override
  String get louagePricePerSeat => 'السعر لكل مقعد';

  @override
  String louageSeatsFreeOfTotal(Object available, Object total) {
    return 'المقاعد المتاحة: $available من أصل $total';
  }

  @override
  String louageDriverRating(String rating) {
    return 'تقييم السائق: $rating / 5';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileChangePhone => 'تغيير رقم الهاتف';

  @override
  String get profileNewPhoneLabel => 'رقم الهاتف الجديد';

  @override
  String get profileHelp => 'المساعدة';

  @override
  String get profileTerms => 'الشروط والأحكام';

  @override
  String get profileDriverTitle => 'ملف السائق';

  @override
  String get profilePassengerFallback => 'مسافر';

  @override
  String get profileDriverFallback => 'سائق';

  @override
  String get widgetGalleryTitle => 'معرض المكونات';

  @override
  String get widgetGalleryFields => 'حقول النموذج';

  @override
  String get widgetGalleryValidate => 'تحقق';

  @override
  String get widgetGalleryFormValid => 'البيانات صحيحة';

  @override
  String get widgetGalleryEmail => 'البريد الإلكتروني';

  @override
  String get widgetGalleryPassword => 'كلمة المرور';

  @override
  String get widgetGalleryPasswordMin => '6 أحرف على الأقل';

  @override
  String get widgetGalleryButtons => 'الأزرار';

  @override
  String get widgetGalleryPrimary => 'أساسي';

  @override
  String get widgetGallerySecondary => 'ثانوي';

  @override
  String get widgetGalleryAccent => 'إبراز';

  @override
  String get widgetGalleryLoading => 'جارٍ التحميل';

  @override
  String get widgetGalleryStatuses => 'حالات الرحلة';

  @override
  String get widgetGalleryCardsSeats => 'البطاقة والمقاعد';

  @override
  String get widgetGalleryDeparturePrice =>
      'الانطلاق 08:00 · 18 دينارًا تونسيًا';

  @override
  String get widgetGalleryLoadingSection => 'جارٍ التحميل';

  @override
  String get widgetGalleryEmpty => 'حالة فارغة';

  @override
  String get widgetGalleryNoSavedTrip => 'لا توجد رحلات محفوظة';

  @override
  String get widgetGalleryAvailableTripsAppear => 'ستظهر الرحلات المتاحة هنا.';

  @override
  String get widgetGallerySearch => 'بحث';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsThemeLabel => 'المظهر';

  @override
  String get settingsThemeSystem => 'حسب إعدادات الجهاز';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguageLabel => 'اللغة';

  @override
  String get settingsLanguageFrench => 'الفرنسية';

  @override
  String get settingsLanguageEnglish => 'الإنجليزية';

  @override
  String get settingsLanguageArabic => 'العربية';
}
