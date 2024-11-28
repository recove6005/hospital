import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '진료 일정',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClinicScheduleScreen(),
    );
  }
}

class ClinicScheduleScreen extends StatelessWidget {
  // 진료 일정 데이터
  final List<Map<String, String>> schedule = [
    {"date": "2024-12-01", "time": "09:00 AM - 05:00 PM", "doctor": "Dr. Kim"},
    {"date": "2024-12-02", "time": "10:00 AM - 04:00 PM", "doctor": "Dr. Lee"},
    {"date": "2024-12-03", "time": "09:30 AM - 06:00 PM", "doctor": "Dr. Choi"},
    {"date": "2024-12-04", "time": "08:30 AM - 05:30 PM", "doctor": "Dr. Park"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("진료 일정"),
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
