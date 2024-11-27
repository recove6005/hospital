import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as ka;
import 'package:logger/logger.dart';

class AuthService {
  static Logger logger = Logger();
  static final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  static String _verifyId = '';

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

  static void authPhoneNumber(String phone) async {
      await _auth.verifyPhoneNumber(
          phoneNumber: '+82${phone.substring(1)}',
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
            _verifyId = verificationId;
            logger.d('[glucocare_log] id: ${verificationId}, $resendToken, +82${phone.substring(1)}');
          },
          timeout: const Duration(seconds: 60),
          codeAutoRetrievalTimeout: (String veficicationId) {
            // Auto-resolution timed out...
          },
      );
    }

  static Future<void> authCodeAndLogin(String smsCode) async {
  // Create a PhoneAuthCredential with the code
  fa.PhoneAuthCredential credential = fa.PhoneAuthProvider.credential(
      verificationId: _verifyId,
      smsCode: smsCode
  );
  // Sign the user in (or link) with the credential
  await _auth.signInWithCredential(credential);
}


static Future<void> signOut() async {
    await _auth.signOut();
    await ka.UserApi.instance.logout();
  }
}