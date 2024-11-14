class PillAlarmColNameModel {
  final String uid;
  final String date;

  PillAlarmColNameModel({
    required this.uid,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'date': date,
    };
  }

  factory PillAlarmColNameModel.fromJson(Map<String, dynamic> json) {
    return PillAlarmColNameModel(
      uid: json['uid'],
      date: json['date'],
    );
  }
}