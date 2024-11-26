class GlucoModel {
  final String checkTimeName;
  final int value;
  final String state;
  final String checkTime;
  final String checkDate;

  GlucoModel({
    required this.checkTimeName,
    required this.value,
    required this.state,
    required this.checkTime,
    required this.checkDate
  });

  Map<String, dynamic> toJson() {
    return {
      'check_time_name': checkTimeName,
      'value': value,
      'state': state,
      'check_time': checkTime,
      'check_date': checkDate
    };
  }

  factory GlucoModel.fromJson(Map<String, dynamic> json) {
    return GlucoModel(
        checkTimeName: json['check_time_name'],
        value: json['value'],
        state: json['state'],
        checkTime: json['check_time'],
        checkDate: json['check_date']
    );
  }
}