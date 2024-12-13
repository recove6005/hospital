import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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

  String _resText = 'Response will appear here.';

  Future<void> callHellowWorldFunction() async {
    try {
      HttpsCallable callable = _functions.httpsCallable("hellowWorld");
      final result = await callable();
      setState(() {
        _resText = result.data.toString();
      });
    } catch(e) {
      setState(() {
        _resText = 'Error: $e';
      });
    }
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
            Text(_resText),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: callHellowWorldFunction,
              child: Text('Call Cloud Function'),
            ),
          ],
        ),
      ),
    );
  }
}