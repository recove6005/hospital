import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/colname_repository.dart';
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

  static Future<List<PurseModel>> selectAllPurseCheck() async {
    String uid = AuthService.getCurUserUid();
    List<PurseModel> models = [];
    List<String> namelist = await ColNameRepository.selectAllPurseColName();

    for(var name in namelist) {
      try {
        var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name).get();
        for(var doc in docSnapshot.docs) {
          PurseModel model = PurseModel.fromJson(doc.data());
          models.add(model);
        }
      } catch(e) {
        logger.d('[glucocare_log] Failed to load purse history : $e');
        return [];
      }
    }

    return models;
  }
}