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
          'eradfdfdf',
          '12120iasdnz,mxcnvklahdklaef',
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
      'plain title',
      'plain body',
      notificationDetails,
      payload: 'item x',
    );


    // try {
    //   await flutterLocalNotificationsPlugin.zonedSchedule(
    //     0,
    //     'Test Title',
    //     'Test Body',
    //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'send_me_the_exaxtime_channel_id3522',
    //         'send_me_the_exaxtime_channel_name987655',
    //         channelDescription: 'channel_description',
    //         importance: Importance.max,
    //         priority: Priority.high,
    //         ticker: 'ticker',
    //       ),
    //     ),
    //     uiLocalNotificationDateInterpretation:
    //     UILocalNotificationDateInterpretation.absoluteTime,
    //     androidScheduleMode: AndroidScheduleMode.inexact,
    //     //allowWhileIdle: true,
    //   );
    // } catch(e) {
    //   logger.d('[glucocare_log] Failed (showNotification) : $e');
    // }
  }

  // static tz.TZDateTime _makeDate(h, m, s) {
  //   var now = tz.TZDateTime.now(tz.local);
  //   var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m, s);
  //   if(when.isBefore(now)) {
  //     when = when.add(const Duration(days: 1));
  //   }
  //   logger.d('[glucocare_log] setTime: ${when}');
  //   return when;
  // }
}