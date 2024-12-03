import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/notice_board_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class NoticeBoardRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertBoard(NoticeBoardModel model) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      _store.collection('notice_board').doc('$uid ${Timestamp.now()}').set(model.toJson());
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      _store.collection('notice_board').doc(kakaoId).set(model.toJson());
    }
  }

  static Future<List<NoticeBoardModel>> selectAllNoticies() async {
    List<NoticeBoardModel> models = [];
    try {
      var docSnapshot = await _store.collection('notice_board').orderBy('date_time', descending: true).get();
      for(var doc in docSnapshot.docs) {
        NoticeBoardModel model = NoticeBoardModel.fromJson(doc.data());
        models.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load Noticies : $e');
    }
    return models;
  }
}