import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String call;
  final Timestamp date;
  final String details;
  final String email;
  final String name;
  final String organization;
  final String progress;
  final String title;
  final String uid;
  final String userEmail;

  ProjectModel({
    required this.call,
    required this.date,
    required this.details,
    required this.email,
    required this.name,
    required this.organization,
    required this.progress,
    required this.title,
    required this.uid,
    required this.userEmail,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'call': call,
      'date': date,
      'details': details,
      'email' : email,
      'name' : name,
      'organization': organization,
      'progress' : progress,
      'uid': uid,
      'userEmail': userEmail,
    };
  }

  factory ProjectModel.fromFirestore(Map<String, dynamic> data) {
    return ProjectModel(
        call: data['call'],
        date: data['date'],
        details: data['details'],
        email: data['email'],
        name: data['name'],
        organization: data['organization'],
        progress: data['progress'],
        title: data['title'],
        uid: data['uid'],
        userEmail: data['userEmail'],
    );
  }

}