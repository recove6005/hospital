import 'package:cloud_firestore/cloud_firestore.dart';

class PurseDangerModel {
  final String uid;
  final int shrink;
  final int relax;
  final bool shrinkDanger;
  final bool relaxDanger;
  final Timestamp checkTime;

  PurseDangerModel({
    required this.uid,
    required this.shrink,
    required this.relax,
    required this.shrinkDanger,
    required this.relaxDanger,
    required this.checkTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'shrink': shrink,
      'relax' : relax,
      'shrink_danger': shrinkDanger,
      'relax_danger': relaxDanger,
      'check_time': checkTime,
    };
  }

  factory PurseDangerModel.fromJson(Map<String, dynamic> json) {
    return PurseDangerModel(
      uid: json['uid'],
      shrink: json['shrink'],
      relax: json['relax'],
      shrinkDanger: json['shrink_danger'],
      relaxDanger: json['relax_danger'],
      checkTime: json['check_time'],
    );
  }
}

