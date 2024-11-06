
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String name;
  final String id; // 전화번호 또는 카카오톡 id토큰
  final String gen;
  final Timestamp birthDate;

  PatientModel({
    required this.name,
    required this.id,
    required this.gen,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': id,
      'gen': gen,
      'birth_date': birthDate
    };
  }
}