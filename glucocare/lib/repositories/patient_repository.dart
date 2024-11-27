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
        PatientModel model = PatientModel(uid: uid!, kakaoId: '', gen: '', birthDate: Timestamp(0, 0), isFilledIn: false, name: '');
        _store.collection('patients').doc(uid).set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to init patient info : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        PatientModel model = PatientModel(uid: '', kakaoId: kakaoId!, gen: '', birthDate: Timestamp(0, 0), isFilledIn: false, name: '');
        _store.collection('patients').doc(kakaoId).set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to init patient info : $e');
      }
    }
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