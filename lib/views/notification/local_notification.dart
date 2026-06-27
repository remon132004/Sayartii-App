import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/views/predicted_codes/predicted_code_description.dart';
import 'package:sayartii/views/trouble_scan/dtc_details.dart';


late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

Future<void> initializeNotifications() async{
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
  androidPlugin?.requestNotificationsPermission();

   AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
   InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // Handle notification tap callback
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && response.payload!.isNotEmpty) {
        selectNotificationSubject.add(response.payload!);
        
        if (response.payload == 'dtc_scan') {
          // Navigate to DTC details screen when tapping DTC notification
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const DtcDetailsScreen(),
            ),
          );
        } else {
          // Default: navigate to AI prediction details
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const PredictedCodeDescription(),
            ),
          );
        }
      }
    },
  );
}

int _notificationIdCounter = 0;

Future<void> showNotification(String title, String body, {String? payload}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'sayartii_diagnostics', 
    'Diagnostics Alerts', 
    channelDescription: 'Notifications for vehicle diagnostic alerts and fault codes', 
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  // Use unique IDs so notifications don't overwrite each other
  _notificationIdCounter++;
  await flutterLocalNotificationsPlugin.show(
    _notificationIdCounter,
    title,
    body,
    platformChannelSpecifics,
    payload: payload ?? 'item x',
  );
}

