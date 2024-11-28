class GlucoModel {
  final String uid;
  final String checkTimeName;
  final int value;
  final String state;
  final String checkTime;
  final String checkDate;
  final bool glucoDanger;

  GlucoModel({
    required this.uid,
    required this.checkTimeName,
    required this.value,
    required this.state,
    required this.checkTime,
    required this.checkDate,
    required this.glucoDanger,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'check_time_name': checkTimeName,
      'value': value,
      'state': state,
      'check_time': checkTime,
      'check_date': checkDate,
      'gluco_danger': glucoDanger,
    };
  }

  factory GlucoModel.fromJson(Map<String, dynamic> json) {
    return GlucoModel(
        uid: json['uid'],
        checkTimeName: json['check_time_name'],
        value: json['value'],
        state: json['state'],
        checkTime: json['check_time'],
        checkDate: json['check_date'],
        glucoDanger: json['gluco_danger'],
    );
  }
}