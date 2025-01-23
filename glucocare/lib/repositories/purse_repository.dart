import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/purse_colname_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PurseRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPurseCheck(PurseModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        await _store
            .collection('purse_check').doc(uid)
            .collection(model.checkDate).doc(model.checkTime)
            .set(model.toJson());
        logger.e('[glucocare_log] PurseCheck field was inserted.');
      } catch(e) {
        logger.e('[glucocare_log] Failed to insert PurseCheck field : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        await _store
            .collection('purse_check').doc(kakaoId)
            .collection(model.checkDate).doc(model.checkTime)
            .set(model.toJson());
        logger.e('[glucocare_log] PurseCheck field was inserted.');
      } catch(e) {
        logger.e('[glucocare_log] Failed to insert PurseCheck field : $e');
      }
    }
  }

  static Future<List<PurseModel>> selectAllPurseCheck() async {
    List<PurseModel> models = [];
    List<String> namelist = await PurseColNameRepository.selectAllPurseColName();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(var name in namelist) {
        try {
          var docSnapshot = await _store.collection('purse_check')
              .doc(uid)
              .collection(name)
              .get();
          for (var doc in docSnapshot.docs) {
            PurseModel model = PurseModel.fromJson(doc.data());
            models.add(model);
          }
        } catch (e) {
          logger.d(
              '[glucocare_log] Failed to load purse history (selectAllPurseCheck) : $e');
          return [];
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(var name in namelist) {
        try {
          var docSnapshot = await _store.collection('purse_check')
              .doc(kakaoId)
              .collection(name)
              .get();
          for (var doc in docSnapshot.docs) {
            PurseModel model = PurseModel.fromJson(doc.data());
            models.add(model);
          }
        } catch (e) {
          logger.d(
              '[glucocare_log] Failed to load purse history (selectAllPurseCheck) : $e');
          return [];
        }
      }
    }
    return models;
  }

  static Future<List<PurseModel>> selectAllPurseCheckBySpecificUid(String uid) async {
    List<PurseModel> models = [];
    List<String> namelist = await PurseColNameRepository.selectAllPurseColNameBySpecificUid(uid);
    for(var name in namelist) {
      try {
        var docSnapshot = await _store.collection('purse_check')
            .doc(uid)
            .collection(name)
            .get();
        for (var doc in docSnapshot.docs) {
          PurseModel model = PurseModel.fromJson(doc.data());
          models.add(model);
        }
      } catch (e) {
        logger.d(
            '[glucocare_log] Failed to load purse history (selectAllPurseCheck) : $e');
      }
    }
    return models;
  }

  static Future<List<PurseModel>> selectPurseByDay(String checkDate) async {
    List<PurseModel> models = <PurseModel>[];

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('purse_check').doc(uid).collection(checkDate).get();
      try {
        for(var doc in docSnapshot.docs) {
          PurseModel purseModel = PurseModel.fromJson(doc.data());
          models.add(purseModel);
        }

        return models;
      } catch(e) {
        logger.e('[glucocare_log] Failed to load purse history by day (selectPurseByDay) : $e');
        return [];
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('purse_check').doc(kakaoId).collection(checkDate).get();
      try {
        for(var doc in docSnapshot.docs) {
          PurseModel purseModel = PurseModel.fromJson(doc.data());
          models.add(purseModel);
        }

        return models;
      } catch(e) {
        logger.e('[glucocare_log] Failed to load purse history by day (selectPurseByDay) : $e');
        return [];
      }
    }
  }

  static Future<PurseModel?>? selectLastPurseCheck() async {
    PurseModel? model;

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try{
        String lastColName = await PurseColNameRepository.selectLastPurseColName();

        if(lastColName != '') {
          var docSnapshot = await _store
              .collection('purse_check').doc(uid)
              .collection(lastColName)
              .orderBy('check_time', descending: true)
              .limit(1)
              .get();

          model = PurseModel.fromJson(docSnapshot.docs.first.data());
          return model;
        }
      } catch(e) {
        logger.d('[glucocare_log] Failed to load purse check by colname (selectLastPurseCheck) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try{
        String lastColName = await PurseColNameRepository.selectLastPurseColName();

        if(lastColName != '') {
          var docSnapshot = await _store
              .collection('purse_check').doc(kakaoId)
              .collection(lastColName)
              .orderBy('check_time', descending: true)
              .limit(1)
              .get();

          model = PurseModel.fromJson(docSnapshot.docs.first.data());
          return model;
        }
      } catch(e) {
        logger.d('[glucocare_log] Failed to load purse check by colname (selectLastPurseCheck) : $e');
      }
    }

    return model;
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

  // shrink 차트 7일 이내
  static Future<List<FlSpot>> getShrinkData(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // shrink 차트 30일 이내
  static Future<List<FlSpot>> getShrinkDataByThirty(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // shrink 차트 90일 이내
  static Future<List<FlSpot>> getShrinkDataByNinety(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // shrink 차트 1일 이내
  static Future<List<FlSpot>> getShrinkDataByDay(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 1)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));
              index++;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 1)) {
          try{
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId).collection(name)
                .orderBy('check_time', descending: false).get();

            for(var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.shrink.toDouble()));
              list.add(name.substring(10,12));

              index++;

              if(chartDatas.length >= 30) return chartDatas;
            }
          } catch(e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getShrinkData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // relax 차트 7일 이내
  static Future<List<FlSpot>> getRelaxData(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();
            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));

              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 7)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId)
                .collection(name).orderBy('check_time', descending: false).get();

            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));
              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // relax 차트 30일 이내
  static Future<List<FlSpot>> getRelaxDataByThirty(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 30)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();
            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));

              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 30)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId)
                .collection(name).orderBy('check_time', descending: false).get();

            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));
              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // relax 차트 90일 이내
  static Future<List<FlSpot>> getRelaxDataByNinety(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 30)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();
            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));

              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 30)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId)
                .collection(name).orderBy('check_time', descending: false).get();

            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));
              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  // relax 차트 1일 이내
  static Future<List<FlSpot>> getRelaxDataByDay(list) async {
    List<FlSpot> chartDatas = [];
    double index = 0;
    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      for(String name in colNames) {
        if(_getPast(name, 1)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
                .orderBy('check_time', descending: false).get();
            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));

              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      for(String name in colNames) {
        if(_getPast(name, 1)) {
          try {
            var docSnapshot = await _store.collection('purse_check').doc(kakaoId)
                .collection(name).orderBy('check_time', descending: false).get();

            for (var doc in docSnapshot.docs) {
              PurseModel model = PurseModel.fromJson(doc.data());
              chartDatas.add(FlSpot(index, model.relax.toDouble()));
              index++;
            }
          } catch (e) {
            logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
            return chartDatas;
          }
        }
      }
    }
    return chartDatas;
  }

  static Future<void> deletePurseCheck() async {
    List<PurseModel> list = await selectAllPurseCheck();

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      if(uid != null) {
        for(PurseModel item in list) {
          _store.collection('purse_check').doc(uid).collection(item.checkDate).doc(item.checkTime).delete();
        }
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      if(kakaoId != null) {
        for(PurseModel item in list) {
          _store.collection('purse_check').doc(kakaoId).collection(item.checkDate).doc(item.checkTime).delete();
        }
      }
    }
  }
}