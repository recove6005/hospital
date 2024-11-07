import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:logger/logger.dart';

class PatientRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> insertPatient(
      String name, String id, String gen, Timestamp birthDate
      ) async {

    PatientModel patientModel = PatientModel(name: name, id: id, gen: gen, birthDate: birthDate);

    try {
      await _firestore.collection('patient').doc(id).set(patientModel.toJson());
      logger.d('glucocare_log : PatientRepository.insertPatient : A patient was created.');
      return true;
    } catch(e) {
      logger.d('glucocare_log : PatientRepository.insertPatient : Failed to create patient. : $patientModel');
      return false;
    }
  }

  static Future<bool> updatePatient(String id) async {
    return true;
  }

  static Future<bool> deletePatient(String id) async {
    return true;
  }
}