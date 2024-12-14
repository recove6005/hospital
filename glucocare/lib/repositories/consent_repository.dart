import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:glucocare/models/consent_model.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class ConsentRepository {
  static Logger logger = Logger();
  static FirebaseFirestore _store = FirebaseFirestore.instance;
  static DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();


  static Future<void> createConsetnForm() async {
    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('consent').doc(uid).get();

      if (!docSnapshot.exists && uid != null) {
        // document가 존재하지 않음, 신규 동의 - 파이어베이스 인증
        String jsonString = await rootBundle.loadString(
            'assets/data/consent.json');
        Map<String, dynamic> consentContentsnapshot = json.decode(jsonString);
        ConsentModel consent = ConsentModel(
            uid: uid,
            consentTimestamp: Timestamp.now(),
            consentType: 'personal_data_collection_usage',
            consentContentSnapshot: consentContentsnapshot,
            deviceInfo: deviceInfoPlugin.deviceInfo.toString(),
            isRevoked: false
        );

        _store.collection('consent').doc(uid).set(consent.toJson());
      }
    } else {
      // document가 존재하지 않음, 신규 동의 - 카카오톡로그인
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('consent').doc(kakaoId).get();
      if (!docSnapshot.exists && kakaoId != null) {
        // 신규 동의 - 파이어베이스 인증
        String jsonString = await rootBundle.loadString(
            'assets/data/consent.json');
        Map<String, dynamic> consentContentsnapshot = json.decode(jsonString);
        ConsentModel consent = ConsentModel(
            uid: kakaoId,
            consentTimestamp: Timestamp.now(),
            consentType: 'personal_data_collection_usage',
            consentContentSnapshot: consentContentsnapshot,
            deviceInfo: deviceInfoPlugin.deviceInfo.toString(),
            isRevoked: false
        );

        _store.collection('consent').doc(kakaoId).set(consent.toJson());
      }
    }
  }

  static Future<bool> checkCurUserConsent() async {
    createConsetnForm(); // 신규 동의 시 모델 생성

    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('consent').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        ConsentModel model = ConsentModel.fromJson(docSnapshot.data()!);
        bool revoke = model.isRevoked;
        return revoke;
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('consent').doc(kakaoId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        ConsentModel model = ConsentModel.fromJson(docSnapshot.data()!);
        bool revoke = model.isRevoked;
        return revoke;
      }
    }
    return false;
  }

  static Future<void> permitCurUserConsent() async {
    if (await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      var docSnapshot = await _store.collection('consent').doc(uid).get();
      if (docSnapshot.exists && uid != null) {
        ConsentModel model = ConsentModel.fromJson(docSnapshot.data()!);
        ConsentModel newModel = ConsentModel(
          uid: model.uid,
          consentTimestamp: model.consentTimestamp,
          consentType: model.consentType,
          consentContentSnapshot: model.consentContentSnapshot,
          deviceInfo: model.deviceInfo,
          isRevoked: true,
        );
        await _store.collection('consent').doc(uid).set(newModel.toJson());
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      var docSnapshot = await _store.collection('consent').doc(kakaoId).get();
      if (docSnapshot.exists && kakaoId != null) {
        ConsentModel model = ConsentModel.fromJson(docSnapshot.data()!);
        ConsentModel newModel = ConsentModel(
          uid: model.uid,
          consentTimestamp: model.consentTimestamp,
          consentType: model.consentType,
          consentContentSnapshot: model.consentContentSnapshot,
          deviceInfo: model.deviceInfo,
          isRevoked: true,
        );
        await _store.collection('consent').doc(kakaoId).set(newModel.toJson());
      }
    }
  }
}