import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/purse_danger_model.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';

class PurseDangerRepository {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static void insertDanger(PurseDangerModel model) async {
    try {
      _store.collection('purse_danger').doc(model.checkTime.toString()).set(model.toJson());
    } catch(e) {
      logger.d('[glucocare_log] Failed to load purse danger : $e');
    }
  }

  static Future<List<PurseDangerModel>> selectAllDanger() async {
    List<PurseDangerModel> models = [];
    try {
      var docSnapshot = await _store.collection('purse_danger').orderBy('check_time', descending: true).limit(100).get();
      for (var doc in docSnapshot.docs) {
        PurseDangerModel model = PurseDangerModel.fromJson(doc.data());
        models.add(model);
      }
    } catch (e) {
      logger.e('[glucocare_log] Failed to load gluco dangers (selectAllDanger): $e');
    }
    return models;
  }

  static Future<List<PurseDangerModel>> selectPurseDangerByUid() async {
    List<PurseDangerModel> models = [];
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('purse_danger').where('uid', isEqualTo: uid).get();
      for(var doc in docSnapshot.docs) {
        PurseDangerModel model = PurseDangerModel.fromJson(doc.data());
        models.add(model);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('purse_danger').where('uid', isEqualTo: kakaoId).get();
      for(var doc in docSnapshot.docs) {
        PurseDangerModel model = PurseDangerModel.fromJson(doc.data());
        models.add(model);
      }
    }

    return models;
  }

  static Future<void> deleteGlucoDanger() async {
    List<PurseDangerModel> models = await selectPurseDangerByUid();
    for(PurseDangerModel model in models) {
      var snapshot = await _store.collection('purse_danger').where('uid', isEqualTo: model.uid).get();
      for(var doc in snapshot.docs) {
        await _store.collection('purse_danger').doc(doc.id).delete();
      }
    }
  }
}