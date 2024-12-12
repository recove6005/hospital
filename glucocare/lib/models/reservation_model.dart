import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String uid;
  final Timestamp reservationDate;
  final String subject;
  final String details;

  ReservationModel({
    required this.uid,
    required this.reservationDate,
    required this.subject,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'reservation_date': reservationDate,
      'subject': subject,
      'details': details,
    };
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      uid: json['uid'],
      reservationDate: json['reservation_date'],
      subject: json['subject'],
      details: json['details'],
    );
  }
}