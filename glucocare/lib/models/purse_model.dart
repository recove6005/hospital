class PurseModel {
  final String uid;
  final int shrink;
  final int relax;
  final int purse;
  final String state;
  final String checkTime;
  final String checkDate;
  final bool shrinkDanger;
  final bool relaxDanger;

  PurseModel({
    required this.uid,
    required this.shrink,
    required this.relax,
    required this.purse,
    required this.state,
    required this.checkTime,
    required this.checkDate,
    required this.shrinkDanger,
    required this.relaxDanger,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'shrink': shrink,
      'relax': relax,
      'purse': purse,
      'state': state,
      'check_time': checkTime,
      'check_date': checkDate,
      'shrink_danger': shrinkDanger,
      'relax_danger': relaxDanger,
    };
  }

  factory PurseModel.fromJson(Map<String, dynamic> json) {
    return PurseModel(
      uid: json['uid'],
      shrink: json['shrink'],
      relax: json['relax'],
      purse: json['purse'],
      state: json['state'],
      checkTime: json['check_time'],
      checkDate: json['check_date'],
      shrinkDanger: json['shrink_danger'],
      relaxDanger: json['relax_danger'],
    );
  }
}