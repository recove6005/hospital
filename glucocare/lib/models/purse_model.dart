class PurseModel {
  final int shrink;
  final int relax;
  final int purse;
  final String state;
  final String checkTime;
  final String checkDate;

  PurseModel({
    required this.shrink,
    required this.relax,
    required this.purse,
    required this.state,
    required this.checkTime,
    required this.checkDate
  });

  Map<String, dynamic> toJson() {
    return {
      'shrink': shrink,
      'relax': relax,
      'purse': purse,
      'state': state,
      'check_time': checkTime,
      'check_date': checkDate
    };
  }

  factory PurseModel.fromJson(Map<String, dynamic> json) {
    return PurseModel(
        shrink: json['shrink'],
        relax: json['relax'],
        purse: json['purse'],
        state: json['state'],
        checkTime: json['check_time'],
        checkDate: json['check_date']
    );
  }
}