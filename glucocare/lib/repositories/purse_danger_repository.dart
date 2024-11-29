import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/purse_danger_model.dart';
import 'package:logger/logger.dart';

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
      var docSnapshot = await _store.collection('purse_danger').get();
      for (var doc in docSnapshot.docs) {
        PurseDangerModel model = PurseDangerModel.fromJson(doc.data());
        models.add(model);
      }
    } catch (e) {
      logger.e('[glucocare_log] Failed to load gluco dangers (selectAllDanger): $e');
    }
    return models;
  }
}