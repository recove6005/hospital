import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:glucocare/models/gluco_col_name_model.dart';
import 'package:glucocare/models/gluco_danger_model.dart';
import 'package:glucocare/models/master_user_model.dart';
import 'package:glucocare/models/pill_alarm_model.dart';
import 'package:glucocare/models/purse_danger_model.dart';
import 'package:glucocare/repositories/alarm_repository.dart';
import 'package:glucocare/repositories/gluco_colname_repository.dart';
import 'package:glucocare/repositories/gluco_danger_repository.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:glucocare/repositories/masteracc_repository.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/repositories/purse_colname_repository.dart';
import 'package:glucocare/repositories/purse_danger_repository.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/repositories/reservation_repository.dart';
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

    static Future<void> authPasswordAndMasterLogin(String email, String password) async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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

  static Future<bool> isMasterUser() async {
     MasterUserModel? model = await MasteraccRepository.getCurMasterUserModel();
     if(model != null) return true;
      else return false;
  }

  static Future<void> signOut() async {
      await _auth.signOut();
      await ka.UserApi.instance.logout();
  }

  static Future<void> deleteAuth() async {
    // 개인 데이터 정보 삭제
    // patients
    await UserRepository.deletePatient();
    // gluco_danger
    await GlucoDangerRepository.deleteGlucoDanger();
    // purse_danger
    await PurseDangerRepository.deleteGlucoDanger();
    // gluco_check
    await GlucoRepository.deleteGlucoCheck();
    // purse_check
    await PurseRepository.deletePurseCheck();
    // alarm
    await AlarmRepository.deleteAlarm();
    // gluco name
    await GlucoColNameRepository.deleteGlucoColName();
    // purse name
    await PurseColNameRepository.deletePurseColName();
    // reservation
    await ReservationRepository.deleteReservationByUid();

    if(await userLoginedFa()) {
      // 파이어베이스 계정 회원탈퇴
      String? uid = getCurUserUid();
      _auth.currentUser!.delete();
    } else {
      // 카카오계정 회원탈퇴
      ka.User user = await ka.UserApi.instance.me();
      await ka.UserApi.instance.unlink();
    }
  }
}