import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

class KakaoLogin {
  static Logger logger = Logger();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> login() async {
    logger.d('[glucocare_log] kakao api login is started');
    if(await isKakaoTalkInstalled()) {
      try {
        // 카카오톡 로그인
        logger.d('[glucocare_log] login with kakaotalk');
        OAuthToken oauthToken = await UserApi.instance.loginWithKakaoTalk();
        logger.e('[glucocare_log] Failed to login with kakao talk $oauthToken');
      } catch (e) {
        if (e is PlatformException && e.code == 'CANCELED') return false;
        // 카카오톡에 연결된 계정이 없는 경우 카카오계정으로 로그인
        try {
          OAuthToken oauthToken = await UserApi.instance.loginWithKakaoAccount();
          logger.d('[glucocare_log] Logind with kakao successfully $oauthToken');
        } catch (e) {
         logger.d('[glucocare_log] token is null $e');
        }
      }
    } else {
      // 카카오톡 실행이 불가할 경우 카카오계정으로 로그인
      try {
        logger.d('[glucocare_log] kakao account login');
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        logger.d('[glucocare_log] oauthToken $token');
      } catch (e) {
        logger.e('[glucocare_log] Failed to login with kakao account $e');
        return false;
      }
    }

    logger.d('[glucocare_log] What is you.');
    return false;
  }
}