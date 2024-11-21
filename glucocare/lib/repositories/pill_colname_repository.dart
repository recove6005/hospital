import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/pill_alarm_col_name_model.dart';
import '../services/auth_service.dart';

class PillColNameRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertAlarmColName(PillAlarmColNameModel model) async {
    String? uid = AuthService.getCurUserUid();
    try {
      _store.collection('alarm_name').doc('${model.date} $uid').set(model.toJson());
    } catch (e) {
      logger.e('[gluccare_log] Failed to insert alarm collection name (PillColNameRepository) : $e');
    }
  }

  static Future<List<String>> selectAllAlarmColName() async {
    String? uid = AuthService.getCurUserUid();
    List<String> pillAlarmColNameList = <String>[];

    var docSnapshot = await _store.collection('alarm_name').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
    for(var doc in docSnapshot.docs) {
      PillAlarmColNameModel alarmData = PillAlarmColNameModel.fromJson(doc.data());
      pillAlarmColNameList.add(alarmData.date);
    }
    return pillAlarmColNameList;
  }
}