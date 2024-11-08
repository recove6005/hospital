import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/gluco_model.dart';
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
      logger.e('[glucocare_log] GlucoCheck field was inserted.');
    } catch(e) {
      logger.e('[glucocare_log] Failed to insert GlucoCheck field : $e');
    }
  }

  static Future<void> updateGlucoCheck(GlucoModel model) async {

  }

  static Future<void> deleteGlucoCheck(GlucoModel model) async {

  }
}