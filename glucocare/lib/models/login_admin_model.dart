class LoginAdminModel {
  final String id;
  final String pw;

  LoginAdminModel({
    required this.id,
    required this.pw,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pw': pw,
    };
  }

  factory LoginAdminModel.fromJson(Map<String, dynamic> json) {
    return LoginAdminModel(
      id: json['id'],
      pw: json['pw'],
    );
  }
}