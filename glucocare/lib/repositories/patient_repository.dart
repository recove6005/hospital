import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class PatientRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertInitPatient() async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        PatientModel model = PatientModel(uid: uid!, kakaoId: '', gen: '', birthDate: Timestamp.fromDate(DateTime(1900, 1, 1, 1, 1)), isFilledIn: false, name: '', isAdmined: false);
        _store.collection('patients').doc(uid).set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to init patient info : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        PatientModel model = PatientModel(uid: '', kakaoId: kakaoId!, gen: '', birthDate: Timestamp(0, 0), isFilledIn: false, name: '', isAdmined: false);
        _store.collection('patients').doc(kakaoId).set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to init patient info : $e');
      }
    }
  }

  static Future<List<PatientModel>> selectAllPatient() async {
    List<PatientModel> models = [];

    try {
      var docSnapshot = await _store.collection('patients')
          .where('is_admined', isEqualTo: false)
          .orderBy('name')
          .orderBy('gen')
          .orderBy('birth_date')
          .get();
      for(var doc in docSnapshot.docs) {
        PatientModel model = PatientModel.fromJson(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load patient all. : $e');
    }

    return models;
  }
  
  static Future<List<PatientModel>> selectAllPatientByName(String name) async {
    List<PatientModel> models = [];
    
    try {
      var docSnapshot = await _store.collection('patients')
          .where('is_admined', isEqualTo: false)
          .where('name', isEqualTo: name)
          .orderBy('name').orderBy('gen')
          .orderBy('birth_date').get();
      for(var doc in docSnapshot.docs) {
        PatientModel model = PatientModel.fromJson(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load patient all. : $e');
    }

    return models;
  }

  static Future<PatientModel?> selectPatientByUid() async {
    PatientModel? model;
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var snapshot = await _store.collection('patients').doc(uid).get();
      model = PatientModel.fromJson(snapshot.data()!);
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var snapshot = await _store.collection('patients').doc(kakaoId).get();
      model = PatientModel.fromJson(snapshot.data()!);
    }
    return model;
  }

  static Future<PatientModel?> selectPatientBySpecificUid(String uid) async {
    PatientModel? model;

    try {
      var snapshot = await _store.collection('patients').doc(uid).get();
      model = PatientModel.fromJson(snapshot.data()!);
    } catch(e) {
      logger.e('[glucocare_log] Failed to load patient info : $e');
    }
    return model;
  }

  static Future<void> updatePatientInfo(PatientModel model) async {
    try {
      if(await AuthService.userLoginedFa()) {
        String? uid = AuthService.getCurUserUid();
        _store.collection('patients').doc(uid).update(model.toJson());
      } else {
        String? kakaoId = await AuthService.getCurUserId();
        _store.collection('patients').doc(kakaoId).update(model.toJson());
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to update patient model (patient_repository.dart/updatePatientInfo) : $e');
    }
  }
}