import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/repositories/pill_colname_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PillRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPillCheck(PillModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        await _store.collection('pill_check').doc(uid)
            .collection(model.saveDate).doc(model.saveTime)
            .set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to insert pill_check (insertPillCheck) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        await _store.collection('pill_check').doc(kakaoId)
            .collection(model.saveDate).doc(model.saveTime)
            .set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to insert pill_check (insertPillCheck) : $e');
      }
    }

  }
  
  static Future<List<PillModel>> selectAllPillModels() async {
    List<PillModel> models = <PillModel>[];
    List<String> namelist = await PillColNameRepository.selectAllAlarmColName();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
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
          logger.d('[glucocare_log] Failed to select pill models (selectAllPillModels) : $e');
          return [];
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(var name in namelist) {
        try {
          var querySnapshot = await _store.collection('pill_check').doc(kakaoId)
              .collection(name)
              .orderBy('alarm_time', descending: false).get();
          for(var doc in querySnapshot.docs) {
            PillModel model = PillModel.fromJson(doc.data());
            models.add(model);
          }
        } catch (e) {
          logger.d('[glucocare_log] Failed to select pill models (selectAllPillModels) : $e');
          return [];
        }
      }
    }

    return models;
  }

  static Future<PillModel?>? selectLastPillAlarm() async {
    PillModel? model = null;

      if(await AuthService.userLoginedFa()) {
        String? uid = AuthService.getCurUserUid();
        try {
          String lastColName = await PillColNameRepository.selectLastPillColName();
          if(lastColName != '') {
            var docSnapshot = await _store
                .collection('pill_check').doc(uid)
                .collection(lastColName)
                .orderBy('alarm_time', descending: false)
                .limit(1)
                .get();

            model = await PillModel.fromJson(docSnapshot.docs.first.data());
            logger.d('glucocare_log ${model.alarmTime}');
            return model;
          }
        } catch(e) {
          logger.d('[glucocare_log] Failed to load pill check by colname (selectLastPurseCheck) : $e');
        }
    } else {
        String? kakaoId = await AuthService.getCurUserId();
        try {
          String lastColName = await PillColNameRepository.selectLastPillColName();
          if(lastColName != '') {
            var docSnapshot = await _store
                .collection('pill_check').doc(kakaoId)
                .collection(lastColName)
                .orderBy('alarm_time', descending: false)
                .limit(1)
                .get();

            model = await PillModel.fromJson(docSnapshot.docs.first.data());
            return model;
          }

        } catch(e) {
          logger.d('[glucocare_log] Failed to load pill check by colname (selectLastPurseCheck) : $e');
        }
    }
  }

  static Future<List<PillModel>> selectTodaysPillAlarms() async {
    List<PillModel> todaysAlarm = [];
    String today = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('pill_check').doc(uid).collection(today).get();
      for(var doc in docSnapshot.docs) {
        PillModel model = PillModel.fromJson(doc.data());
        todaysAlarm.add(model);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('pill_check').doc(kakaoId).collection(today).get();
      for(var doc in docSnapshot.docs) {
        PillModel model = PillModel.fromJson(doc.data());
        todaysAlarm.add(model);
      }
    }
    return todaysAlarm;
  }

  static Future<void> deletePillCheckBySaveTime(String saveDate, String saveTime) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      await _store.collection('pill_check').doc(uid).collection(saveDate).doc(saveTime).delete();
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      await _store.collection('pill_check').doc(kakaoId).collection(saveDate).doc(saveTime).delete();
    }
  }
}