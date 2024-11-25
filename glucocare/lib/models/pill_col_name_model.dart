class PillColNameModel {
  final String uid;
  final String date;

  PillColNameModel({
    required this.uid,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
    };
  }

  factory PillColNameModel.fromJson(Map<String, dynamic> json) {
    return PillColNameModel(
      uid: json['uid'],
      date: json['date'],
    );
  }
}