import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as ka;
import 'package:logger/logger.dart';

class AuthService {
  static Logger logger = Logger();
  static final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  static Future<bool> userLoginedFa() async {
    if(_auth.currentUser == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> userLoginedKa() async {
    try {
      ka.User user = await ka.UserApi.instance.me();
      return true;
    } catch(e) {
      return false;
    }
  }

  static String? getCurUserUid() {
    if(_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    } else {

    }
    return null;
  }

  static Future<String?>? getCurUserId() async{
    try {
      ka.User user = await ka.UserApi.instance.me();
      return user.id.toString();
    } catch(e) {
      logger.e('[glucocare_log] $e');
      return null;
    }
  }

    static void authPhoneNumber(String phoneNumber) async {
      await _auth.verifyPhoneNumber(
          phoneNumber: '+82$phoneNumber',
          verificationCompleted: (fa.PhoneAuthCredential credential) async {
            // Android only
            // Sign the user in (or link) with the auto-generated credential
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (fa.FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              logger.e('[glucocare_log] The provided phone number is not valid.');
            }
          },
          codeSent: (String verificationId, int? resendToken) async {
            logger.d('[glucocare_log] id: ${verificationId}');
            String smsCode = 'xxxxxx';

            // Create a PhoneAuthCredential with the code
            fa.PhoneAuthCredential credential = fa.PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode
            );

            // Sign the user in (or link) with the credential
            _auth.signInWithCredential(credential);
          },
          timeout: const Duration(seconds: 60),
          codeAutoRetrievalTimeout: (String veficicationId) {
            // Auto-resolution timed out...
          },
      );
    }

    static void sendPhoneAuth(String phone) async {
      String phoneNumSet = phone.substring(1);
    String formatPhone = "+82$phoneNumSet";

    await fa.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formatPhone,
        timeout: const Duration(seconds: 60),

        // Android 기기 sms코드 자동처리
        verificationCompleted: (fa.PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch(e) {
            logger.d('[glucocare_log] Failed to verify auth : $e');
          }
        },

        verificationFailed: (fa.FirebaseAuthException e) {
          // 잘못된 번호나 sms할당량 초과 여부 등 실패 이벤트 처리
          if (e.code == 'invalid-phone-number') {
            logger.d('[glucocare_log] Failed to send a code : $e');
          }
        },

        codeSent: (String verificationId, int? resendToken) async {
          // 사용자에게 메시지 표시
          logger.d('glucocare_log : Verification code sent to $phone');
          fa.PhoneAuthCredential credential = fa.PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: '인증번호를 확인해 주세요.'
          );
          try{
            await _auth.signInWithCredential(credential);
          } catch(e) {
            logger.d('[glucocare_log] Failed to send a code : $e');
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // 자동 sms 코드 처리에 실패한 경우 시간 초과 처리
          logger.d('[glucocare_log] Failed to send a code : timeout');
        });

    logger.d('[glucocare_log] _sendSMSCode is done.');
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await ka.UserApi.instance.logout();
  }
}