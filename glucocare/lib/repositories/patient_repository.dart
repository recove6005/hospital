import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class PatientRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<PatientModel?> selectPatient(String uid) async {
    try {
      DocumentSnapshot docSnapshot = await _store.collection('patient').doc(uid).get();

      if(docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        return PatientModel.fromJson(data);
      } else {
        logger.e('[glucocare_log] Patient data not found.');
      }
    } catch(e) {
      logger.e('[glucocare_log] Error fetching patient data: $e');
      rethrow;
    }

    return null;
  }

  static Future<void> insertPatient(PatientModel model) async {
    String? id = AuthService.getCurUserUid();

    try {
      await _store.collection('patient').doc(id).set(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed to insert patient : $e');
    }
  }

  static Future<bool> updatePatient() async {
    return true;
  }

  static Future<bool> deletePatient() async {
    return true;
  }
}