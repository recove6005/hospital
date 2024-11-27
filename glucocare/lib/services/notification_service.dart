import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Logger logger = Logger();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.d('Notification clicked with payload: ${response.payload}');
      },
    );

    logger.d('[glucocare_log] init set times.');
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  }

  static Future<void> showNotification() async {
    // const AndroidNotificationDetails androidNotificationDetails =
    //     AndroidNotificationDetails(
    //       'asdf1029jjasdf',
    //       '12120iasdnz,mxcnvklahdklaef',
    //       channelDescription: 'channel_description',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //       ticker: 'ticker',
    //     );
    //
    // const NotificationDetails notificationDetails = NotificationDetails(
    //     android: androidNotificationDetails
    // );
    //
    // await flutterLocalNotificationsPlugin.show(
    //   0,
    //   'plain title',
    //   'plain body',
    //   notificationDetails,
    //   payload: 'item x',
    // );

    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 2));
    logger.d('[glucocare_log] Scheduled Date: $scheduledDate');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Test Title',
        'Test Body',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'send_me_the_exaxtime_channel_id352asd2',
            'send_me_the_exaxtime_channel_name9asdfew7655',
            channelDescription: 'channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        //allowWhileIdle: true,
      );
    } catch(e) {
      logger.d('[glucocare_log] Failed (showNotification) : $e');
    }
  }

  static tz.TZDateTime _makeDate(h, m, s) {
    var now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m, s);
    if(when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    logger.d('[glucocare_log] setTime: ${when}');
    return when;
  }
}