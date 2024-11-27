import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/pill_model.dart';

class AlarmRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertAlarm(PillModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      _store.collection('alarm').doc('$uid ${model.alarmTimeStr}').set(model.toJson());
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      _store.collection('alarm').doc('$kakaoId ${model.alarmTimeStr}').set(model.toJson());
    }
  }

  static Future<List<PillModel>> selectAllAlarm() async {
    List<PillModel> models = [];

    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('alarm').where(
          'uid', isEqualTo: uid).orderBy('alarm_time').get();
      for (var doc in docSnapshot.docs) {
        PillModel model = PillModel.fromJson(doc.data());
        models.add(model);
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('alarm').where(
          'uid', isEqualTo: kakaoId).orderBy('alarm_time').get();
      for (var doc in docSnapshot.docs) {
        PillModel model = PillModel.fromJson(doc.data());
        models.add(model);
      }
    }
    return models;
  }

  static Future<PillModel?> selectSoonerAlarm() async {
    PillModel? model = null;
    String nowTime = DateFormat('HH:mm').format(DateTime.now());

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('alarm')
          .where('uid', isEqualTo: uid)
          .where('alarm_time_str', isGreaterThan: nowTime)
          .orderBy('alarm_time_str', descending: false)
          .limit(1)
          .get();
      model = PillModel.fromJson(docSnapshot.docs.first.data());

    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('alarm')
          .where('uid', isEqualTo: kakaoId)
          .where('alarm_time_str', isGreaterThan: nowTime)
          .orderBy('alarm_time_str', descending: false)
          .limit(1)
          .get();
      model = PillModel.fromJson(docSnapshot.docs.first.data());
    }
    return model;
  }

  static Future<void> deleteAlarm(String alarmTimeStr) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      _store.collection('alarm').doc('$uid $alarmTimeStr').delete();
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      _store.collection('alarm').doc('$kakaoId $alarmTimeStr').delete();
    }
  }
}