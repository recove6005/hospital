import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:glucocare/repositories/toekn_repository.dart';
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
    List<String> tokens = await TokenRepository.selectMasterTokens();

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
}