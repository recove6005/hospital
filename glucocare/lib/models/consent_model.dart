import 'package:cloud_firestore/cloud_firestore.dart';

class ConsentModel {
  final String uid;
  final Timestamp consentTimestamp;
  final String consentType;
  final Map consentContentSnapshot;
  final String deviceInfo;
  final bool isRevoked;

  ConsentModel({
    required this.uid,
    required this.consentTimestamp,
    required this.consentType,
    required this.consentContentSnapshot,
    required this.deviceInfo,
    required this.isRevoked,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'consent_timestamp': consentTimestamp,
      'consent_type': consentType,
      'consent_content_snapshot': consentContentSnapshot,
      'device_info': deviceInfo,
      'is_revoked': isRevoked,
    };
  }

  factory ConsentModel.fromJson(Map<String, dynamic> json) {
    return ConsentModel(
      uid: json['uid'],
      consentTimestamp: json['consent_timestamp'],
      consentType: json['consent_type'],
      consentContentSnapshot: json['consent_content_snapshot'],
      deviceInfo: json['device_info'],
      isRevoked: json['is_revoked'],
    );
  }
}