import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/admin_request_model.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/repositories/admin_request_image_storage.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class AdminRequestRepository {
  static Logger logger = Logger();
  static FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertAdminRequest() async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      if(uid != null) {
        AdminRequestModel model = AdminRequestModel(uid: uid, accepted: false);
        _store.collection('admin_request').doc(uid).set(model.toJson());
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      if(kakaoId != null) {
        AdminRequestModel model = AdminRequestModel(uid: kakaoId, accepted: false);
        _store.collection('admin_request').doc(kakaoId).set(model.toJson());
      }
    }
  }

  static Future<AdminRequestModel?> selectAdminRequest() async {
    AdminRequestModel? model = null;

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      if(uid != null) {
        var snapshot = await _store.collection('admin_request').doc(uid).get();
        if(snapshot.exists) {
          model = AdminRequestModel.fromJson(snapshot.data()!);
          logger.d('${snapshot.exists}');
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      if(kakaoId != null) {
        var snapshot = await _store.collection('admin_request').doc(kakaoId).get();
        if(snapshot.exists) {
          model = AdminRequestModel.fromJson(snapshot.data()!);
        }
      }
    }
    return model;
  }

  static Future<List<AdminRequestModel>> selectAllAdminRequest() async {
    List<AdminRequestModel> models = [];
    try {
      var snapshot = await _store.collection('admin_request').get();
      for(var doc in snapshot.docs) {
        AdminRequestModel model = AdminRequestModel.fromJson(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load admin list');
    }

    return models;
  }

  static Future<void> deleteAdminRequest() async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      if(uid != null) {
        _store.collection('admin_request').doc(uid).delete();
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      if(kakaoId != null) {
        _store.collection('admin_request').doc(kakaoId).delete();
      }
    }
  }

  static Future<void> setUserUptoAdmin(String uid) async {
    UserModel? userModel = await UserRepository.selectUserBySpecificUid(uid);
    if(userModel != null) {
      UserModel updateModel = UserModel(
        uid: userModel.uid,
        kakaoId: userModel.kakaoId,
        name: userModel.name,
        gen: userModel.gen,
        birthDate: userModel.birthDate,
        isFilledIn: userModel.isFilledIn,
        isAdmined: true,
        state: userModel.state,
      );
      UserRepository.updateUserInfoBySpecificUid(updateModel);
    }
    
    AdminRequestModel model = AdminRequestModel(uid: uid, accepted: true);
    try {
      _store.collection('admin_request').doc(uid).set(model.toJson());
      logger.d('[glucocare_log] user updated. ${model.uid}');
    } catch(e) {
      logger.d('[glucocare_log] Failed to update user. ${model.uid}');
    }
    
    AdminRequestImageStorage.deleteFileBySpecificUid(uid);
  }

  static Future<void> cancelUserUptoAdmin(String uid) async {
    UserModel? userModel = await UserRepository.selectUserBySpecificUid(uid);
    if(userModel != null) {
      UserModel updateModel = UserModel(
        uid: userModel.uid,
        kakaoId: userModel.kakaoId,
        name: userModel.name,
        gen: userModel.gen,
        birthDate: userModel.birthDate,
        isFilledIn: userModel.isFilledIn,
        isAdmined: false,
        state: userModel.state,
      );
      UserRepository.updateUserInfoBySpecificUid(updateModel);
    }

    // AdminRequestModel model = AdminRequestModel(uid: uid, accepted: false);
    // _store.collection('admin_request').doc(uid).set(model.toJson());
    // logger.d('[gluccoare_log] user updated. ${model.uid}');
    _store.collection('admin_request').doc(uid).delete();
  }
}