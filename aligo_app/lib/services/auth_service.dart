import 'package:aligo_app/repo/subscribe_repo.dart';
import 'package:aligo_app/repo/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService  {
  static final _auth = FirebaseAuth.instance;
  static Logger logger = Logger();

  // 로그인 상태 확인
  static Future<bool> checkLogin() async {
    try {
      User? user = _auth.currentUser;
      if(user != null) {
        return true;
      } else {
        return false;
      }
    } catch(e) {
      return false;
    }
  }

  // 현재 사용자 uid 가져오기
  static Future<String> getCurrentUserUid() async {
    String? uid = _auth.currentUser?.uid;
    return uid ?? '';
  }

  // 현재 사용자 email 가져오기
  static Future<String> getCurrentUserEmail() async {
    String? email = _auth.currentUser?.email;
    return email ?? '';
  }
  
  // 이메일 인증된 사용자 확인
  static Future<bool> verifyEmail() async {
    bool? isVerifyed = _auth.currentUser?.emailVerified;
    await UserRepo.updateEmailVerify(isVerifyed!);
    return isVerifyed;
  }

  // 인증 이메일 전송
  static Future<void> sendVeifyEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // 로그인 회원가입
  static Future<int> login(email, password) async {
    try {
      // 로그인 시도
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 0;
    } on FirebaseException catch(e) {
      if(e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // 로그인을 시도한 유저가 등록되어 있지 않음
        // 계정 생성
        // 이메일 인증 링크 발송
        try {
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
          await UserRepo.addUser();
          await sendVeifyEmail();

          // 계정 생성 시 구독 정보 초기화
          await SubscribeRepo.initSubscribe();

          return 0;
        } catch(e) {
          logger.e('aligo-log $e');
          return -2;
        }
      }
      else if(e.code == 'firebase_auth/weak-password') {
        return -1;
      }
      else {
        logger.e('aligo-log ${e.code}');
        return -2;
      }
    }
  }

  // 로그아웃
  static Future<void> logout() async {
    await _auth.signOut();
  }
}