import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

class KakaoLogin {
  static Logger logger = Logger();

  static void login() async {
    // 카카오톡으로 로그인
    if(await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        logger.d('gluco_log : Kakaotalk login token is geteed successfully.');
      } catch (e) {
        logger.e('gluco_log : Kakaotalk login is failed => $e');

        if(e is PlatformException && e.code == 'CANCELED') return;

        // 카카오톡에 연결된 계정이 없는 경우 카카오계정으로 로그인
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          logger.d('glucocare : 카카오계정으로 로그인 성공 ${token.accessToken}');
        } catch (e) {
          logger.d('glucocare : 카카오계정으로 로그인 실패 $e');
        }
      }
    } else {
      // 카카오톡 실행이 불가할 경우 카카오계정으로 로그인
      try {
        await UserApi.instance.loginWithKakaoAccount();
        logger.d('glucocare_log : 카카오계정으로 로그인 성공');
      } catch (e) {
        logger.e('glucocare_log : 카카오계정으로 로그인 실패 $e');
      }
    }
  }
}