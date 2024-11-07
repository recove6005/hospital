import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

class KakaoLogin {
  static Logger logger = Logger();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> login() async {
    if(await isKakaoTalkInstalled()) {
      try {
        // 카카오톡 로그인
        OAuthToken oauthToken = await UserApi.instance.loginWithKakaoTalk();
        // firebase 연동
        final credential = OAuthProvider("kakao.com").credential(
          accessToken: oauthToken.accessToken,
        );
        // firebase 인증
        UserCredential userCredential = await _auth.signInWithCredential(credential);

        if(userCredential.user != null) {
          // 인증 성공
          return true;
        }

      } catch (e) {
        if(e is PlatformException && e.code == 'CANCELED') return false;
        // 카카오톡에 연결된 계정이 없는 경우 카카오계정으로 로그인
        try {
          OAuthToken oauthToken = await UserApi.instance.loginWithKakaoAccount();

          final credential = OAuthProvider("kakao.com").credential(
            accessToken: oauthToken.accessToken,
          );
          UserCredential userCredential = await _auth.signInWithCredential(credential);

          if(userCredential.user != null) {
            // 인증 성공
            logger.d('[glucocare_log] 카카오계정으로 로그인 성공');
            return true;
          }
        } catch (e) {
          logger.d('[glucocare_log] 카카오계정으로 로그인 실패 $e');
        }
      }
    } else {
      // 카카오톡 실행이 불가할 경우 카카오계정으로 로그인
      try {
          OAuthToken oauthToken = await UserApi.instance.loginWithKakaoAccount();

          final credential = OAuthProvider("kakao.com").credential(
            accessToken: oauthToken.accessToken,
          );
          UserCredential userCredential = await _auth.signInWithCredential(credential);

          if(userCredential.user != null) {
            // 인증 성공
            logger.d('[glucocare_log] 카카오계정으로 로그인 성공');
            return true;
          }
      } catch (e) {
        logger.e('[glucocare_log] 카카오계정으로 로그인 실패 $e');
        return false;
      }
    }

    return false;
  }
}