import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class PurseRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPurseCheck(PurseModel model) async {
    String uid = AuthService.getCurUserUid();

    try {
      await _store
          .collection('purse_check').doc(uid)
          .collection(model.checkDate).doc(model.checkTime)
          .set(model.toJson());
      logger.e('[glucocare_log] PurseCheck field was inserted.');
    } catch(e) {
      logger.e('[glucocare_log] Failed to insert PurseCheck field : $e');
    }
  }

  static Future<void> updatePurseCheck(PurseModel model) async {

  }

  static Future<void> deletePurseCheck(PurseModel model) async {

  }
}