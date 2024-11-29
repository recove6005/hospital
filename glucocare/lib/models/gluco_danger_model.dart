import 'package:cloud_firestore/cloud_firestore.dart';

class GlucoDangerModel {
  final String uid;
  final int value;
  final bool danger;
  final Timestamp checkTime;

  GlucoDangerModel({
    required this.uid,
    required this.value,
    required this.danger,
    required this.checkTime
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'value': value,
      'danger': danger,
      'check_time': checkTime,
    };
  }

  factory GlucoDangerModel.fromJson(Map<String, dynamic> json) {
    return GlucoDangerModel(
      uid: json['uid'],
      value: json['value'],
      danger: json['danger'],
      checkTime: json['check_time'],
    );
  }
}