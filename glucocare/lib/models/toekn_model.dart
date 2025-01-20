import 'package:glucocare/models/gluco_model.dart';

class TokenModel {
  final String uid;
  final String token;
  final bool isAdmin;
  final bool isMaster;

  TokenModel({
    required this.uid,
    required this.token,
    required this.isAdmin,
    required this.isMaster,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'token': token,
      'is_admin': isAdmin,
      'is_master': isMaster,
    };
  }

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      uid: json['uid'],
      token: json['token'],
      isAdmin: json['is_admin'],
      isMaster: json['is_master'],
    );
  }
}

