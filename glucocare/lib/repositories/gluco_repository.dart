import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/repositories/colname_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class GlucoRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertGlucoCheck(GlucoModel model) async {
    String uid = AuthService.getCurUserUid();

    try {
      await _store
          .collection('gluco_check').doc(uid)
          .collection(model.checkDate).doc(model.checkTime)
          .set(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed to insert GlucoCheck field : $e');
    }
  }

  static Future<List<GlucoModel>> selectAllGlucoCheck() async {
    String uid = AuthService.getCurUserUid();
    List<GlucoModel> models = <GlucoModel>[];

    List<String> namelist = await ColNameRepository.selectAllGlucoColName();

    for(var name in namelist) {
      try {
        var docSnapshot = await _store.collection('gluco_check').doc(uid)
            .collection(name).get();
        for(var doc in docSnapshot.docs) {
          GlucoModel model = GlucoModel.fromJson(doc.data());
          models.add(model);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco check history $e');
        return [];
      }
    }

    return models;
  }

  static Future<GlucoModel?>? selectGlucoByColName(String colName) async {
    String uid = AuthService.getCurUserUid();

    try {
      var docSnapshot = await _store.collection('gluco_check').doc(uid).collection(colName)
          .orderBy('check_time', descending: true).limit(1).get();
      GlucoModel model = GlucoModel.fromJson(docSnapshot.docs.first.data());
      return model;
    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco check history $e');
      return null;
    }
  }

  static Future<void> updateGlucoCheck(GlucoModel model) async {

  }

  static Future<void> deleteGlucoCheck(GlucoModel model) async {

  }
}