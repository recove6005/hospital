import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static Logger logger = Logger();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<String?> _getToken() async {
    // FCM 토큰 획득
    String? token = await _messaging.getToken();
    logger.d('[glucocare_log] A FCM token was gatted : $token');
    return token;
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
    logger.d('Background message received: ${msg.notification?.body}');
  }

  static Future<void> sendBackgroundMsg() async {
    _getToken();

    // 백그라운드 알림 처리
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> sendForegroundMsg() async {
    _getToken();

    // 포그라운드 알림 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      RemoteNotification? notification = msg.notification;

      if(notification != null) {

        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
                'high_importance_ch',
                'high_importance_ntc',
                importance: Importance.max
            ),
          ),
        );
      }

      String msgString = msg.notification!.body!;
      logger.d('[glucocare_log] Foreground message: $msgString');
    });
  }

  static Future<void> initialize() async {
    // ios 권한
    NotificationSettings iosSetting = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
        'high_importance_ch',
        'high_importance_ntc',
        importance: Importance.max)
    );

    await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ));

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


  static Future<void> sendNotificationToServer() async {


  }
}