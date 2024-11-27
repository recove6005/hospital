import 'package:cloud_firestore/cloud_firestore.dart';

class PillModel {
  final String uid;
  final String saveDate;
  final String saveTime;
  final Timestamp alarmTime;
  final String alarmTimeStr;
  final String state;

  PillModel({
    required this.uid,
    required this.saveDate,
    required this.saveTime,
    required this.alarmTime,
    required this.alarmTimeStr,
    required this.state,
  });

 Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'save_date': saveDate,
      'save_time': saveTime,
      'alarm_time': alarmTime,
      'alarm_time_str': alarmTimeStr,
      'state': state,
    };
  }

  factory PillModel.fromJson(Map<String, dynamic> json) {
    return PillModel(
        uid: json['uid'],
        saveDate: json['save_date'],
        saveTime: json['save_time'],
        alarmTime: json['alarm_time'],
        alarmTimeStr: json['alarm_time_str'],
        state: json['state'],
    );
  }
}