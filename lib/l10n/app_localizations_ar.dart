// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سيارتي';

  @override
  String get home => 'الرئيسية';

  @override
  String get applicationCenter => 'أدوات الفحص';

  @override
  String get myInfo => 'حسابي';

  @override
  String get applicationCenterTitle => 'أدوات التشخيص';

  @override
  String get myTools => 'أدواتي :';

  @override
  String get predictedIssues => 'التنبؤ بالأعطال';

  @override
  String get liveData => 'قراءة الحساسات';

  @override
  String get troubleScan => 'فحص الأعطال';

  @override
  String get inDepthCheck => 'فحص شامل';

  @override
  String get troubleScanningTitle => 'فحص الأعطال السريع';

  @override
  String get scanDtcCodes => 'ابدأ الفحص';

  @override
  String get clearDtcCodes => 'مسح الأعطال';

  @override
  String dtcDetected(int count) {
    return 'تم رصد $count أعطال';
  }

  @override
  String get noDtcDetected => 'لا توجد أعطال مسجلة';

  @override
  String get activatePairedDevice => 'الاتصال بوحدة الـ OBD';

  @override
  String get drivingData => 'بيانات القيادة';

  @override
  String get currentSpeed => 'السرعة الحالية';

  @override
  String get realTimeSpeed => 'السرعة الفعلية من حاسوب السيارة';

  @override
  String get engineRpm => 'عدد لفات المحرك (RPM)';

  @override
  String get realTimeRpm => 'قراءة الـ RPM المباشرة من المحرك';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get carName => 'طراز المركبة';

  @override
  String get startPrediction => 'تفعيل التنبؤ الذكي';

  @override
  String get aboutUs => 'عن التطبيق';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get areYouSureLogOut => 'هل تود تأكيد تسجيل الخروج؟';

  @override
  String get continueBtn => 'استمرار';

  @override
  String get backBtn => 'رجوع';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get obdLiveData => 'البيانات الحية للحساسات';

  @override
  String get predictedCodesTitle => 'الأعطال المتوقعة';

  @override
  String get noIssuesDetected => 'لم يتم رصد أي أعطال';

  @override
  String get connectToDevice => 'الرجاء الاتصال بقطعة الـ OBD';

  @override
  String get currentSpeedLabel => 'السرعة الحالية';

  @override
  String get engineRpmLabel => 'لفة/دقيقة (RPM)';

  @override
  String get engineCoolantLabel => 'حرارة سائل التبريد';

  @override
  String get fuelTrimLabel => 'موازنة الوقود (Fuel Trim)';

  @override
  String get engineLoadLabel => 'حِمل المحرك (Load)';

  @override
  String get throttleLabel => 'دعسة البنزين (Throttle)';

  @override
  String get airIntakeLabel => 'حرارة هواء السحب (Intake)';

  @override
  String get timingAdvanceLabel => 'توقيت الإشعال (Timing)';

  @override
  String get inDepthCheckTitle => 'الفحص الشامل';

  @override
  String get inDepthCheckSoon => 'قريباً في التحديثات القادمة!';

  @override
  String get aboutUsTitle => 'عن سيارتي';

  @override
  String get aboutUsDesc =>
      'سيارتي هو تطبيق تشخيص سيارات احترافي مدعوم بالذكاء الاصطناعي، يتصل بسيارتك عبر منفذ OBD-II ويساعدك على اكتشاف الأعطال والتنبؤ بها بدقة قبل تفاقمها.';

  @override
  String get vehicleLabel => 'المركبة';

  @override
  String get userName => 'المستخدم';

  @override
  String get premiumMembership => 'النسخة الاحترافية (Pro)';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get liveDataStream => 'مراقبة الحساسات المباشرة';

  @override
  String get aboutSayartii => 'عن سيارتي';

  @override
  String get connectivity => 'الاتصال';

  @override
  String get bluetoothOffPrompt =>
      'البلوتوث غير مفعل. الرجاء تشغيله للتمكن من الاتصال بقطعة الـ OBD.';

  @override
  String get yes => 'تفعيل';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get searchBluetooth => 'البحث عن أجهزة OBD';

  @override
  String get connecting => 'جارٍ الاتصال...';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get mileage => 'المسافة المقطوعة';

  @override
  String get totalDistance => 'إجمالي المسافة';

  @override
  String get avgFuel => 'متوسط استهلاك الوقود';

  @override
  String get estimatedConsumption => 'الاستهلاك التقديري';

  @override
  String get loginTab => 'تسجيل الدخول';

  @override
  String get signUpTab => 'حساب جديد';

  @override
  String get welcomeBack => 'مرحباً بك! قم بتسجيل الدخول للمتابعة';

  @override
  String get createAccountSub => 'قم بإنشاء حسابك الجديد للبدء';

  @override
  String get fullName => 'الاسم بالكامل';

  @override
  String get vehicleModel => 'نوع وموديل السيارة';

  @override
  String get modelYear => 'سنة الصنع';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginBtn => 'دخول';

  @override
  String get createAccountBtn => 'إنشاء حساب';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get alreadyAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get nameRequired => 'يجب إدخال الاسم';

  @override
  String get enterValidEmail => 'أدخل بريد إلكتروني صحيح';

  @override
  String get minSixChars => 'يجب ألا تقل عن 6 أحرف';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. يرجى التأكد من صحة البيانات.';

  @override
  String get registrationFailed => 'فشل إنشاء الحساب. يرجى المحاولة لاحقاً.';

  @override
  String get accountCreated =>
      'تم إنشاء الحساب بنجاح! يمكنك تسجيل الدخول الآن.';

  @override
  String get nearbyMechanics => 'الورش القريبة';

  @override
  String locationsNearby(int count) {
    return '$count أماكن قريبة';
  }

  @override
  String get yourLocation => 'موقعك';

  @override
  String get mechanic => 'ورشة';

  @override
  String get partsStore => 'قطع غيار';

  @override
  String get viewOnMap => 'عرض على الخريطة';

  @override
  String get gettingLocation => 'جاري تحديد موقعك...';

  @override
  String get locationError => 'تعذر تحديد الموقع. تأكد من تفعيل الـ GPS.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String mAway(int distance) {
    return '$distance متر';
  }

  @override
  String kmAway(String distance) {
    return '$distance كم';
  }

  @override
  String get verifiedLocation => 'موقع موثق';

  @override
  String get demoLocation => 'موقع تجريبي';

  @override
  String get searchThisArea => 'البحث في هذه المنطقة';

  @override
  String get checkMoreSensors => 'تحقق من المزيد من الحساسات';

  @override
  String get readingLiveData => 'جاري قراءة الحساسات مباشرة...';

  @override
  String get swipeForSensorData => 'اسحب لعرض بيانات الحساسات';
}
