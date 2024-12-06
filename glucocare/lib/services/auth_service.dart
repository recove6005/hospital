import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as ka;
import 'package:logger/logger.dart';

class AuthService {
  static Logger logger = Logger();
  static Completer<String> completer = Completer();
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

  static Future<String> authPhoneNumber(String phone) async {

      await _auth.verifyPhoneNumber(
          phoneNumber: '+82${phone.substring(1)}',
          codeSent: (String verificationId, int? resendToken) async {
            logger.d('[glucocare_log] code sented ===> id: $verificationId, token: $resendToken, phone: +82${phone.substring(1)}');
            completer.complete(verificationId);
          },
          verificationCompleted: (fa.PhoneAuthCredential credential) async {
            // Android only
            // Sign the user in (or link) with the auto-generated credential
            await _auth.signInWithCredential(credential);
          },
          timeout: const Duration(minutes: 1),
          codeAutoRetrievalTimeout: (String verificationId) {
            // Auto-resolution timed out...
            completer.complete(verificationId);
          },
          verificationFailed: (fa.FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              logger.e('[glucocare_log] The provided phone number is not valid.');
              completer.completeError(e);
            }
          },
      );

      return completer.future;
    }

  static Future<void> authCodeAndLogin(String verifyId, String smsCode) async {
  // Create a PhoneAuthCredential with the code
  fa.PhoneAuthCredential credential = fa.PhoneAuthProvider.credential(
      verificationId: verifyId,
      smsCode: smsCode
  );
  // Sign the user in (or link) with the credential
  logger.d('[glucocare_log] id: $verifyId, smsCode: $smsCode}');
  await _auth.signInWithCredential(credential);
}

static Future<void> signOut() async {
    await _auth.signOut();
    await ka.UserApi.instance.logout();
  }
}