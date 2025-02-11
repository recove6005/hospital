class PriceModel {
  final int date;
  final String docId;
  final bool payed;
  final String paytype;
  final String price;
  final String title;
  final String uid;

  PriceModel({
    required this.date,
    required this.docId,
    required this.payed,
    required this.paytype,
    required this.price,
    required this.title,
    required this.uid,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'docId': docId,
      'payed': payed,
      'paytype': paytype,
      'price': price,
      'title': title,
      'uid': uid,
    };
  }

  factory PriceModel.fromFirestore(Map<String, dynamic> data) {
    return PriceModel(
        date: data['date'],
        docId: data['docId'],
        payed: data['payed'],
        paytype: data['paytype'],
        price: data['price'],
        title: data['title'],
        uid: data['uid'],
    );
  }
}