import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static Logger logger = Logger();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<String?> getToken() async {
    // FCM 토큰 획득
    String? token = await _messaging.getToken();
    logger.d('[glucocare_log] A FCM token was gatted : $token');
    return token;
  }

  static Future<void> onBackgroundMsg(RemoteMessage msg) async {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? msg) {
        if(msg != null) {
          if(msg.notification != null) {
            logger.e('[glucocare_log] ${msg.notification!.title}');
            logger.e('[glucocare_log] ${msg.notification!.body}');
            logger.e('[glucocare_log] ${msg.data['click_action']}');
          }
        }
      });
  }

  static Future<void> onForegroundMsg() async {
    getToken();

    // 포그라운드 알림 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage? msg) async {
      if(msg != null) {
        if(msg.notification != null) {
          logger.e('[glucocare_log] ${msg.notification!.title}');
          logger.e('[glucocare_log] ${msg.notification!.body}');
          logger.e('[glucocare_log] ${msg.data['click_action']}');
        }
      }
    });
  }

  static Future<void> onTerminateMsg() async {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? msg){
      if(msg != null) {
        if(msg.notification != null) {
          logger.e('[glucocare_log] ${msg.notification!.title}');
          logger.e('[glucocare_log] ${msg.notification!.body}');
          logger.e('[glucocare_log] ${msg.data['click_action']}');
        }
      }
    });
  }

  static Future<void> initialize() async {
    // ios 권한
    NotificationSettings permissionSetting = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
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
  }

  static Future<String?> postMessage(String fcmToken) async {
    try {
      String? accessToken = dotenv.env['FIREBASE_MSG_ACCESS_TOKEN'];
      http.Response response = http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/glucocare-7820b/messages:send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          "message": {
            "token": fcmToken,
            // "topic": "user_uid",

            "notification": {
              "title": "FCM Test Title",
              "body": "FCM Test Body",
            },
            "data": {
              "click_action": "FCM Test Click Action",
            },
            "android": {
              "notification": {
                "click_action": "Android Click Action",
              }
            },
            "apns": {
              "payload": {
                "aps": {
                  "category": "Message Category",
                  "content-available": 1
                }
              }
            }
          }
        })) as http.Response;
      if (response.statusCode == 200) {
        return null;
      } else {
        return "Faliure";
      }
    } on HttpException catch(e) {
      return e.message;
    }
  }


}