import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class AdminRequestImageStorage {
  static final Logger logger = Logger();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<void> uploadFile(File file) async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        String path = 'admin_request/$uid/${uid}_admin_request.jpg';
        final ref = _storage.ref().child(path);
        await ref.putFile(file);
      } catch(e) {
        logger.e('[glucocare_log] Failed to upload image file (AdminRequestImageStorage.uploadFile) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        String path = 'admin_request/$kakaoId/${DateTime.now().toIso8601String()}';
        final ref = _storage.ref().child(path);
        await ref.putFile(file);
      } catch(e) {
        logger.e('[glucocare_log] Failed to upload image file (AdminRequestImageStorage.uploadFile) : $e');
      }
    }
  }

  static Future<String> downloadFileBySpecificUid(String uid) async {
    String imageUrl = '';
    try {
      String path = 'admin_request/$uid/${uid}_admin_request.jpg';
      final ref = _storage.ref().child(path);
      imageUrl = await ref.getDownloadURL();
    } catch(e) {
      logger.d('[glucocare_log] Failed to download image url. : $e');
    }

    return imageUrl;
  }

  static Future<void> deleteFile() async {
    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      try {
        String folderPath = 'admin_request/$uid';
        final ref = _storage.ref().child(folderPath);
        final fileRefs = await ref.listAll();
        for(var fileRef in fileRefs.items) {
          await fileRef.delete();
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to upload image file (AdminRequestImageStorage.uploadFile) : $e');
      }
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      try {
        String folderPath = 'admin_request/$kakaoId';
        final ref = _storage.ref().child(folderPath);
        final fileRefs = await ref.listAll();
        for(var fileRef in fileRefs.items) {
          await fileRef.delete();
        }
      } catch(e) {
        logger.e('[glucocare_log] Failed to upload image file (AdminRequestImageStorage.uploadFile) : $e');
      }
    }
  }

  static Future<void> deleteFileBySpecificUid(String uid) async {
    try {
      String folderPath = 'admin_request/$uid';
      final ref = _storage.ref().child(folderPath);
      final fileRefs = await ref.listAll();
      for (var fileRef in fileRefs.items) {
        await fileRef.delete();
      }
    } catch (e) {
      logger.e(
          '[glucocare_log] Failed to upload image file (AdminRequestImageStorage.uploadFile) : $e');
    }
  }
}