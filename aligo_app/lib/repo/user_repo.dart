import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';

class UserRepo {
  static final FirebaseFirestore _store = FirebaseFirestore.instance;
  static Logger logger = Logger();

  // 현재 로그인된 사용자 모델 가져오기
  static Future<UserModel?> getCurrentUser() async {
    final email = await AuthService.getCurrentUserEmail();

    try {
      final snap = await _store.collection('users').doc(email).get();
      UserModel userModel = UserModel.fromFirestore(snap.data()!);
      return userModel;
    } catch(e) {
      logger.e('aligo-log: Error parsing user data - $e');
      return null;
    }
  }

  // 현재 로그인된 사용자 어드민 체크
  static Future<bool> checkAdmin() async {
    final email = await AuthService.getCurrentUserEmail();
    bool isAdmin = false;

    try {
      final snap = await _store.collection('users').doc(email).get();
      UserModel userModel = UserModel.fromFirestore(snap.data()!);
      isAdmin = userModel.admin;
    } catch(e) {
      logger.e('aligo-log: Error parsing user data - $e');
    }

    return isAdmin;
  }

  // 신규 사용자 모델 insert
  static Future<void> addUser() async {
    final email = await AuthService.getCurrentUserEmail();
    final uid = await AuthService.getCurrentUserUid();

    UserModel userModel = UserModel(admin: false, email: email, subscribe: '0', uid: uid, verify: false);

    await _store.collection('users').doc(email).set(userModel.toFirestore());
  }

  // 이메일 인증 정보 업데이트
  static Future<void> updateEmailVerify(bool verify) async {
    final email = await AuthService.getCurrentUserEmail();
    try {
      final docRef = await _store.collection('users').doc(email);
      docRef.update({"verify":verify});
    } catch(e) {
      logger.e('aligo-log $e');
    }
  }
}