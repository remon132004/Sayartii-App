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
  String get applicationCenter => 'مركز التطبيقات';

  @override
  String get myInfo => 'حسابي';

  @override
  String get applicationCenterTitle => 'مركز التطبيقات';

  @override
  String get myTools => 'أدواتي :';

  @override
  String get predictedIssues => 'التنبؤ بالأعطال';

  @override
  String get liveData => 'البيانات الحية';

  @override
  String get troubleScan => 'فحص الأعطال';

  @override
  String get inDepthCheck => 'فحص دقيق';

  @override
  String get troubleScanningTitle => 'فحص الأعطال السريع';

  @override
  String get scanDtcCodes => 'ابدأ الفحص';

  @override
  String get clearDtcCodes => 'مسح الأعطال';

  @override
  String dtcDetected(int count) {
    return 'تم اكتشاف $count عطل';
  }

  @override
  String get noDtcDetected => 'لا يوجد أعطال';

  @override
  String get activatePairedDevice => 'بدء الاتصال بالسيارة';

  @override
  String get drivingData => 'بيانات القيادة';

  @override
  String get currentSpeed => 'السرعة الحالية';

  @override
  String get realTimeSpeed => 'السرعة الفورية بناءً على الـ OBD';

  @override
  String get engineRpm => 'دوران المحرك';

  @override
  String get realTimeRpm => 'دوران المحرك الآني بناءً على الـ OBD';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get carName => 'اسم السيارة';

  @override
  String get startPrediction => 'تفعيل التنبؤ الذكي';

  @override
  String get aboutUs => 'عن التطبيق';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get areYouSureLogOut => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get continueBtn => 'استمرار';

  @override
  String get backBtn => 'رجوع';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get obdLiveData => 'البيانات الحية OBD';

  @override
  String get predictedCodesTitle => 'الأعطال المتوقعة';

  @override
  String get noIssuesDetected => 'لا توجد أعطال مكتشفة';

  @override
  String get connectToDevice => 'قم بتوصيل الجهاز';

  @override
  String get currentSpeedLabel => 'السرعة الحالية';

  @override
  String get engineRpmLabel => 'دوران المحرك';

  @override
  String get engineCoolantLabel => 'حرارة المياه';

  @override
  String get fuelTrimLabel => 'نسبة الوقود القصيرة';

  @override
  String get engineLoadLabel => 'حمل المحرك';

  @override
  String get throttleLabel => 'موضع الخانق';

  @override
  String get airIntakeLabel => 'حرارة هواء المحرك';

  @override
  String get timingAdvanceLabel => 'تقدم التوقيت';

  @override
  String get inDepthCheckTitle => 'الفحص الشامل';

  @override
  String get inDepthCheckSoon => 'هذه الميزة قادمة قريباً!';

  @override
  String get aboutUsTitle => 'عن سيارتي';

  @override
  String get aboutUsDesc =>
      'سيارتي هو تطبيق تشخيص سيارات مدعوم بالذكاء الاصطناعي، يتصل بسيارتك عبر OBD-II ويساعدك على اكتشاف الأعطال والتنبؤ بها قبل أن تتفاقم.';

  @override
  String get vehicleLabel => 'المركبة';

  @override
  String get userName => 'المستخدم';

  @override
  String get premiumMembership => 'عضوية مميزة';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get liveDataStream => 'بث البيانات المباشر';

  @override
  String get aboutSayartii => 'عن سيارتي';

  @override
  String get connectivity => 'الاتصال';

  @override
  String get bluetoothOffPrompt =>
      'البلوتوث مغلق. هل تريد تشغيله للاتصال بسيارتك؟';

  @override
  String get yes => 'نعم';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get searchBluetooth => 'البحث عن الأجهزة';

  @override
  String get connecting => 'جارٍ الاتصال...';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get mileage => 'المسافة';

  @override
  String get totalDistance => 'إجمالي المسافة';

  @override
  String get avgFuel => 'متوسط الوقود';

  @override
  String get estimatedConsumption => 'استهلاك تقديري';

  @override
  String get loginTab => 'تسجيل الدخول';

  @override
  String get signUpTab => 'إنشاء حساب';

  @override
  String get welcomeBack => 'مرحباً بعودتك! سجّل دخولك للمتابعة';

  @override
  String get createAccountSub => 'أنشئ حسابك للبدء';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get vehicleModel => 'موديل السيارة';

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
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get enterValidEmail => 'أدخل بريد إلكتروني صحيح';

  @override
  String get minSixChars => '6 أحرف على الأقل';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. تحقق من بيانات الحساب.';

  @override
  String get registrationFailed => 'فشل إنشاء الحساب. حاول مجدداً.';

  @override
  String get accountCreated => 'تم إنشاء الحساب! سجّل دخولك الآن.';
}
