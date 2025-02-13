import 'package:aligo_app/model/deposit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class DepositRepo {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> addDepositInfo(DepositModel model, String docId) async {
    try {
      await _store.collection('deposit').doc(docId).set(model.toFirebase());
    } catch(e) {
      logger.e('aligo-log Failed to add deposit info. $e');
    }
  }

  static Future<DepositModel?> getDepositInfoByDocId(String docId) async {
    DepositModel? model;

    try {
      var docRef = await _store.collection('deposit').doc(docId).get();
      model = DepositModel.fromFirebase(docRef.data()!);
    } catch(e) {
      logger.e('aligo-log Failed to get deposit info by docId. $e');
    }

    return model;
  }
}