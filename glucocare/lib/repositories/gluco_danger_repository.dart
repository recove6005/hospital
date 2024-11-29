import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/gluco_danger_model.dart';

class GlucoDangerRepository {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static void insertDanger(GlucoDangerModel model) async {
    try {
      _store.collection('gluco_danger').doc(model.checkTime.toString()).set(model.toJson());
    } catch(e) {
      logger.d('[glucocare_log] Failed to load gluco danger : $e');
    }
  }

  static Future<List<GlucoDangerModel>> selectAllDanger() async {
    List<GlucoDangerModel> models = [];
    try {
      var docSnapshot = await _store.collection('gluco_danger').get();
      for (var doc in docSnapshot.docs) {
        GlucoDangerModel model = GlucoDangerModel.fromJson(doc.data());
        models.add(model);
      }
    } catch (e) {
      logger.e('[glucocare_log] Failed to load gluco dangers (selectAllDanger): $e');
    }
    return models;
  }
}