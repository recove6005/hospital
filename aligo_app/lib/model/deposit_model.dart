class DepositModel {
  final String docId;
  final String owner;
  final String actNum;

  DepositModel({
    required this.docId,
    required this.owner,
    required this.actNum,
  });

  Map<String, dynamic> toFirebase() {
    return {
      'docId': docId,
      'owner': owner,
      'actNum': actNum,
    };
  }

  factory DepositModel.fromFirebase(Map<String, dynamic> data) {
    return DepositModel(
      docId: data['docId'],
      owner: data['owner'],
      actNum: data['actNum'],
    );
  }
}