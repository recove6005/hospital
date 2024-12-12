import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glucocare/models/reservation_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class ReservationRepository {
  static Logger logger = Logger();
  static final FirebaseFirestore _store = FirebaseFirestore.instance;

  static Future<void> insertReservationBySpecificUid(ReservationModel model) async {
    try {
      await _store.collection('reservation').doc('${model.uid} ${model.reservationDate}').set(model.toJson());
    } catch(e) {
      logger.e('[glucocare_log] Failed reservation. : $e');
    }
  }

  static Future<List<ReservationModel>> selectAllReservations() async {
    List<ReservationModel> list = [];
    try {
      var docSnapshot = await _store.collection('reservation').orderBy('reservation_date').get();
      for(var doc in docSnapshot.docs) {
        ReservationModel model = ReservationModel.fromJson(doc.data());
        list.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load reservations. : $e');
    }

    return list;
  }

  static Future<List<ReservationModel>> selectAllReservationsBySpecificUid(String uid) async {
    List<ReservationModel> list = [];

    try {
      var docSnapshot = await _store.collection('reservation').where('uid', isEqualTo: uid).orderBy('reservation_date').get();
      for(var doc in docSnapshot.docs) {
        ReservationModel model = ReservationModel.fromJson(doc.data());
        list.add(model);
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load specific user\'s reservations. : $e');
    }

    return list;
  }

  static Future<List<ReservationModel>> selectAllReservationsByCurUid() async {
    List<ReservationModel> list = [];

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        var docSnapshot = await _store.collection('reservation').where('uid', isEqualTo: uid).orderBy('reservation_date').get();
        for(var doc in docSnapshot.docs) {
          ReservationModel model = ReservationModel.fromJson(doc.data());
          list.add(model);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load current user\'s reservations. : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        var docSnapshot = await _store.collection('reservation').where('uid', isEqualTo: kakaoId).orderBy('reservation_date').get();
        for(var doc in docSnapshot.docs) {
          ReservationModel model = ReservationModel.fromJson(doc.data());
          list.add(model);
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to load current user\'s reservations. : $e');
      }
    }
    return list;
  }

  static Future<void> deleteReservationByUid(String uid, Timestamp reservationDate) async {
    try {
      await _store.collection('reservation').doc('${uid} ${reservationDate}').delete();
    } catch(e) {
      logger.e('[gluccoare_log] Failed to delete reservation. : $e');
    }
  }
}