import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String uid;
  final Timestamp reservationDate;
  final String subject;
  final String details;
  final String admin;

  ReservationModel({
    required this.uid,
    required this.reservationDate,
    required this.subject,
    required this.details,
    required this.admin,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'reservation_date': reservationDate,
      'subject': subject,
      'details': details,
      'admin': admin,
    };
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      uid: json['uid'],
      reservationDate: json['reservation_date'],
      subject: json['subject'],
      details: json['details'],
      admin: json['admin'],
    );
  }
}