import 'package:sayartii/views/predicted_codes/cubit/predict_codes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:sayartii/views/connect_device/cubit/bluetooth_cubit.dart';
import 'package:sayartii/views/connect_device/cubit/connect_device_cubit.dart';
import 'package:sayartii/views/notification/local_notification.dart';
import 'package:sayartii/views/splash_screen.dart';
import 'package:sayartii/views/trouble_scan/cubit/trouble_scan_cubit.dart';
import 'package:sizer/sizer.dart';
import 'constants.dart';
import 'simple_bloc_observer.dart';
import 'package:sayartii/views/home/cubit/data_cubit.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/cubit/language_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();

  //ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  //SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  //HttpOverrides.global = MyHttpOverrides() as HttpOverrides? ;

  // initializeNotifications();
  Bloc.observer = SimpleBlocObserver();

  runApp(Phoenix(child: MyApp(navigatorKey: navigatorKey)));
}

class MyApp extends StatelessWidget {
    final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key,required this.navigatorKey});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  
    //getlogged();
    return Sizer(builder: (context, orientation, deviceType) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: ((context) => ConnectDeviceCubit())),
          BlocProvider(create: ((context) => DataCubit())),
          BlocProvider(create: ((context) => BluetoothCubit())),
          BlocProvider(create: ((context) => TroubleScanCubit())),
          BlocProvider(create: ((context) => PredictCodesCubit())),
          BlocProvider(create: ((context) => LanguageCubit())),
        ],
        child: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Sayartii',
            theme: ThemeData(
              primaryColor: const Color(0xFF235DFF),
              scaffoldBackgroundColor: kPrimaryBackGroundColor,
              textSelectionTheme:
                  const TextSelectionThemeData(cursorColor: Colors.white),
              fontFamily: 'SourceSansPro',
              textTheme: const TextTheme(
                displaySmall: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 45.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                labelLarge: TextStyle(
                  // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
                  fontFamily: 'OpenSans',
                ),
                bodySmall: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF235DFF),
                ),
                displayLarge: TextStyle(fontFamily: 'Quicksand'),
                displayMedium: TextStyle(fontFamily: 'Quicksand'),
                headlineMedium: TextStyle(fontFamily: 'Quicksand'),
                headlineSmall: TextStyle(fontFamily: 'NotoSans'),
                titleLarge: TextStyle(fontFamily: 'NotoSans'),
                titleMedium: TextStyle(fontFamily: 'NotoSans'),
                bodyLarge: TextStyle(fontFamily: 'NotoSans'),
                bodyMedium: TextStyle(fontFamily: 'NotoSans'),
                titleSmall: TextStyle(fontFamily: 'NotoSans'),
                labelSmall: TextStyle(fontFamily: 'NotoSans'),
              ),
            ),
            home: const SplashScreen());
          },
        ),
      );
    });
  }
} 
