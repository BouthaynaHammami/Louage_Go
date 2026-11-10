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
  String get bookingReviewAction => 'مراجعة الحجز';

  @override
  String get bookingReviewTitle => 'مراجعة الحجز';

  @override
  String get bookingConfirmAction => 'تأكيد الحجز';

  @override
  String get bookingConfirmed => 'تم تأكيد الحجز';

  @override
  String get bookingTicketReady => 'تذكرتك جاهزة';

  @override
  String get bookingReference => 'المرجع';

  @override
  String get bookingSeats => 'المقاعد';

  @override
  String get bookingDriver => 'السائق';

  @override
  String get bookingMatricule => 'رقم التسجيل';

  @override
  String get bookingDeparture => 'المغادرة';

  @override
  String get bookingTotal => 'المجموع';

  @override
  String get bookingPayment => 'الدفع';

  @override
  String get bookingDownloadTicket => 'حفظ / مشاركة تذكرة PDF';

  @override
  String get bookingDetails => 'تفاصيل الحجز';

  @override
  String get bookingCancel => 'إلغاء';

  @override
  String get bookingCancelTitle => 'إلغاء الحجز؟';

  @override
  String get bookingCancelMessage => 'يمكن الإلغاء حتى ساعتين قبل المغادرة.';

  @override
  String get bookingEmpty => 'لا توجد حجوزات بعد';

  @override
  String get bookingPerSeat => 'لكل مقعد';

  @override
  String bookingSummary(int count) {
    return '$count مقاعد مختارة';
  }

  @override
  String get bookingChooseSeatsTitle => 'اختر مقعدي';

  @override
  String bookingSeatLabel(int number, String status) {
    return 'المقعد $number: $status';
  }

  @override
  String get bookingSeatUnavailable =>
      'تم حجز هذا المقعد للتو. اختر مقعدًا آخر.';

  @override
  String get bookingNotEnoughSeats => 'لا توجد مقاعد شاغرة كافية.';

  @override
  String get bookingTripUnavailable => 'لم تعد هذه الرحلة متاحة.';

  @override
  String get bookingLouageUnavailable => 'لم يعد هذا اللواج متاحًا.';

  @override
  String get bookingPaymentSimulation => 'الدفع';

  @override
  String get bookingPaymentMethod => 'طريقة الدفع';

  @override
  String get bookingPayOnBoarding => 'الدفع عند الصعود';

  @override
  String get bookingCardSimulation => 'بطاقة بنكية';

  @override
  String get bookingMobileSimulation => 'محفظة الهاتف';

  @override
  String get bookingDriverSeat => 'السائق';

  @override
  String get bookingTaken => 'محجوز';

  @override
  String get bookingSelected => 'محدد';

  @override
  String get bookingFree => 'متاح';

  @override
  String get commonLoading => 'جارٍ التحميل';

  @override
  String get statusWaiting => 'بانتظار الانطلاق';

  @override
  String get statusConfirmed => 'مؤكد';

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
  String legalUpdatedAt(String date) {
    return 'تاريخ التحديث: $date';
  }

  @override
  String legalDocumentVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get legalDemoDisclaimer =>
      'نسخة تجريبية: يجب مراجعة هذا النص من قبل مختص قانوني قبل النشر.';

  @override
  String get legalTableOfContents => 'الفهرس';

  @override
  String get legalContactLabel => 'للتواصل:';

  @override
  String get legalUpdateTitle => 'تحديث الشروط';

  @override
  String get legalUpdateMessage =>
      'تم تحديث الشروط وسياسة الخصوصية. يرجى قراءتهما وقبول هذا الإصدار للمتابعة.';

  @override
  String get legalAcceptUpdate => 'قبول ومتابعة';

  @override
  String get legalSignOut => 'تسجيل الخروج';

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

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
  String get supportTitle => 'دعم لواج غو';

  @override
  String get supportFaqTitle => 'الأسئلة الشائعة';

  @override
  String get supportContactTitle => 'الاتصال بالدعم';

  @override
  String get supportRequestsTitle => 'طلباتي';

  @override
  String get supportRequestDetailTitle => 'تفاصيل الطلب';

  @override
  String get supportQuickContact => 'اتصال سريع';

  @override
  String get supportCallAction => 'اتصال';

  @override
  String get supportEmailAction => 'بريد إلكتروني';

  @override
  String get supportWhatsappAction => 'واتساب';

  @override
  String get supportContactUnavailable =>
      'لا يوجد تطبيق متاح لتنفيذ هذا الإجراء.';

  @override
  String get supportFaqSearch => 'البحث عن سؤال';

  @override
  String get supportClearSearch => 'مسح البحث';

  @override
  String get supportFaqAll => 'الكل';

  @override
  String get supportFaqEmpty => 'لا توجد نتائج. جرّب كلمات أو فئات أخرى.';

  @override
  String get supportCategoryBooking => 'الحجز';

  @override
  String get supportCategoryPayment => 'الدفع';

  @override
  String get supportCategoryTrip => 'الرحلة والمتابعة';

  @override
  String get supportCategoryAccount => 'الحساب';

  @override
  String get supportCategoryDrivers => 'السائقون';

  @override
  String get supportCategoryBug => 'مشكلة تقنية';

  @override
  String get supportCategoryOther => 'أخرى';

  @override
  String get supportCategoryLabel => 'الفئة';

  @override
  String get supportTripReference => 'مرجع الرحلة (اختياري)';

  @override
  String get supportMessageLabel => 'رسالتك';

  @override
  String get supportSendRequest => 'إرسال الطلب';

  @override
  String get supportRequestSent => 'تم إرسال طلبك.';

  @override
  String get supportTooManyOpenRequests => 'لديك بالفعل 3 طلبات دعم مفتوحة.';

  @override
  String get supportCategoryRequired => 'اختر فئة.';

  @override
  String get supportMessageInvalid => 'يجب أن تتراوح الرسالة بين 10 و1000 حرف.';

  @override
  String get supportSignInRequired => 'سجّل الدخول لإرسال طلباتك أو عرضها.';

  @override
  String get supportSubmissionFailed => 'تعذر إرسال الطلب. حاول مرة أخرى.';

  @override
  String get supportLoadFailed => 'تعذر تحميل الطلبات.';

  @override
  String get supportRetry => 'إعادة المحاولة';

  @override
  String get supportRequestsEmpty => 'ليس لديك أي طلبات دعم.';

  @override
  String get supportRequestNotFound => 'تعذر العثور على هذا الطلب.';

  @override
  String get supportAdminReply => 'رد الدعم';

  @override
  String get supportNoAdminReply => 'لا يوجد رد حتى الآن.';

  @override
  String get supportStatusOpen => 'مفتوح';

  @override
  String get supportStatusInProgress => 'قيد المعالجة';

  @override
  String get supportStatusResolved => 'تم الحل';

  @override
  String get supportEmailSubject => 'طلب دعم لواج غو';

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
  String driverHomeGreeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get driverHomeSubtitle => 'أدر اللواج ورحلاتك.';

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
  String driverSeatCounts(String reserved, String free) {
    return '$reserved مقاعد مشغولة · $free متاحة';
  }

  @override
  String driverDepartureTime(String time) {
    return 'وقت المغادرة';
  }

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
  String get stationsTitle => 'المحطات';

  @override
  String get stationsSearchLabel => 'ابحث عن محطة';

  @override
  String get stationsBrowsePrompt => 'تصفح محطات تونس';

  @override
  String get stationsLoadError => 'تعذر تحميل المحطات';

  @override
  String get stationsNoResults => 'لم يتم العثور على محطات';

  @override
  String get stationsSearchFrom => 'ابحث انطلاقا من هذه المحطة';

  @override
  String get locationUseMyPosition => 'استخدم موقعي';

  @override
  String get locationConsentTitle => 'استخدام موقعك؟';

  @override
  String get locationConsentMessage =>
      'يُستخدم موقعك فقط للعثور على أقرب المحطات ولا تتم مشاركته.';

  @override
  String get locationConsentPrivacyLink => 'قراءة سياسة الخصوصية';

  @override
  String get locationConsentAccept => 'متابعة';

  @override
  String get locationDenied => 'تم رفض الوصول إلى الموقع.';

  @override
  String get locationDeniedForever =>
      'اسمح بالوصول إلى الموقع من إعدادات التطبيق.';

  @override
  String get locationServiceDisabled => 'فعّل خدمات الموقع على جهازك.';

  @override
  String get locationError => 'تعذر الحصول على موقعك.';

  @override
  String get locationOpenSettings => 'فتح الإعدادات';

  @override
  String get locationNearestEmpty => 'لم يتم العثور على محطات ذات موقع معروف.';

  @override
  String get stationsMapTitle => 'خريطة المحطات';

  @override
  String get stationsMapUnavailable => 'الخريطة غير متاحة دون اتصال';

  @override
  String get stationsMapRecenter => 'إعادة توسيط الخريطة';

  @override
  String get stationsMapMyPosition => 'موقعي';

  @override
  String get stationsMapFavoritesSoon =>
      'ستتوفر إضافة المحطات إلى المفضلة قريبًا';

  @override
  String stationsMapRouteCount(int count) {
    return '$count مسارات تنطلق من هنا';
  }

  @override
  String get favoriteAddRoute => 'أضف هذا المسار إلى المفضلة';

  @override
  String get favoriteRemoveRoute => 'أزل هذا المسار من المفضلة';

  @override
  String get favoriteAddStation => 'أضف هذه المحطة إلى المفضلة';

  @override
  String get favoriteRemoveStation => 'أزل هذه المحطة من المفضلة';

  @override
  String get favoriteUpdateError => 'تعذر تحديث المفضلة.';

  @override
  String get favoritesTabOffers => 'العروض';

  @override
  String get favoritesRoutesTab => 'المسارات';

  @override
  String get favoritesStationsTab => 'المحطات';

  @override
  String get favoritesEmptyOffers => 'لا توجد عروض مفضلة حتى الآن.';

  @override
  String get favoritesEmptyRoutes => 'لا توجد مسارات مفضلة حتى الآن.';

  @override
  String get favoritesEmptyStations => 'لا توجد محطات مفضلة حتى الآن.';

  @override
  String get favoritesUndo => 'تراجع';

  @override
  String get favoritesRemoved => 'تم حذف العنصر من المفضلة.';

  @override
  String get favoritesOfferAdd => 'أضف هذا العرض إلى المفضلة';

  @override
  String get favoritesOfferRemove => 'أزل هذا العرض من المفضلة';

  @override
  String get favoritesNoDeparture => 'لا يوجد موعد انطلاق متاح';

  @override
  String favoritesNextDeparture(String date) {
    return 'موعد الانطلاق التالي: $date';
  }

  @override
  String get favoritesOtherSchedules => 'عرض المواعيد الأخرى';

  @override
  String get favoritesMyOffers => 'عروضي';

  @override
  String get filtersReset => 'إعادة ضبط';

  @override
  String get filtersHideFull => 'إخفاء الرحلات المكتملة';

  @override
  String filtersActiveCount(int count) {
    return '$count عوامل تصفية نشطة';
  }

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
  String get searchNoLouage => 'لا يوجد لواج متاح';

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
  String get driverLouageProfileTitle => 'ملف السائق واللواج';

  @override
  String get driverLouageProfileSubtitle => 'أدخل معلومات مركبتك.';

  @override
  String get driverVehicleModel => 'العلامة التجارية والطراز';

  @override
  String get driverMatricule => 'رقم التسجيل';

  @override
  String get driverMatriculeRequired => 'أدخل رقم تسجيل المركبة.';

  @override
  String get driverTotalSeats => 'إجمالي المقاعد';

  @override
  String get driverTotalSeatsInvalid =>
      'أدخل عددًا إجماليًا للمقاعد أكبر من صفر.';

  @override
  String get driverAvailableSeats => 'المقاعد المتاحة';

  @override
  String get driverAvailableSeatsInvalid =>
      'يجب أن يكون عدد المقاعد المتاحة بين صفر والإجمالي.';

  @override
  String get driverCurrentStation => 'المحطة الحالية';

  @override
  String get driverStationRequired => 'اختر أو أدخل المحطة الحالية.';

  @override
  String get driverRatingAverage => 'متوسط التقييم';

  @override
  String get driverCompletedTrips => 'الرحلات المنجزة';

  @override
  String get driverDashboardStatsTitle => 'الإحصائيات';

  @override
  String get driverDashboardRevenueTitle => 'الإيرادات';

  @override
  String get driverRevenueToday => 'اليوم';

  @override
  String get driverRevenueWeek => 'هذا الأسبوع';

  @override
  String get driverSaveLouage => 'حفظ بيانات اللواج';

  @override
  String get driverLouageSaved => 'تم حفظ بيانات اللواج.';

  @override
  String get driverLouageSaveFailed =>
      'تعذر حفظ بيانات اللواج. تحقق من المعلومات وحاول مرة أخرى.';

  @override
  String get driverChangeStatus => 'تغيير الحالة';

  @override
  String get driverStatusUpdated => 'تم تحديث حالة اللواج.';

  @override
  String get driverStatusUpdateFailed => 'تعذر تحديث الحالة. حاول مرة أخرى.';

  @override
  String get driverStatsUnavailable => 'الإحصائيات غير متاحة مؤقتًا.';

  @override
  String get driverStatusAvailable => 'متاح';

  @override
  String get driverStatusWaiting => 'في الانتظار';

  @override
  String get driverStatusInTransit => 'في الطريق';

  @override
  String get driverStatusOutOfService => 'خارج الخدمة';

  @override
  String get driverConfirmStatus => 'هل تؤكد تغيير الحالة؟';

  @override
  String get driverTripsTitle => 'رحلاتي';

  @override
  String get driverTripsEmpty => 'لا توجد رحلات حالياً';

  @override
  String get driverTripDetail => 'تفاصيل الرحلة';

  @override
  String get driverTripDateTime => 'التاريخ والوقت';

  @override
  String get driverTripPrice => 'السعر لكل مقعد';

  @override
  String get driverTripDuration => 'المدة';

  @override
  String get driverTripPreview => 'معاينة الرحلة';

  @override
  String driverTripSeatsAvailable(String available, String total) {
    return 'المقاعد المتاحة: $available من $total';
  }

  @override
  String get driverCreateTripTitle => 'رحلة جديدة';

  @override
  String get driverCreateTripSubtitle => 'حدد محطتك الحالية وجهتك.';

  @override
  String get driverDestination => 'الوجهة';

  @override
  String get driverDepartureDate => 'تاريخ المغادرة';

  @override
  String get driverPublishTrip => 'نشر الرحلة';

  @override
  String get driverTripPublished => 'تم نشر الرحلة وهي الآن مرئية للمسافرين.';

  @override
  String get driverTripCreationError =>
      'تعذر نشر هذه الرحلة. تحقق من المعلومات وحاول مرة أخرى.';

  @override
  String get driverTripSameStation =>
      'يجب أن تكون المحطة الحالية والوجهة مختلفتين.';

  @override
  String get driverLouageMissing => 'لا يوجد لواج مرتبط بحساب السائق هذا.';

  @override
  String get driverLouageOutOfService =>
      'اللواج خارج الخدمة ولا يمكنه نشر الرحلات.';

  @override
  String get driverDepartureInPast => 'يجب أن يكون موعد المغادرة في المستقبل.';

  @override
  String get driverDuplicateDeparture =>
      'توجد رحلة مقررة بالفعل في هذا الموعد.';

  @override
  String get driverTripMissing => 'تعذر العثور على هذه الرحلة.';

  @override
  String get driverTripNotWaiting =>
      'يمكن إلغاء الرحلات التي ما زالت قيد الانتظار فقط.';

  @override
  String get driverCreateFirstTrip => 'إنشاء رحلتي الأولى';

  @override
  String get driverTripCancel => 'إلغاء';

  @override
  String get driverTripCancelTitle => 'إلغاء هذه الرحلة؟';

  @override
  String get driverTripCancelMessage =>
      'سيؤدي هذا إلى حذف الرحلة في الانتظار من قائمة المسافرين.';

  @override
  String get driverTripCancelled => 'تم إلغاء الرحلة.';

  @override
  String get driverBookingsTitle => 'الحجوزات والركاب';

  @override
  String driverBookingPayment(String status) {
    return 'الدفع: $status';
  }

  @override
  String driverBookingStatus(String status) {
    return 'الحجز: $status';
  }

  @override
  String get driverUpdateSeats => 'تحديث المقاعد المتاحة';

  @override
  String get driverScanInstructions => 'امسح رمز التذكرة للرحلة المحددة.';

  @override
  String get driverScanSelectTrip => 'اختر الرحلة للتحقق';

  @override
  String get driverScanValid => 'تذكرة صالحة — تم تسجيل الحجز كمستخدم.';

  @override
  String get driverScanUsed => 'تم استخدام هذه التذكرة من قبل.';

  @override
  String get driverScanInvalid => 'تذكرة غير صالحة أو ملغاة أو تخص رحلة أخرى.';

  @override
  String get driverRatingTitle => 'متوسط تقييم السائق';

  @override
  String driverRatingsCount(String count) {
    return '$count تقييم';
  }

  @override
  String get driverOperationFailed => 'تعذرت العملية. حاول مرة أخرى.';

  @override
  String get driverPaymentPending => 'قيد الانتظار';

  @override
  String get driverPaymentPaid => 'مدفوع';

  @override
  String get driverPaymentCash => 'الدفع على متن المركبة';

  @override
  String get driverPaymentUnknown => 'حالة الدفع غير معروفة';

  @override
  String get driverBookingConfirmed => 'مؤكد';

  @override
  String get driverBookingValidated => 'تم التحقق';

  @override
  String get driverBookingCancelled => 'ملغى';

  @override
  String get driverBookingRejected => 'مرفوض';

  @override
  String get driverBookingUnknown => 'حالة الحجز غير معروفة';

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
  String get profileDriverReviews => 'تقييماتي';

  @override
  String get profilePassengerFallback => 'مسافر';

  @override
  String get profileDriverFallback => 'سائق';

  @override
  String get reviewsTitle => 'تقييمات السائق';

  @override
  String get reviewsSeeAll => 'عرض كل التقييمات';

  @override
  String reviewsCount(int count) {
    return '$count تقييم';
  }

  @override
  String get reviewsLatest => 'أحدث التقييمات';

  @override
  String get reviewsNoReviews => 'لا توجد تقييمات بعد';

  @override
  String get reviewsAnonymous => 'مستخدم محذوف';

  @override
  String get reviewsWriteTitle => 'قيّم هذه الرحلة';

  @override
  String get reviewsEditTitle => 'تعديل تقييمي';

  @override
  String get reviewsRatingPrompt => 'اختر تقييماً';

  @override
  String get reviewsRating1 => 'مخيّب جداً';

  @override
  String get reviewsRating2 => 'مخيّب';

  @override
  String get reviewsRating3 => 'مقبول';

  @override
  String get reviewsRating4 => 'جيد جداً';

  @override
  String get reviewsRating5 => 'ممتاز';

  @override
  String reviewsStarSemantics(int count) {
    return '$count من 5 نجوم';
  }

  @override
  String get reviewsComment => 'تعليق (اختياري)';

  @override
  String get reviewsCommentHint => 'شاركنا تجربتك';

  @override
  String get reviewsSubmit => 'إرسال تقييمي';

  @override
  String get reviewsUpdate => 'حفظ التعديلات';

  @override
  String get reviewsDelete => 'حذف تقييمي';

  @override
  String get reviewsDeleteConfirm => 'هل تريد حذف هذا التقييم؟';

  @override
  String get reviewsSaved => 'تم إرسال تقييمك.';

  @override
  String get reviewsUpdated => 'تم تعديل تقييمك.';

  @override
  String get reviewsDeleted => 'تم حذف تقييمك.';

  @override
  String get reviewsNotEligible =>
      'يمكنك تقييم الرحلات المكتملة التي حجزتها فقط.';

  @override
  String get reviewsAlreadyReviewed => 'لقد قيّمت هذه الرحلة بالفعل.';

  @override
  String get reviewsInvalidRating => 'اختر تقييماً من نجمة إلى خمس نجوم.';

  @override
  String get reviewsInvalidComment => 'يجب ألا يتجاوز التعليق 300 حرف.';

  @override
  String get reviewsNotFound => 'تعذر العثور على هذا التقييم.';

  @override
  String get reviewsWindowExpired => 'يمكن تعديل التقييم خلال 24 ساعة من نشره.';

  @override
  String get reviewsSignInRequired => 'سجّل الدخول للمتابعة.';

  @override
  String get reviewsLoadError => 'تعذر تحميل التقييمات.';

  @override
  String get reviewsReport => 'الإبلاغ عن هذا التقييم';

  @override
  String get reviewsReportTitle => 'الإبلاغ عن هذا التقييم؟';

  @override
  String get reviewsReportBody => 'سيتم إرسال البلاغ إلى فريق الإشراف.';

  @override
  String get reviewsReportSent => 'تم الإبلاغ عن التقييم.';

  @override
  String get reviewsDistribution => 'توزيع التقييمات';

  @override
  String get reviewsNoComment => 'لا يوجد تعليق';

  @override
  String get reviewsUnavailable => 'معلومات الرحلة غير متاحة.';

  @override
  String get reviewsAnonymousAuthor => 'مسافر';

  @override
  String get reviewsDeleteAction => 'حذف';

  @override
  String get reviewsCancelAction => 'إلغاء';

  @override
  String get reviewsLoadMore => 'عرض المزيد';

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

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsNotificationsDescription =>
      'تلقي التحديثات المهمة حول رحلاتك';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsChannelName => 'إشعارات لواج غو';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyBody => 'ستظهر تحديثاتك المهمة هنا.';

  @override
  String get notificationsLoadError => 'تعذر تحميل الإشعارات.';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get notificationsYesterday => 'أمس';

  @override
  String get notificationsOlder => 'أقدم';

  @override
  String get notificationsDeleted => 'تم حذف الإشعار';

  @override
  String get notificationsUnread => 'غير مقروء';

  @override
  String get notificationsTypeBooking => 'الحجز';

  @override
  String get notificationsTypeTrip => 'الرحلة';

  @override
  String get notificationsTypePromotion => 'عرض';

  @override
  String get notificationsTypeSystem => 'معلومة';

  @override
  String get notificationsPermissionTitle => 'تفعيل الإشعارات';

  @override
  String get notificationsPermissionExplanation =>
      'يمكن لتطبيق لواج غو إرسال تحديثات مهمة حول حجوزاتك ورحلاتك. يمكنك تغيير هذا الإذن من إعدادات جهازك.';

  @override
  String get notificationsPermissionContinue => 'متابعة';

  @override
  String get notificationsPermissionDenied =>
      'الإشعارات معطلة في إعدادات الجهاز.';

  @override
  String get notificationsOpenSettings => 'فتح الإعدادات';

  @override
  String get searchHideFull => 'إخفاء الرحلات المكتملة';

  @override
  String get searchUseMaximumPrice => 'تحديد السعر الأقصى';

  @override
  String get searchResetFilters => 'إعادة الضبط';

  @override
  String get docStepAccountCreated => 'تم إنشاء الحساب';

  @override
  String get docStepDocumentsSent => 'تم إرسال الوثائق';

  @override
  String get docStepValidated => 'تم التحقق';

  @override
  String get docStepCurrent => 'الحالي';

  @override
  String get docSectionTitle => 'الوثائق المطلوبة';

  @override
  String get docStatusToSend => 'للإرسال';

  @override
  String get docStatusSent => 'مُرسَل';

  @override
  String get docStatusRejected => 'مرفوض';

  @override
  String get docStatusValidated => 'تم التحقق';

  @override
  String get docTypeNationalId => 'بطاقة الهوية الوطنية';

  @override
  String get docTypeDriverLicense => 'رخصة القيادة';

  @override
  String get docTypeVehicleCard => 'بطاقة ترقيم المركبة';

  @override
  String get docTypeInsurance => 'وثيقة التأمين';

  @override
  String get docTypeTransportLicense => 'رخصة النقل';

  @override
  String get docTypeDriverPhoto => 'صورة السائق';

  @override
  String get docTypeVehiclePhoto => 'صورة اللواج';

  @override
  String get docUploadTitle => 'رفع وثيقة';

  @override
  String get docUploadFromCamera => 'التقاط صورة';

  @override
  String get docUploadFromGallery => 'اختر من المعرض';

  @override
  String get docUploadPreviewTitle => 'معاينة قبل الإرسال';

  @override
  String get docUploadConfirm => 'تأكيد الإرسال';

  @override
  String get docUploadCancel => 'إلغاء';

  @override
  String get docUploadSuccess => 'تم إرسال الوثيقة.';

  @override
  String get docUploadError => 'تعذّر إرسال الوثيقة.';

  @override
  String get docResend => 'إعادة الإرسال';

  @override
  String get docRejectionReason => 'سبب الرفض';

  @override
  String get docSubmitAll => 'إرسال الوثائق';

  @override
  String get docSubmitConfirmTitle => 'إرسال جميع الوثائق؟';

  @override
  String get docSubmitConfirmBody =>
      'ستُرسَل وثائقك للمراجعة. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get docSubmitSuccess => 'تم إرسال الوثائق بنجاح.';

  @override
  String get docLockedPreviewTitle => 'مساحة السائق';

  @override
  String get docLockedPreviewBody =>
      'ستكون هذه الميزات متاحة بعد التحقق من حسابك.';

  @override
  String get docHelpTitle => 'هل تحتاج مساعدة؟';

  @override
  String get docHelpFaq => 'الأسئلة الشائعة';

  @override
  String get docHelpContact => 'تواصل مع الدعم';

  @override
  String get docDebugTitle => 'محاكاة المشرف (تجريبي)';

  @override
  String get docDebugApprove => 'الموافقة على جميع الوثائق';

  @override
  String get docDebugReject => 'رفض وثيقة';

  @override
  String get docDebugRejectReason => 'السبب (مثال: صورة غير واضحة)';

  @override
  String get docDebugNotifApproved => 'تم التحقق من الحساب';

  @override
  String get docDebugNotifApprovedBody =>
      'تهانينا! تم التحقق من حساب السائق الخاص بك.';

  @override
  String get docDebugNotifRejected => 'تم رفض وثيقة';

  @override
  String get docDebugNotifRejectedBody =>
      'تم رفض إحدى وثائقك. تحقق من السبب وأعد الإرسال.';

  @override
  String get docValidationStatusPending => 'الحساب قيد الانتظار';

  @override
  String get docValidationStatusSubmitted =>
      'تم إرسال الوثائق — في انتظار التحقق';

  @override
  String get docValidationStatusApproved => 'تم التحقق من الحساب';

  @override
  String get docValidationStatusRejected => 'تم رفض الحساب';

  @override
  String get driverDelayTitle => 'الإعلان عن تأخير';

  @override
  String get driverDelayNewTime => 'وقت المغادرة الجديد';

  @override
  String get driverDelayReason => 'السبب (اختياري)';

  @override
  String get driverDelayConfirm => 'الإعلان عن التأخير';

  @override
  String get driverDelaySuccess => 'تم إخطار الركاب بالتأخير.';

  @override
  String get driverReportTitle => 'الإبلاغ عن مشكلة';

  @override
  String get driverReportBreakdown => 'عطل';

  @override
  String get driverReportDelay => 'تأخير';

  @override
  String get driverReportOther => 'أخرى';

  @override
  String get driverReportSend => 'إرسال البلاغ';

  @override
  String get driverReportSuccess => 'تم إرسال البلاغ إلى الركاب.';

  @override
  String get driverNavigateTitle => 'الاتجاه إلى المحطة';

  @override
  String get driverNavigateOpen => 'فتح في الخرائط';

  @override
  String get driverNavigateNoCoords => 'إحداثيات المحطة غير متوفرة.';

  @override
  String get routeToStationTitle => 'المسافة إلى محطة الانطلاق';

  @override
  String routeDistanceFromStation(String distance) {
    return 'تبعد $distance عن محطة الانطلاق';
  }

  @override
  String routeDurationByCar(String duration) {
    return '≈ $duration بالسيارة';
  }

  @override
  String routeDistanceMeters(String meters) {
    return '$meters م';
  }

  @override
  String routeDistanceKilometers(String kilometers) {
    return '$kilometers كم';
  }

  @override
  String routeDurationMinutes(String minutes) {
    return '$minutes دقيقة';
  }

  @override
  String routeDurationHours(String hours, String minutes) {
    return '$hours س $minutes';
  }

  @override
  String get routeArrivedAtStation => 'لقد وصلت إلى المحطة';

  @override
  String get routeErrorNetwork => 'تعذر الاتصال بخدمة تحديد المسار.';

  @override
  String get routeErrorTimeout => 'استغرق حساب المسار وقتًا طويلاً.';

  @override
  String get routeErrorNoRoute => 'لم يتم العثور على مسار بالسيارة.';

  @override
  String get routeErrorInvalidResponse =>
      'أعادت خدمة تحديد المسار استجابة غير صالحة.';

  @override
  String get routeRetry => 'إعادة المحاولة';

  @override
  String get routeRefresh => 'تحديث';
}
