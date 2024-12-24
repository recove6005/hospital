import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

class KakaoLogin {
  static Logger logger = Logger();

  static Future<bool> login() async {
    // var keyhash = await KakaoSdk.origin;
    // logger.d('[glucocare_log] keyhash : $keyhash');

    if(await isKakaoTalkInstalled()) {
      try {
        // 카카오톡 로그인
        OAuthToken oauthToken = await UserApi.instance.loginWithKakaoTalk();
        return true;
      } catch (e) {
        if (e is PlatformException && e.code == 'CANCELED') {
          logger.d('[glucocare_log] kakao login canceled. $e');
          return false;
        }
      }
    } else {
      logger.d('[glucocare_log] Kakaotalk was not installed in your mobile.');
    }

    Fluttertoast.showToast(msg: '카카오톡을 설치해 주세요.');
    return false;
  }
}