import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFunctions _functions = FirebaseFunctions.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;

  TextEditingController _userId = TextEditingController();


  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // 현재 기기 사용자 FCM토큰 저장
  void _saveTokenToFirestore() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String userId = _userId.text;
    String? token = await messaging.getToken();
    if(token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'fcmToken': token});
    }
  }

  void _addData() async {
    String userId = _userId.text;
    _store.collection('data').doc(userId).set(
      {
        'addedBy': userId,
        'content': 'human0 exemaple',
        'targetUserId': 'human1',
      }
    );
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Functions Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           TextField(
             controller: _userId,
           ),
            ElevatedButton(onPressed: _saveTokenToFirestore, child: Text('add user fcm token')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addData),
    );
  }
}