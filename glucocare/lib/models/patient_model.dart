
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String name;
  final String gen;
  final Timestamp birthDate;

  PatientModel({
    required this.name,
    required this.gen,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gen': gen,
      'birth_date': birthDate
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
        name: json['name'],
        gen: json['gen'],
        birthDate: json['birth_date']
    );
  }
}
