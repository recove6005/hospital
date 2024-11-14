import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/gluco_col_name_model.dart';
import 'package:glucocare/models/purse_col_name_model.dart';
import 'package:glucocare/models/pill_alarm_col_name_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class ColNameRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;
  
  static Future<void> insertAlarmColName(PillAlarmColNameModel model) async {
    String uid = AuthService.getCurUserUid();
    try {
      _store.collection('alarm_name').doc(uid).set(model.toJson());
    } catch (e) {
      logger.e('[gluccare_log] Failed to insert alarm collection name : $e');
    }
  }

  static Future<List<String>> selectAllAlarmColName() async {
    String uid = AuthService.getCurUserUid();
    List<String> pillAlarmColNameList = <String>[];

    var docSnapshot = await _store.collection('alarm_name').where('uid', isEqualTo: uid).orderBy('date', descending: false).get();
    for(var doc in docSnapshot.docs) {
      PillAlarmColNameModel alarmData = PillAlarmColNameModel.fromJson(doc.data());
      pillAlarmColNameList.add(alarmData.date);
    }
    return pillAlarmColNameList;
  }

  static Future<void> insertPurseColName(PurseColNameModel model) async {
    String uid = AuthService.getCurUserUid();
    try {
      _store.collection('purse_name').doc(uid).set(model.toJson());
    } catch (e) {
      logger.e('[glucocare_log] Failed to insert purse check coll name : $e');
    }
  }

  static Future<List<String>> selectAllPurseColName() async {
    String uid = AuthService.getCurUserUid();
    List<String> purseColNameList = <String>[];

    var docSnapshot = await _store.collection('purse_name').where('uid', isEqualTo: uid).orderBy('date', descending: false).get();
    for(var doc in docSnapshot.docs) {
      PurseColNameModel purseData = PurseColNameModel.fromJson(doc.data());
      purseColNameList.add(purseData.date);
    }
    return purseColNameList;
  }

  static Future<void> insertGlucoColName(GlucoColNameModel model) async {
    String uid = AuthService.getCurUserUid();
    try {
      _store.collection('gluco_name').doc(uid).set(model.toJson());
    } catch(e) {
      logger.d('[glucocare_log] Failed to insert gluco col name : $e');
    }
  }

  static Future<List<String>> selectAllGlucoColName() async {
    String uid = AuthService.getCurUserUid();
    List<String> glucoColNameList = <String>[];

    var docSnapshot = await _store.collection('gluco_name').where('uid', isEqualTo: uid).orderBy('date', descending: false).get();
    for(var doc in docSnapshot.docs) {
      GlucoColNameModel glucoData = GlucoColNameModel.fromJson(doc.data());
      glucoColNameList.add(glucoData.date);
    }
    return glucoColNameList;
  }
}