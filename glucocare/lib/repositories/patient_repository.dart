import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class UserRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertInitUser() async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        UserModel model = UserModel(uid: uid!, kakaoId: '', gen: '', birthDate: Timestamp.fromDate(DateTime(1900, 1, 1, 1, 1)), isFilledIn: false, name: '', isAdmined: false, state: '없음');
        _store.collection('patients').doc(uid).set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to init patient info : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        UserModel model = UserModel(uid: '', kakaoId: kakaoId!, gen: '', birthDate: Timestamp(0, 0), isFilledIn: false, name: '', isAdmined: false, state: '없음');
        _store.collection('patients').doc(kakaoId).set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to init patient info : $e');
      }
    }
  }

  static Future<List<UserModel>> selectAllUser() async {
    List<UserModel> models = [];

    try {
      var docSnapshot = await _store.collection('patients')
          .where('is_admined', isEqualTo: false)
          .orderBy('name')
          .orderBy('gen')
          .orderBy('birth_date')
          .get();
      for(var doc in docSnapshot.docs) {
        UserModel model = UserModel.fromJson(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load patient all. : $e');
    }

    return models;
  }
  
  static Future<List<UserModel>> selectAllUserByName(String name) async {
    List<UserModel> models = [];
    
    try {
      var docSnapshot = await _store.collection('patients')
          .where('is_admined', isEqualTo: false)
          .where('name', isEqualTo: name)
          .orderBy('name').orderBy('gen')
          .orderBy('birth_date').get();
      for(var doc in docSnapshot.docs) {
        UserModel model = UserModel.fromJson(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load patient all. : $e');
    }

    return models;
  }

  static Future<UserModel?> selectUserByUid() async {
    UserModel? model;
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var snapshot = await _store.collection('patients').doc(uid).get();
      model = UserModel.fromJson(snapshot.data()!);
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var snapshot = await _store.collection('patients').doc(kakaoId).get();
      model = UserModel.fromJson(snapshot.data()!);
    }
    return model;
  }

  static Future<UserModel?> selectUserBySpecificUid(String uid) async {
    UserModel? model;

    try {
      var snapshot = await _store.collection('patients').doc(uid).get();
      model = UserModel.fromJson(snapshot.data()!);
    } catch(e) {
      logger.e('[glucocare_log] Failed to load patient info : $e');
    }
    return model;
  }

  static Future<void> updateUserInfo(UserModel model) async {
    try {
      if(await AuthService.userLoginedFa()) {
        String? uid = AuthService.getCurUserUid();
        if(uid != null) {
          await _store.collection('patients').doc(uid).update(model.toJson());
        }
      } else {
        String? kakaoId = await AuthService.getCurUserId();
        if(kakaoId != null) {
          await _store.collection('patients').doc(kakaoId).update(model.toJson());
        }
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to update patient model (patient_repository.dart/updatePatientInfo) : $e');
    }
    logger.d('[glucocare_log] updated');
  }

  static Future<void> updateUserInfoBySpecificUid(UserModel model) async {
    String uid = '';
    if(model.uid != '') {
      uid = model.uid;
    } else {
      uid = model.kakaoId;
    }
    try {
      await _store.collection('patients').doc(uid).update(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed to update patient model (updatePatientInfoBySpecificUid): $e');
    }
  }
}