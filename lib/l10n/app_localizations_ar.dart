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
  String get aboutUsDesc => 'سيارتي هو تطبيق تشخيص سيارات مدعوم بالذكاء الاصطناعي، يتصل بسيارتك عبر OBD-II ويساعدك على اكتشاف الأعطال والتنبؤ بها قبل أن تتفاقم.';
  @override
  String get vehicleLabel => 'المركبة';
  @override
  String get userName => 'المستخدم';
}
