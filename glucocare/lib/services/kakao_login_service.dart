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
        logger.d('[glucocare_log] Kakao logged in : ${oauthToken}');
        return true;
      } catch (e) {
        if (e is PlatformException && e.code == 'CANCELED') {
          logger.d('[glucocare_log] kakao login canceled. $e');
          Fluttertoast.showToast(msg: '카카오톡 로그인이 취소되었습니다.');
          return false;
        }
        else if(e is PlatformException && e.code == 'NotSupportError') {
          Fluttertoast.showToast(msg: '카카오톡 로그인 후 다시 시도해 주세요.');
          return false;
        }
        else {
          logger.d('[glucocare_log] kakao login error: ${e}');
          Fluttertoast.showToast(msg: '네트워크 상태를 확인해 주세요.');
          return false;
        }
      }
    } else {
      Fluttertoast.showToast(msg: '카카오톡을 설치해 주세요.');
      return false;
    }
  }
}