class PillModel {
  final String pillName;
  final String pillCategory;
  final String eatTime;
  final String saveDate;
  final String saveTime;

  PillModel({
    required this.pillName,
    required this.pillCategory,
    required this.eatTime,
    required this.saveDate,
    required this.saveTime
  });

 Map<String, dynamic> toJson() {
    return {
      'pill_name': pillName,
      'pill_category': pillCategory,
      'eat_time': eatTime,
      'save_date': saveDate,
      'save_time': saveTime
    };
  }

  factory PillModel.fromJson(Map<String, dynamic> json) {
    return PillModel(pillName: json['pill_name'],
        pillCategory: json['pill_category'],
        eatTime: json['eat_time'],
        saveDate: json['save_date'],
        saveTime: json['save_time'],
    );
  }
}