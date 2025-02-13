import 'package:aligo_app/model/subscribe_model.dart';
import 'package:aligo_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class SubscribeRepo {
  static final FirebaseFirestore _store = FirebaseFirestore.instance;
  static final Logger logger = Logger();

  // 구독 정보 초기화 type=0
  static Future<void> initSubscribe() async {
    String uid = await AuthService.getCurrentUserUid();
    String email = await AuthService.getCurrentUserEmail();

    SubscribeModel model = SubscribeModel(
        blog: 0,
        discount: 0,
        draft: 0,
        homepage: 0,
        logo: 0,
        signage: 0,
        email: email,
        uid: uid,
        type: '0',
        instagram: 0,
        naverplace: 0,
        banner: 0,
        video: 0,
    );
    
    await _store.collection('subscribes').doc(uid).set(model.toFirestore());
  }

  // null 반환
  static Future<SubscribeModel?> getSubscribeInfo() async {
    String email = await AuthService.getCurrentUserEmail();
    try {
      var snap = await _store.collection('subscribes').doc(email).get();
      if(snap.exists) {
        SubscribeModel model = SubscribeModel.fromFirestore(snap.data()!);
        return model;
      }
    } catch(e) {
      logger.e('aligo-log Failed to select subscribe info. $e.');
    }
    return null;
  }

  // 구독권 사용
  static Future<bool> getpayWithSubscribe(String category) async {
    String? email = await AuthService.getCurrentUserEmail();
    try {
      var snap = await _store.collection('subscribes').doc(email).get();
      if(snap.exists) {
        var count = snap.get(category);
        if(count > 0) {
          await _store.collection('subscribes').doc(email).update({ category : count - 1});
          return true;
        }
      }
    } catch(e) {
      logger.e('aligo-log Failed to pay with subscribe. $e');
    }

    return false;
  }
}