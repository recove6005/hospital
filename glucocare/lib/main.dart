import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glucocare/login.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'login_page',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          brightness: Brightness.light,
          textTheme: TextTheme(
              bodySmall: TextStyle(fontSize: 15, color: Colors.grey[800]),
              bodyMedium: TextStyle(fontSize: 20, color: Colors.grey[800]),
              bodyLarge: TextStyle(fontSize: 30, color: Colors.grey[800])
          ),
          appBarTheme: AppBarTheme(
              color: Colors.red[700],
              elevation: 4
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.red[700],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          )
      ),
      home: const MyHomePage(title: 'main'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:',),
            Text('main page', style: Theme.of(context).textTheme.headlineMedium,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()))
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
