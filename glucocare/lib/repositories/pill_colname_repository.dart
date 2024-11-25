import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/pill_col_name_model.dart';
import '../services/auth_service.dart';

class PillColNameRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertAlarmColName(PillColNameModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        _store.collection('pill_name').doc('${model.date} $uid').set(model.toJson());
      } catch (e) {
        logger.e('[gluccare_log] Failed to insert alarm collection name (PillColNameRepository) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        _store.collection('pill_name').doc('${model.date} $kakaoId').set(model.toJson());
      } catch (e) {
        logger.e('[gluccare_log] Failed to insert alarm collection name (PillColNameRepository) : $e');
      }
    }
  }

  static Future<List<String>> selectAllAlarmColName() async {
    List<String> pillAlarmColNameList = <String>[];

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('pill_name').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
      for(var doc in docSnapshot.docs) {
        PillColNameModel alarmData = PillColNameModel.fromJson(doc.data());
        pillAlarmColNameList.add(alarmData.date);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('pill_name').where('uid', isEqualTo: kakaoId).orderBy('date', descending: true).get();
      for(var doc in docSnapshot.docs) {
        PillColNameModel alarmData = PillColNameModel.fromJson(doc.data());
        pillAlarmColNameList.add(alarmData.date);
      }
    }

    return pillAlarmColNameList;
  }

  static Future<String> selectLastPillColName() async {
    String lastPillColName = '';

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        var docSnapshot = await _store.collection('pill_name')
            .where('uid', isEqualTo: uid)
            .orderBy('date', descending: false)
            .limit(1)
            .get();

        if(docSnapshot.docs.isNotEmpty) lastPillColName =
            PillColNameModel.fromJson(docSnapshot.docs.first.data()).date;

      } catch(e) {
        logger.e('[glucocare_log] Failed to load pill col name (selectLastPillColName) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        var docSnapshot = await _store.collection('pill_name')
            .where('uid', isEqualTo: kakaoId)
            .orderBy('date', descending: false)
            .limit(1)
            .get();

        if(docSnapshot.docs.isNotEmpty) lastPillColName =
            PillColNameModel.fromJson(docSnapshot.docs.first.data()).date;

      } catch(e) {
        logger.e('[glucocare_log] Failed to load pill col name (selectLastPillColName) : $e');
      }
    }

    return lastPillColName;
  }
}