import 'dart:developer';
import 'dart:io';

import 'package:countdown/models/countdown_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class NotificationService extends ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String ANDROID_CHANNEL_ID = "COUNTDOWN_TRACKER_ID";
  static const String ANDROID_CHANNEL_NAME = "COUNTDOWN_TRACKER";
  static const String ANDROID_CHANNEL_DESCRIPTION = "Countdown Tracker";

  void registerNotificationPlugin() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {
        return Future.value("ok");
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    bool initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: (String payload) async {
      if (payload != null) {
        log('notification payload: $payload');
      }
    });

    if (!initialized) {
      log("Notification plugin initialization failed!");
    } else {
      log("Notification plugin initialization worked!");
    }

    // prompt for notifications permissions
    if (Platform.isIOS) {
      // TODO: handle failure case
      final bool result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // initialize timezone (for scheduled notifications)
    initializeTimeZones();
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    setLocalLocation(getLocation(currentTimeZone));
  }

  NotificationService() {
    registerNotificationPlugin();
  }

  void triggerInstantNotification(String body,
      {String title = "Countdown Notification", String payload = ""}) async {
    // TODO: What if the hash exists already
    int id = body.hashCode;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(ANDROID_CHANNEL_ID, ANDROID_CHANNEL_NAME,
            ANDROID_CHANNEL_DESCRIPTION,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  void triggerScheduledCountdownNotification(
      CountdownItem countdownItem) async {
    int id = countdownItem.id.hashCode;

    triggerScheduledNotification(
      id,
      "Your countdown '${countdownItem.label}' is completed!",
      "Countdown Notification",
      TZDateTime.from(countdownItem.time, local),
    );
  }

  void triggerScheduledNotification(
      int id, String body, String title, TZDateTime scheduledDate) async {
    // ensure scheduledDate is in the future
    if (scheduledDate.isBefore(TZDateTime.now(local))) {
      log("Not possible to schedule notifications in the past");
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
            android: AndroidNotificationDetails(
          ANDROID_CHANNEL_ID,
          ANDROID_CHANNEL_NAME,
          ANDROID_CHANNEL_DESCRIPTION,
        )),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  void clearScheduledNotification(CountdownItem countdownItem) async {
    flutterLocalNotificationsPlugin.cancel(countdownItem.id.hashCode);
  }

  void clearAllScheduledNotifications() async {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>>
      getScheduledNotificationRequests() async {
    List<PendingNotificationRequest> pendingRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingRequests;
  }
}
