import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeBoardModel {
  final String uid;
  final String title;
  final String content;
  final Timestamp datetime;

  NoticeBoardModel({
    required this.uid,
    required this.title,
    required this.content,
    required this.datetime,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'content': content,
      'date_time': datetime,
    };
  }

  factory NoticeBoardModel.fromJson(Map<String, dynamic> json) {
    return NoticeBoardModel(
      uid: json['uid'],
      title: json['title'],
      content: json['content'],
      datetime: json['date_time'],
    );
  }
}