import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/pill_model.dart';

class AlarmRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertAlarm(PillModel model) async {
    DateTime dateTime = model.alarmTime.toDate().toLocal().subtract(const Duration(hours: 3));
    String formattedData = DateFormat('yyyy년 MM월 dd일 a h시 m분 s초', 'ko_KR').format(dateTime);
    String date = formattedData + ' UTC+9';

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      _store.collection('alarm').doc('$uid $date').set(model.toJson());
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      _store.collection('alarm').doc('$kakaoId $date').set(model.toJson());
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

  static Future<void> deleteAlarm(Timestamp alarmTime) async {
    logger.d('[glucocare_log] $alarmTime');
    DateTime dateTime = alarmTime.toDate();
    String formattedData = DateFormat('yyyy년 MM월 dd일 a h시 m분 s초', 'ko_KR').format(dateTime);
    String date = formattedData + ' UTC+9';
    logger.d('[glucocare_log] $date');

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      _store.collection('alarm').doc('$uid $date}').delete();
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      _store.collection('alarm').doc('$kakaoId $date}').delete();
    }
  }
}