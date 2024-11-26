class PurseColNameModel {
  final String uid;
  final String date;

  PurseColNameModel({
    required this.uid,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
    };
  }

  factory PurseColNameModel.fromJson(Map<String, dynamic> json) {
    return PurseColNameModel(uid: json['uid'], date: json['date']);
  }
}