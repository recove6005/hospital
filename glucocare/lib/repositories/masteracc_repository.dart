import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/master_user_model.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class MasteraccRepository {
  static Logger logger = Logger();
  static FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> registerMasterUser(MasterUserModel model) async {
    try {
      await _store.collection('master').doc(model.uid).set(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed to nominate ${model.name} for the master account. : $e ');
    }
  }

  static Future<MasterUserModel?> getCurMasterUserModel() async {
    MasterUserModel? model = null;

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        if(uid != null) {
          var docSnapshot = await _store.collection('master').doc(uid).get();
          if(docSnapshot.exists) model = MasterUserModel.fromJson(docSnapshot.data()!);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to get current user.');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        if(kakaoId != null) {
          var docSnapshot = await _store.collection('master').doc(kakaoId).get();
          if(docSnapshot.exists) model = MasterUserModel.fromJson(docSnapshot.data()!);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to get current user.');
      }
    }
    return model;
  }

  static Future<MasterUserModel?> getCurMasterUserModelByUid(String uid) async {
    MasterUserModel? model = null;

    try {
      var docSnapshot = await _store.collection('master').doc(uid).get();
      model = MasterUserModel.fromJson(docSnapshot.data()!);
    } catch(e) {
      logger.e('[glucocare_log] Failed to get current user.');
    }
    return model;
  }
}