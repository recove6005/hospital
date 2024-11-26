class GlucoColNameModel {
  final String? uid;
  final String date;

  GlucoColNameModel({
    required this.uid,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
    };
  }

  factory GlucoColNameModel.fromJson(Map<String, dynamic> json) {
    return GlucoColNameModel(uid: json['uid'], date: json['date']);
  }
}