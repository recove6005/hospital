import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/purse_col_name_model.dart';
import '../services/auth_service.dart';

class PurseColNameRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPurseColName(PurseColNameModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        _store.collection('purse_name').doc('${model.date} $uid').set(model.toJson());
      } catch (e) {
        logger.e('[glucocare_log] Failed to insert purse check coll name (insertPurseColName) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        _store.collection('purse_name').doc('${model.date} $kakaoId').set(model.toJson());
      } catch (e) {
        logger.e('[glucocare_log] Failed to insert purse check coll name (insertPurseColName) : $e');
      }
    }
  }

  static Future<List<String>> selectAllPurseColName() async {
    List<String> purseColNameList = <String>[];

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();

      var docSnapshot = await _store.collection('purse_name').where('uid', isEqualTo: uid).orderBy('date', descending: true).get();
      for(var doc in docSnapshot.docs) {
        PurseColNameModel purseData = PurseColNameModel.fromJson(doc.data());
        purseColNameList.add(purseData.date);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('purse_name').where('uid', isEqualTo: kakaoId).orderBy('date', descending: true).get();
      for(var doc in docSnapshot.docs) {
        PurseColNameModel purseData = PurseColNameModel.fromJson(doc.data());
        purseColNameList.add(purseData.date);
      }
    }

    return purseColNameList;
  }

  static Future<String> selectPurseColNameNyDay(String docName) async {
    String purseColName = '';

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('purse_name').where('uid', isEqualTo: uid).get();
      for(var doc in docSnapshot.docs) {
        PurseColNameModel purseDate = PurseColNameModel.fromJson(doc.data());
        if(purseDate.date == docName) purseColName = purseDate.date;
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('purse_name').where('uid', isEqualTo: kakaoId).get();
      for(var doc in docSnapshot.docs) {
        PurseColNameModel purseDate = PurseColNameModel.fromJson(doc.data());
        if(purseDate.date == docName) purseColName = purseDate.date;
      }
    }

    return purseColName;
  }

  static Future<String> selectLastPurseColName() async {
    String lastPurseColName = '';

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        var docSnapshot = await _store.collection('purse_name')
            .where('uid', isEqualTo: uid)
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if(docSnapshot.docs.isNotEmpty) lastPurseColName = PurseColNameModel.fromJson(docSnapshot.docs.first.data()).date;

      } catch(e) {
        logger.e('[glucocare_log] Failed to load purse col name (selectLastPurseColName) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        var docSnapshot = await _store.collection('purse_name')
            .where('uid', isEqualTo: kakaoId)
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if(docSnapshot.docs.isNotEmpty) lastPurseColName = PurseColNameModel.fromJson(docSnapshot.docs.first.data()).date;

      } catch(e) {
        logger.e('[glucocare_log] Failed to load purse col name (selectLastPurseColName) : $e');
      }
    }
    return lastPurseColName;
  }
}