import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String uid;
  final String kakaoId;
  final String name;
  final String gen;
  final Timestamp birthDate;

  PatientModel({
    required this.uid,
    required this.kakaoId,
    required this.name,
    required this.gen,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'kakao_id': kakaoId,
      'name': name,
      'gen': gen,
      'birth_date': birthDate
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
        uid: json['uid'],
        kakaoId: json['kakao_id'],
        name: json['name'],
        gen: json['gen'],
        birthDate: json['birth_date']
    );
  }
}
