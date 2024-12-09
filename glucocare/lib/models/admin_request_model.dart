class AdminRequestModel {
  final String uid;
  final bool accepted;

  AdminRequestModel({
    required this.uid,
    required this.accepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'accepted': accepted,
    };
  }

  factory AdminRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminRequestModel(uid: json['uid'], accepted: json['accepted']);
  }
}