import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ClinicScheduleScreen(),
    );
  }
}

class ClinicScheduleScreen extends StatelessWidget {
  // 진료 일정 데이터
  final List<Map<String, String>> schedule = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("진료 일정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final item = schedule[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(
                "날짜: ${item['date']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("시간: ${item['time']}"),
                  Text("의사: ${item['doctor']}"),
                ],
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // 일정 클릭 시 동작 (선택 사항)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${item['date']}의 진료 일정입니다.")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
