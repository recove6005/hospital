import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  static Logger logger = Logger();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? getCurUser() {
    if(_auth.currentUser != null) return _auth.currentUser;
    else {
      logger.d('[glucocare_log] User is not exist.');
      return null;
    }
  }

  static String? getCurUserUid() {
    if(_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    } else {
      logger.d('[glucocare_log] User is not exist.');
    }
    return null;
  }

  static void sendPhoneAuth(String phone) async {
    String phoneNumSet = phone.substring(1);
    String formatPhone = "+82$phoneNumSet";

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formatPhone,
        timeout: const Duration(seconds: 60),

        // Android 기기 sms코드 자동처리
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch(e) {
            logger.d('[glucocare_log] Failed to verify auth : $e');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          // 잘못된 번호나 sms할당량 초과 여부 등 실패 이벤트 처리
          if (e.code == 'invalid-phone-number') {
            logger.d('[glucocare_log] Failed to send a code : $e');
          }
        },

        codeSent: (String verificationId, int? resendToken) async {
          // 사용자에게 메시지 표시
          logger.d('glucocare_log : Verification code sent to $phone');
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
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
  }
}