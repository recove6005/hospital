import 'package:cloud_firestore/cloud_firestore.dart';

class PillModel {
  final String pillCategory;
  final String eatTime;
  final String saveDate;
  final String saveTime;
  final Timestamp alarmTime;

  PillModel({
    required this.pillCategory,
    required this.eatTime,
    required this.saveDate,
    required this.saveTime,
    required this.alarmTime,
  });

 Map<String, dynamic> toJson() {
    return {
      'pill_category': pillCategory,
      'eat_time': eatTime,
      'save_date': saveDate,
      'save_time': saveTime,
      'alarm_time': alarmTime
    };
  }

  factory PillModel.fromJson(Map<String, dynamic> json) {
    return PillModel(
        pillCategory: json['pill_category'],
        eatTime: json['eat_time'],
        saveDate: json['save_date'],
        saveTime: json['save_time'],
        alarmTime: json['alarm_time'],
    );
  }
}