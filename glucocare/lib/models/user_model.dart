import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String kakaoId;
  final String name;
  final String gen;
  final Timestamp birthDate;
  final bool isFilledIn;
  final bool isAdmined;
  final String state;

  UserModel({
    required this.uid,
    required this.kakaoId,
    required this.name,
    required this.gen,
    required this.birthDate,
    required this.isFilledIn,
    required this.isAdmined,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'kakao_id': kakaoId,
      'name': name,
      'gen': gen,
      'birth_date': birthDate,
      'is_filled_in': isFilledIn,
      'is_admined': isAdmined,
      'state': state,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['uid'],
        kakaoId: json['kakao_id'],
        name: json['name'],
        gen: json['gen'],
        birthDate: json['birth_date'],
        isFilledIn: json['is_filled_in'],
        isAdmined: json['is_admined'],
        state: json['state'],
    );
  }
}