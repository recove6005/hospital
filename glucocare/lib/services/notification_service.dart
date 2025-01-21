import 'dart:math';

import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Logger logger = Logger();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initNotification() async {
    // Android 설정
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // IOS 설정
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.d('Notification clicked with payload: ${response.payload}');
      },
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'alarm_1004_name',
          'alarm_1004_channel',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '다올케어',
      '약 먹을 시간이에요 !',
      notificationDetails,
      payload: 'item x',
    );
  }

  static Future<void> showForegreoundFCMNotification(String title, String body) async {
    logger.d('[glucocare_log] show notification.');
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'alarm_name_foreground_fcm_notify',
            'alarm_chenel_foreground_fcm_notify_patient_alert',
            channelDescription: 'notification to alert patients in danger',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: 'item x',
    );
  }
}