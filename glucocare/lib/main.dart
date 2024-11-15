import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:glucocare/login.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:glucocare/taps/gloco_history_tap.dart';
import 'package:glucocare/taps/purse_history_tap.dart';
import 'package:glucocare/taps/home_tap.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await dotenv.load();

  // locale init
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  // kakotalk api init
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY']
  );

  // firebase init
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // notification service init
  NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOME',
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static var _user = FirebaseAuth.instance.currentUser!.uid;

  int _tappedIndex = 0;
  static List<Widget> _tapPages = <Widget> [
    HomeTap(),
    PurseHistoryTap(),
    GlucoHistoryTap(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _tappedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, toolbarHeight: 40,),
      drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: Text(
                      _user,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),
                    ),
                  )
              ),
              ListTile(
                  leading: Icon(Icons.logout),
                  title: const Text('로그아웃', style: TextStyle(
                    fontSize: 20,
                    color: Colors.black
                  ),),
                  onTap: () async {
                    // logout logic
                    AuthService.signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage())
                    );
                  }
              ),
            ],
          )
      ),
      body: _tapPages.elementAt(_tappedIndex),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital),
                label: '홈'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.monitor_heart),
                label: '혈압'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.bloodtype),
                label: '혈당'
            ),
          ],
        currentIndex: _tappedIndex,
        selectedItemColor: Colors.red[800],
        onTap: _onItemTapped,
      ),
    );
  }
}