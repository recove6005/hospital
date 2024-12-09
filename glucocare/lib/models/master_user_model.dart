class MasterUserModel {
  final String uid;
  final String name;

  MasterUserModel({
    required this.uid,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
    };
  }

  factory MasterUserModel.fromJson(Map<String, dynamic> json) {
    return MasterUserModel(
        uid: json['uid'],
        name: json['name'],
    );
  }
}
