import 'package:aligo_app/model/price_model.dart';
import 'package:aligo_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class PriceRepo {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> addPriceModel(PriceModel model) async {
    try {
      await _store.collection('price').doc(model.docId).set(model.toFirestore());
    } catch(e) {
      logger.e('aligo-log Failed to add price info. $e');
    }
  }

  static Future<PriceModel?> getPriceModelByDocId(String docId) async {
    PriceModel? model;
    try {
      var docRef = await _store.collection('price').doc(docId).get();
      model = PriceModel.fromFirestore(docRef.data()!);
    } catch(e) {
      logger.e('aligo-log Failed to get price info. This project is in the pre-payment request stage.. $e');
    }

    return model;
  }

  static Future<List<PriceModel>> getPayedPriceModels([int limit = 0]) async {
    List<PriceModel> models = [];
    String uid = await AuthService.getCurrentUserUid();

    try {
      var snap;
      if(limit == 0) {
        snap = await _store.collection('price').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
      } else {
        snap = await _store.collection('price').where('uid', isEqualTo: uid).orderBy('date', descending: true).limit(limit).get();
      }
      for(var doc in snap.docs) {
        PriceModel model = PriceModel.fromFirestore(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('aligo-log Failed to get payedPriceModel list. $e');
    }

    return models;
  }
}