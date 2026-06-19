import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sayartii'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @applicationCenter.
  ///
  /// In en, this message translates to:
  /// **'Application Center'**
  String get applicationCenter;

  /// No description provided for @myInfo.
  ///
  /// In en, this message translates to:
  /// **'My Info'**
  String get myInfo;

  /// No description provided for @applicationCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Center'**
  String get applicationCenterTitle;

  /// No description provided for @myTools.
  ///
  /// In en, this message translates to:
  /// **'My Tools :'**
  String get myTools;

  /// No description provided for @predictedIssues.
  ///
  /// In en, this message translates to:
  /// **'Predicted issues'**
  String get predictedIssues;

  /// No description provided for @liveData.
  ///
  /// In en, this message translates to:
  /// **'Live data'**
  String get liveData;

  /// No description provided for @troubleScan.
  ///
  /// In en, this message translates to:
  /// **'Trouble scan'**
  String get troubleScan;

  /// No description provided for @inDepthCheck.
  ///
  /// In en, this message translates to:
  /// **'In-depth check'**
  String get inDepthCheck;

  /// No description provided for @troubleScanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Trouble Scanning'**
  String get troubleScanningTitle;

  /// No description provided for @scanDtcCodes.
  ///
  /// In en, this message translates to:
  /// **'Scan DTC codes'**
  String get scanDtcCodes;

  /// No description provided for @clearDtcCodes.
  ///
  /// In en, this message translates to:
  /// **'Clear dtc Codes'**
  String get clearDtcCodes;

  /// No description provided for @dtcDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} Dtc detected'**
  String dtcDetected(int count);

  /// No description provided for @noDtcDetected.
  ///
  /// In en, this message translates to:
  /// **'0 detected'**
  String get noDtcDetected;

  /// No description provided for @activatePairedDevice.
  ///
  /// In en, this message translates to:
  /// **'Activate Paired Device'**
  String get activatePairedDevice;

  /// No description provided for @drivingData.
  ///
  /// In en, this message translates to:
  /// **'Driving data'**
  String get drivingData;

  /// No description provided for @currentSpeed.
  ///
  /// In en, this message translates to:
  /// **'Current speed'**
  String get currentSpeed;

  /// No description provided for @realTimeSpeed.
  ///
  /// In en, this message translates to:
  /// **'Real-time speed according to OBD data'**
  String get realTimeSpeed;

  /// No description provided for @engineRpm.
  ///
  /// In en, this message translates to:
  /// **'Engine RPM'**
  String get engineRpm;

  /// No description provided for @realTimeRpm.
  ///
  /// In en, this message translates to:
  /// **'Real-time engine RPM according to OBD data'**
  String get realTimeRpm;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @carName.
  ///
  /// In en, this message translates to:
  /// **'Car Name'**
  String get carName;

  /// No description provided for @startPrediction.
  ///
  /// In en, this message translates to:
  /// **'Start prediction'**
  String get startPrediction;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @areYouSureLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureLogOut;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backBtn;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @obdLiveData.
  ///
  /// In en, this message translates to:
  /// **'OBD Live Data'**
  String get obdLiveData;

  /// No description provided for @predictedCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Predicted Codes'**
  String get predictedCodesTitle;

  /// No description provided for @noIssuesDetected.
  ///
  /// In en, this message translates to:
  /// **'No issues detected'**
  String get noIssuesDetected;

  /// No description provided for @connectToDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect to device'**
  String get connectToDevice;

  /// No description provided for @currentSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Current speed'**
  String get currentSpeedLabel;

  /// No description provided for @engineRpmLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine RPM'**
  String get engineRpmLabel;

  /// No description provided for @engineCoolantLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine coolant temp'**
  String get engineCoolantLabel;

  /// No description provided for @fuelTrimLabel.
  ///
  /// In en, this message translates to:
  /// **'Short term fuel bank1'**
  String get fuelTrimLabel;

  /// No description provided for @engineLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine load'**
  String get engineLoadLabel;

  /// No description provided for @throttleLabel.
  ///
  /// In en, this message translates to:
  /// **'Throttle position'**
  String get throttleLabel;

  /// No description provided for @airIntakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Air intake temp'**
  String get airIntakeLabel;

  /// No description provided for @timingAdvanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Timing advance'**
  String get timingAdvanceLabel;

  /// No description provided for @inDepthCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'In-Depth Check'**
  String get inDepthCheckTitle;

  /// No description provided for @inDepthCheckSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get inDepthCheckSoon;

  /// No description provided for @aboutUsTitle.
  ///
  /// In en, this message translates to:
  /// **'About Sayartii'**
  String get aboutUsTitle;

  /// No description provided for @aboutUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sayartii is an AI-powered car diagnostic app that connects to your vehicle via OBD-II and helps you detect and predict issues before they become serious problems.'**
  String get aboutUsDesc;

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleLabel;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userName;

  /// No description provided for @premiumMembership.
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get premiumMembership;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @liveDataStream.
  ///
  /// In en, this message translates to:
  /// **'Live Data Stream'**
  String get liveDataStream;

  /// No description provided for @aboutSayartii.
  ///
  /// In en, this message translates to:
  /// **'About Sayartii'**
  String get aboutSayartii;

  /// No description provided for @connectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivity;

  /// No description provided for @bluetoothOffPrompt.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off. Would you like to enable it to connect to your car?'**
  String get bluetoothOffPrompt;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @searchBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Search Bluetooth Devices'**
  String get searchBluetooth;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'MILEAGE'**
  String get mileage;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @avgFuel.
  ///
  /// In en, this message translates to:
  /// **'AVG FUEL'**
  String get avgFuel;

  /// No description provided for @estimatedConsumption.
  ///
  /// In en, this message translates to:
  /// **'Estimated Consumption'**
  String get estimatedConsumption;

  /// No description provided for @loginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTab;

  /// No description provided for @signUpTab.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTab;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue'**
  String get welcomeBack;

  /// No description provided for @createAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountSub;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @modelYear.
  ///
  /// In en, this message translates to:
  /// **'Model Year'**
  String get modelYear;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountBtn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @minSixChars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get minSixChars;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please log in.'**
  String get accountCreated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
