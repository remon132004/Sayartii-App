import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/views/predicted_codes/predicted_code_description.dart';


late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

Future<void> initializeNotifications() async{
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
  androidPlugin?.requestNotificationsPermission();

   AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
   InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // Handle notification tap callback
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && response.payload!.isNotEmpty) {
        selectNotificationSubject.add(response.payload!);
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const PredictedCodeDescription(),
          ),
        );
      }
    },
  );
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', 
    'your_channel_name', 
    channelDescription: 'your_channel_description', 
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

