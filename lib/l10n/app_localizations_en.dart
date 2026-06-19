// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sayartii';

  @override
  String get home => 'Home';

  @override
  String get applicationCenter => 'Application Center';

  @override
  String get myInfo => 'My Info';

  @override
  String get applicationCenterTitle => 'Application Center';

  @override
  String get myTools => 'My Tools :';

  @override
  String get predictedIssues => 'Predicted issues';

  @override
  String get liveData => 'Live data';

  @override
  String get troubleScan => 'Trouble scan';

  @override
  String get inDepthCheck => 'In-depth check';

  @override
  String get troubleScanningTitle => 'Trouble Scanning';

  @override
  String get scanDtcCodes => 'Scan DTC codes';

  @override
  String get clearDtcCodes => 'Clear dtc Codes';

  @override
  String dtcDetected(int count) {
    return '$count Dtc detected';
  }

  @override
  String get noDtcDetected => '0 detected';

  @override
  String get activatePairedDevice => 'Activate Paired Device';

  @override
  String get drivingData => 'Driving data';

  @override
  String get currentSpeed => 'Current speed';

  @override
  String get realTimeSpeed => 'Real-time speed according to OBD data';

  @override
  String get engineRpm => 'Engine RPM';

  @override
  String get realTimeRpm => 'Real-time engine RPM according to OBD data';

  @override
  String get notAvailable => 'N/A';

  @override
  String get carName => 'Car Name';

  @override
  String get startPrediction => 'Start prediction';

  @override
  String get aboutUs => 'About us';

  @override
  String get logOut => 'Log Out';

  @override
  String get areYouSureLogOut => 'Are you sure you want to log out?';

  @override
  String get continueBtn => 'Continue';

  @override
  String get backBtn => 'Back';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get obdLiveData => 'OBD Live Data';

  @override
  String get predictedCodesTitle => 'Predicted Codes';

  @override
  String get noIssuesDetected => 'No issues detected';

  @override
  String get connectToDevice => 'Connect to device';

  @override
  String get currentSpeedLabel => 'Current speed';

  @override
  String get engineRpmLabel => 'Engine RPM';

  @override
  String get engineCoolantLabel => 'Engine coolant temp';

  @override
  String get fuelTrimLabel => 'Short term fuel bank1';

  @override
  String get engineLoadLabel => 'Engine load';

  @override
  String get throttleLabel => 'Throttle position';

  @override
  String get airIntakeLabel => 'Air intake temp';

  @override
  String get timingAdvanceLabel => 'Timing advance';

  @override
  String get inDepthCheckTitle => 'In-Depth Check';

  @override
  String get inDepthCheckSoon => 'This feature is coming soon!';

  @override
  String get aboutUsTitle => 'About Sayartii';

  @override
  String get aboutUsDesc =>
      'Sayartii is an AI-powered car diagnostic app that connects to your vehicle via OBD-II and helps you detect and predict issues before they become serious problems.';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get userName => 'User';

  @override
  String get premiumMembership => 'Premium Membership';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get liveDataStream => 'Live Data Stream';

  @override
  String get aboutSayartii => 'About Sayartii';

  @override
  String get connectivity => 'Connectivity';

  @override
  String get bluetoothOffPrompt =>
      'Bluetooth is off. Would you like to enable it to connect to your car?';

  @override
  String get yes => 'Yes';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get searchBluetooth => 'Search Bluetooth Devices';

  @override
  String get connecting => 'Connecting...';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get mileage => 'MILEAGE';

  @override
  String get totalDistance => 'Total Distance';

  @override
  String get avgFuel => 'AVG FUEL';

  @override
  String get estimatedConsumption => 'Estimated Consumption';

  @override
  String get loginTab => 'Login';

  @override
  String get signUpTab => 'Sign Up';

  @override
  String get welcomeBack => 'Welcome back! Sign in to continue';

  @override
  String get createAccountSub => 'Create your account to get started';

  @override
  String get fullName => 'Full Name';

  @override
  String get vehicleModel => 'Vehicle Model';

  @override
  String get modelYear => 'Model Year';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginBtn => 'Login';

  @override
  String get createAccountBtn => 'Create Account';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get alreadyAccount => 'Already have an account? ';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get minSixChars => 'Min 6 characters';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get accountCreated => 'Account created! Please log in.';
}
