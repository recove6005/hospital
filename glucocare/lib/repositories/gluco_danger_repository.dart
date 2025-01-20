import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';
import '../models/gluco_danger_model.dart';

class GlucoDangerRepository {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertDanger(GlucoDangerModel model) async {
    try {
      _store.collection('gluco_danger').doc(model.checkTime.toString()).set(model.toJson());
    } catch(e) {
      logger.d('[glucocare_log] Failed to load gluco danger : $e');
    }
  }

  static Future<List<GlucoDangerModel>> selectAllDanger() async {
    List<GlucoDangerModel> models = [];
    try {
      var docSnapshot = await _store.collection('gluco_danger').orderBy('check_time', descending: true).get();
      for (var doc in docSnapshot.docs) {
        GlucoDangerModel model = GlucoDangerModel.fromJson(doc.data());
        models.add(model);
      }
    } catch (e) {
      logger.e('[glucocare_log] Failed to load gluco dangers (selectAllDanger): $e');
    }
    return models;
  }

  static Future<List<GlucoDangerModel>> selectGlucoDangerByUid() async {
    List<GlucoDangerModel> models = [];
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('gluco_danger').where('uid', isEqualTo: uid).get();
      for(var doc in docSnapshot.docs) {
        GlucoDangerModel model = GlucoDangerModel.fromJson(doc.data());
        models.add(model);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('gluco_danger').where('uid', isEqualTo: kakaoId).get();
      for(var doc in docSnapshot.docs) {
        GlucoDangerModel model = GlucoDangerModel.fromJson(doc.data());
        models.add(model);
      }
    }

    return models;
  }

  static Future<void> deleteGlucoDanger() async {
    List<GlucoDangerModel> models = await selectGlucoDangerByUid();
    for(GlucoDangerModel model in models) {
      var snapshot = await _store.collection('gluco_danger').where('uid', isEqualTo: model.uid).get();
      for(var doc in snapshot.docs) {
        await _store.collection('gluco_danger').doc(doc.id).delete();
      }
    }
  }
}