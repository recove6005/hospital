import 'package:aligo_app/model/price_model.dart';
import 'package:aligo_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class PriceRepo {
  static final Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<List<PriceModel>> getPayedPriceModels() async {
    List<PriceModel> models = [];
    String uid = await AuthService.getCurrentUserUid();

    try {
      var snap = await _store.collection('price').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
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