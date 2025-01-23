import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'gluco_colname_repository.dart';

class GlucoRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertGlucoCheck(GlucoModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        await _store
            .collection('gluco_check').doc(uid)
            .collection(model.checkDate).doc(model.checkTime)
            .set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to insert GlucoCheck field (insertGlucoCheck) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      logger.d('[glucocare_log] user num: $kakaoId');
      try {
        await _store
            .collection('gluco_check').doc(kakaoId.toString())
            .collection(model.checkDate).doc(model.checkTime)
            .set(model.toJson());
      } catch(e) {
        logger.e('[glucocare_log] Failed to insert GlucoCheck field (insertGlucoCheck) : $e');
      }
    }
  }

  static Future<List<GlucoModel>> selectAllGlucoCheck() async {
    List<GlucoModel> models = <GlucoModel>[];
    List<String> namelist = await GlucoColNameRepository.selectAllGlucoColName();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(var name in namelist) {
        try {
          var docSnapshot = await _store.collection('gluco_check').doc(uid)
              .collection(name).get();
          for(var doc in docSnapshot.docs) {
            GlucoModel model = GlucoModel.fromJson(doc.data());
            models.add(model);
          }
        } catch(e) {
          logger.e('[glucocare_log] Failed to load gluco check history (selectAllGlucoCheck) $e');
          return [];
        }
      }
    } else {
      var kakaoId = AuthService.getCurUserId();
      for(var name in namelist) {
            try {
              var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString())
                  .collection(name).get();
          for(var doc in docSnapshot.docs) {
            GlucoModel model = GlucoModel.fromJson(doc.data());
            models.add(model);
          }
        } catch(e) {
          logger.e('[glucocare_log] Failed to load gluco check history (selectAllGlucoCheck) $e');
          return [];
        }
      }
    }

    return models;
  }

  static Future<List<GlucoModel>> selectAllGlucoCheckBySpecificUid(String uid) async {
    List<GlucoModel> models = <GlucoModel>[];
    List<String> namelist = await GlucoColNameRepository.selectAllGlucoColNameBySpecificUid(uid);
    for(var name in namelist) {
      try {
        var docSnapshot = await _store.collection('gluco_check').doc(uid)
            .collection(name).get();
        for(var doc in docSnapshot.docs) {
          GlucoModel model = GlucoModel.fromJson(doc.data());
          models.add(model);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco check history (selectAllGlucoCheck) $e');
      }
    }

    return models;
  }

  static Future<GlucoModel?>? selectGlucoByColName(String colName) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        var docSnapshot = await _store.collection('gluco_check').doc(uid).collection(colName)
            .orderBy('check_time', descending: true).limit(1).get();
        GlucoModel model = GlucoModel.fromJson(docSnapshot.docs.first.data());
        return model;
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco check history (selectGlucoByColName) $e');
        return null;
      }
    } else {
      var kakaoId = AuthService.getCurUserId();
      try {
        var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString()).collection(colName)
            .orderBy('check_time', descending: true).limit(1).get();
        GlucoModel model = GlucoModel.fromJson(docSnapshot.docs.first.data());
        return model;
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco check history (selectGlucoByColName) $e');
        return null;
      }
    }
  }

  static Future<List<GlucoModel>> selectGlucoByDay(String checkDate) async {
    List<GlucoModel> models = <GlucoModel>[];

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try{
        var docSnapshot = await _store.collection('gluco_check').doc(uid).collection(checkDate).get();

        for(var doc in docSnapshot.docs) {
          GlucoModel model = GlucoModel.fromJson(doc.data());
          models.add(model);
        }

        return models;
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco history by day (selectGlucoByDay) : $e');
        return [];
      }
    } else {
       String? kakaoId = await AuthService.getCurUserId();
      try{
        var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString()).collection(checkDate).get();

        for(var doc in docSnapshot.docs) {
          GlucoModel model = GlucoModel.fromJson(doc.data());
          models.add(model);
        }

        return models;
      } catch(e) {
        logger.e('[glucocare_log] Failed to load gluco history by day (selectGlucoByDay) : $e');
        return [];
      }
    }
  }

  static bool _getPast(String name, int past) {
    DateFormat format = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');
    DateTime parsedDate = format.parse(name);
    DateTime today = DateTime.now();
    int differenceInDays = today.difference(parsedDate).inDays;

    if(past == 1) {
      if(differenceInDays <= 1) return true;
    }
    else if(past == 7) {
      if(differenceInDays <= 7) return true;
    }
    else if(past == 30) {
      if(differenceInDays <= 30) return true;
    }
    else if(past == 90) {
      if(differenceInDays <= 90) return true;
    }

    return false;
  }

  static Future<List<FlSpot>> getGlucoData(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await GlucoColNameRepository.selectAllGlucoColName();
    colNames = colNames.reversed.toList();

    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for (String name in colNames) {
        if(_getPast(name, 7)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(uid)
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for (String name in colNames) {
        if(_getPast(name, 7)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString())
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    }
    return chartDatas;
  }

  static Future<List<FlSpot>> getGlucoDataByDay(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await GlucoColNameRepository.selectAllGlucoColName();
    colNames = colNames.reversed.toList();

    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for (String name in colNames) {
        if(_getPast(name, 1)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(uid)
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for (String name in colNames) {
        if(_getPast(name, 1)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString())
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    }
    return chartDatas;
  }

  static Future<List<FlSpot>> getGlucoDataByThirty(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await GlucoColNameRepository.selectAllGlucoColName();
    colNames = colNames.reversed.toList();

    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for (String name in colNames) {
        if(_getPast(name, 30)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(uid)
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for (String name in colNames) {
        if(_getPast(name, 30)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString())
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    }
    return chartDatas;
  }

  static Future<List<FlSpot>> getGlucoDataByNinety(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await GlucoColNameRepository.selectAllGlucoColName();
    colNames = colNames.reversed.toList();

    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for (String name in colNames) {
        if(_getPast(name, 90)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(uid)
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for (String name in colNames) {
        if(_getPast(name, 90)) {
          try {
            var docSnapshot = await _store.collection('gluco_check').doc(kakaoId.toString())
                .collection(name)
                .orderBy('check_time', descending: false)
                .get();
            for (var doc in docSnapshot.docs) {
              GlucoModel model = GlucoModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.value.toDouble()));
              list.add(name.substring(10, 12));

              index++;

              if (chartDatas.length >= 30) return chartDatas;
            }
          } catch (e) {
            logger.e(
                '[glucocare_log] Failed to load gluco chart data (getGlucoData) : $e');
          }
        }
      }
    }
    return chartDatas;
  }

  static Future<GlucoModel?> selectLastGlucoCheck() async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try{
        String lastColName = await GlucoColNameRepository.selectLastGlucoColName();

        if(lastColName != '') {
          try {
            var docSnapshot = await _store
                .collection('gluco_check').doc(uid)
                .collection(lastColName)
                .orderBy('check_time', descending: true)
                .limit(1)
                .get();

            GlucoModel model = GlucoModel.fromJson(docSnapshot.docs.first.data());
            return model;
          } catch(e) {
            logger.d('[glucocare_log] Failed to load gluco check by colname (selectLastGlucoCheck if1) : $e');
          }
        } else {
          logger.d('[glucocare_log] Failed to load gluco check by colname (selectLastGlucoCheck if1)');
        }
      } catch(e) {
        logger.d('[glucocare_log] Failed to load gluco check by colname (selectLastGlucoCheck if2)  : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      logger.d('[glucocare_log] user num: $kakaoId');

      try{
        String lastColName = await GlucoColNameRepository.selectLastGlucoColName();

        if(lastColName != '') {
          try {
            var docSnapshot = await _store
                .collection('gluco_check').doc(kakaoId.toString())
                .collection(lastColName)
                .orderBy('check_time', descending: true)
                .limit(1)
                .get();

            GlucoModel model = GlucoModel.fromJson(docSnapshot.docs.first.data());
            return model;
          } catch(e) {
            logger.d('[glucocare_log] Failed to load gluco check by colname (selectLastGlucoCheck if1) : $e');
          }
        }
      } catch(e) {
        logger.d('[glucocare_log] Failed to load gluco check by colname (selectLastGlucoCheck if2)  : $e');
      }
    }

    return null;
  }

  static Future<void> deleteGlucoCheck() async {
    List<GlucoModel> list = await selectAllGlucoCheck();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      if(uid != null) {
        for(GlucoModel item in list) {
          _store.collection('gluco_check').doc(uid).collection(item.checkDate).doc(item.checkTime).delete();
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      if(kakaoId != null) {
        for(GlucoModel item in list) {
          _store.collection('gluco_check').doc(kakaoId).collection(item.checkDate).doc(item.checkTime).delete();
        }
      }
    }
  }
}