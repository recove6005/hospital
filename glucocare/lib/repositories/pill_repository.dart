import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class PillRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPillCheck(PillModel model) async {
    String uid = AuthService.getCurUserUid();
    try {
      await _store.collection('pill_check').doc(uid)
          .collection(model.saveDate).doc(model.saveTime)
          .set(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed to insert pill_check : $e');
    }
  }
}