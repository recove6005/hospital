import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:glucocare/repositories/toekn_repository.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static Logger logger = Logger();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<String?> getToken() async {
    String? token = await _messaging.getToken();
    logger.d('[glucocare_log] A FCM token was gatted : $token');
    return token;
  }

  static Future<void> sendPushNotification(String name, String type, String value, String checkDate, String checkTime) async {
    List<String> tokens = await TokenRepository.selectAdminTokens();

    logger.d('[glucocare_log] tokens:$tokens, name: $name, type: $type, value:$value, checkDate:$checkDate, checkTime:$checkTime');

    const url = "https://us-central1-glucocare-7820b.cloudfunctions.net/sendPushNotification";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "tokens": tokens,
          "name": name,
          "type": type,
          "value": value,
          "checkDate": checkDate,
          "checkTime": checkTime,
        }),
      );

      // final HttpsCallable callable = _functions.httpsCallable('sendPushNotification');
      // final response = await callable.call({});

      if(response.statusCode == 200) {
        logger.d('[glucocare_log] Patient alert is pushed.');
      } else {
        logger.e('[glucocare_log] FCM failed: ${response.body}');
      }

    } catch(e) {
      logger.e('[glucocare_log] error: $e');
    }
  }

  static Future<void> initialize() async {
    // FCM 권한 요청
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 포그라운드 알림 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.d('[glucocare_log] Foreground message received: ${message.data['title']}');
      // TODO: 알림 UI표시 (flutter_local_notification)
      String? title = message.data['title'];
      String? body = message.data['body'];
      NotificationService.showForegreoundFCMNotification(title!, body!);
    });

    // 백그라운드 및 종료 상태에서 알림 클릭 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.d('[glucocare_log] Notification clicked: ${message.data['title']}');
      // TODO: 알림 클릭 시의 동작 처리
    });

    // 앱 종료 상태에서 알림 클릭 처리
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null) {
      logger.d('[glucocare_log] App launched from notification: ${initialMessage.data['title']}');
      // TODO: 초기 알림 처리
    }
  }
}