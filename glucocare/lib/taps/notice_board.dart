import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoticeBoardPage extends StatelessWidget {
  const NoticeBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: const NoticeBoardForm(),
    );
  }
}

class NoticeBoardForm extends StatefulWidget {
  const NoticeBoardForm({super.key});

  @override
  State<NoticeBoardForm> createState() => _NoticeBoardFormState();
}

class _NoticeBoardFormState extends State<NoticeBoardForm> {

  final List<Map<String, String>> notices = [
    {
      "title": "진료 시간 변경 안내",
      "date": "2024-11-27",
      "content": "12월부터 진료 시간이 변경됩니다. 오전 9시부터 오후 6시까지."
    },
    {
      "title": "독감 예방 접종 안내",
      "date": "2024-11-20",
      "content": "독감 예방 접종이 시작되었습니다. 예약 후 방문 부탁드립니다."
    },
    {
      "title": "추석 휴무 안내",
      "date": "2024-09-28",
      "content": "추석 연휴 기간 동안 병원은 휴무입니다."
    },
    {
      "title": "코로나 예방 접종 안내",
      "date": "2024-05-08",
      "content": "코로나 예방 접종이 시작되었습니다. 예약 후 방문 부탁드립니다."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: notices.length, // 공지사항 개수
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Container(
            width: 300,
            height: 150,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey,
                )
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice["title"]!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "날짜: ${notice["date"]}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    notice["content"]!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
