import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'colname_repository.dart';

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
  
  static Future<List<PillModel>> selectAllPillModels() async {
    String uid = AuthService.getCurUserUid();
    List<PillModel> models = <PillModel>[];
    List<String> namelist = await ColNameRepository.selectAllAlarmColName();

    for(var name in namelist) {
      try {
        var querySnapshot = await _store.collection('pill_check').doc(uid)
            .collection(name)
            .orderBy('alarm_time', descending: false).get();
        for(var doc in querySnapshot.docs) {
          PillModel model = PillModel.fromJson(doc.data());
          models.add(model);
        }
      } catch (e) {
        logger.d('[glucocare_log] Failed to select pill models : $e');
        return [];
      }
    }

    return models;
  }
}