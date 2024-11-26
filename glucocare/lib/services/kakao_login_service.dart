import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

class KakaoLogin {
  static Logger logger = Logger();

  static Future<bool> login() async {
    if(await isKakaoTalkInstalled()) {
      try {
        // 카카오톡 로그인
        OAuthToken oauthToken = await UserApi.instance.loginWithKakaoTalk();
        logger.e('[glucocare_log] Succeed to login with kakaotalke ${oauthToken.accessToken}');
        // var user = await UserApi.instance.me();
        return true;
      } catch (e) {
        if (e is PlatformException && e.code == 'CANCELED') {
          logger.d('[glucocare_log] kakao login canceled. $e');
          return false;
        }
      }
    }

    logger.d('[glucocare_log] Failed to login with kakao.');
    return false;
  }
}