import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/purse_colname_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class PurseRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertPurseCheck(PurseModel model) async {
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
  }

  static Future<List<PurseModel>> selectAllPurseCheck() async {
    String? uid = AuthService.getCurUserUid();
    List<PurseModel> models = [];
    List<String> namelist = await PurseColNameRepository.selectAllPurseColName();

    for(var name in namelist) {
      try {
        var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name).get();
        for(var doc in docSnapshot.docs) {
          PurseModel model = PurseModel.fromJson(doc.data());
          models.add(model);
        }
      } catch(e) {
        logger.d('[glucocare_log] Failed to load purse history (selectAllPurseCheck) : $e');
        return [];
      }
    }

    return models;
  }

  static Future<List<PurseModel>> selectPurseByDay(String checkDate) async {
    String? uid = AuthService.getCurUserUid();
    List<PurseModel> models = <PurseModel>[];
    
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
  }

  static Future<PurseModel?>? selectLastPurseCheck() async {
    String? uid = AuthService.getCurUserUid();
    PurseModel? model = null;
    
    try{
      String lastColName = await PurseColNameRepository.selectLastPurseColName();

      if(lastColName != '') {
        var docSnapshot = await _store
            .collection('purse_check').doc(uid)
            .collection(lastColName)
            .orderBy('check_time', descending: true)
            .limit(1)
            .get();

        model = await PurseModel.fromJson(docSnapshot.docs.first.data());
        return model;
      }
    } catch(e) {
      logger.d('[glucocare_log] Failed to load purse check by colname (selectLastPurseCheck) : $e');
    }

    logger.d('[glucocare_log] $model');
    return model;
  }

  static Future<List<FlSpot>> getShrinkData(list) async {
    String? uid = AuthService.getCurUserUid();

    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();
    for(String name in colNames) {
      try{
        var docSnapshot = await _store.collection('purse_check').doc(uid).collection(name)
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

    return chartDatas;
  }

  static Future<List<FlSpot>> getRelaxData(list) async {
    String? uid = AuthService.getCurUserUid();

    List<FlSpot> chartDatas = [];
    double index = 0;

    List<String> colNames = await PurseColNameRepository.selectAllPurseColName();
    colNames = colNames.reversed.toList();

    for(String name in colNames) {
      try {
        var docSnapshot = await _store.collection('purse_check').doc(uid)
            .collection(name)
            .orderBy('check_time', descending: false)
            .get();

        for (var doc in docSnapshot.docs) {
          PurseModel model = PurseModel.fromJson(doc.data());
          chartDatas.add(FlSpot(index, model.relax.toDouble()));

          index++;

          if (chartDatas.length >= 30) return chartDatas;
        }
      } catch (e) {
        logger.e('[glucocare_log] Faeild to load purse chart data (getRelaxData) : $e');
        return chartDatas;
      }
    }

    return chartDatas;
  }
}