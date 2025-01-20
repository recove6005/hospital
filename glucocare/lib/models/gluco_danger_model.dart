import 'package:cloud_firestore/cloud_firestore.dart';

class GlucoDangerModel {
  final String uid;
  final int value;
  final bool danger;
  final Timestamp checkTime;
  final String checkTimeName;

  GlucoDangerModel({
    required this.uid,
    required this.value,
    required this.danger,
    required this.checkTime,
    required this.checkTimeName,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'value': value,
      'danger': danger,
      'check_time': checkTime,
      'check_time_name': checkTimeName,
    };
  }

  factory GlucoDangerModel.fromJson(Map<String, dynamic> json) {
    return GlucoDangerModel(
      uid: json['uid'],
      value: json['value'],
      danger: json['danger'],
      checkTime: json['check_time'],
      checkTimeName: json['check_time_name'],
    );
  }
}