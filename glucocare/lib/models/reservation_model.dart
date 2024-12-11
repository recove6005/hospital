import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String uid;
  final Timestamp reservationDate;

  ReservationModel({
    required this.uid,
    required this.reservationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'reservation_date': reservationDate,
    };
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      uid: json['uid'],
      reservationDate: json['reservation_date'],
    );
  }
}