import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'ontap_notifications.dart';


class NotificationServices{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initNotification(var context){
    AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings darwinInitializationSettings = const DarwinInitializationSettings(requestAlertPermission: true, defaultPresentAlert: true);
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse){
      final String? payload = notificationResponse.payload;
      // Perform actions based on payload //

      showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text("Notification"!),
          content: Text("Notification Body"!),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () async {
                if(notificationResponse.payload == "secondScreen"){
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationScreen(payload: payload!,)));
                }else{
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        ),
      );
    },
    );
  }


  //Show Notification
  Future<void> showNotification({required String title, required String body, required String payload})async{
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails("0", "androidLocalNoti");
    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }



  // Schedule notifications for a specific time //
  scheduledNotification({required String title, required String body})async{
    tz.initializeTimeZones();
    log("Notification Scheduled");
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        3,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                '2', 'scheduled channel 1',
                channelDescription: 'your channel description')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }


//Periodic Notifications //
  periodicNotification({required String title, required String body})async{
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        '3', 'periodic notification channel',
        channelDescription: 'repeating description');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.periodicallyShow(0, title,
        body, RepeatInterval.everyMinute, notificationDetails,
        androidAllowWhileIdle: true);
  }


  // cancel specific notification
  cancelNotification({required int notificationId})async{
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

// cancel all type of notifications
  cancelAllNotifications()async{
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}