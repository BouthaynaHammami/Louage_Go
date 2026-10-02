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
  String get authAccountBlocked => 'هذا الحساب محظور';

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
  String get loginWelcome => 'مرحبًا بك في لواج غو';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginForgotPassword => 'هل نسيت كلمة المرور؟';

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
  String get registerPasswordLabel => 'كلمة المرور';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerSubmit => 'إنشاء حسابي';

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
  String get profileTitle => 'الملف الشخصي';

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
