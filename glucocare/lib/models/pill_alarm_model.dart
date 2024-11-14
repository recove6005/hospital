import 'package:cloud_firestore/cloud_firestore.dart';

class PillAlarmModel {
  final String saveDate;
  final String saveTime;
  final Timestamp alarmTime;

  PillAlarmModel({
    required this.saveDate,
    required this.saveTime,
    required this.alarmTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'save_date': saveDate,
      'save_time': saveTime,
      'alarm_time': alarmTime,
    };
  }

  factory PillAlarmModel.fromJson(Map<String, dynamic> json) {
    return PillAlarmModel(
        saveDate: json['save_date'],
        saveTime: json['save_time'],
        alarmTime: json['alarm_time'],
    );
  }
}