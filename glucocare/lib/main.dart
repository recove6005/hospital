import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:glucocare/drawer/notice_posting.dart';
import 'package:glucocare/drawer/patient_search.dart';
import 'package:glucocare/drawer/patient_worning.dart';
import 'package:glucocare/login.dart';
import 'package:glucocare/drawer/user_info.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/services/background_fetch_service.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/notification_service.dart';
import 'package:glucocare/taps/gloco_history_tap.dart';
import 'package:glucocare/taps/purse_history_tap.dart';
import 'package:glucocare/taps/home_tap.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

  // 터치 영역 디버깅 활성화
  debugPaintPointersEnabled = false;

  // locale init - 기본 지역 설정
  await initializeDateFormatting('ko_KR', null);
  Intl.defaultLocale = 'ko_KR';

  // kakotalk api init
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'],
    loggingEnabled: true,
  );

  // firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // notification service init
  NotificationService.initNotification();

  // Background Fetch Headless Init
  // FetchService.initConfigureBackgroundFetch();
  FetchService.headlessInit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HOME',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ko', ''),
      ],
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
  Logger logger = Logger();
  static final String? _user = AuthService.getCurUserUid();

  String _userName = '';
  bool _isAdmin = false;

  int _tappedIndex = 0;
  static final List<Widget> _tapPages = <Widget> [
    const HomeTap(),
    const GlucoHistoryTap(),
    const PurseHistoryTap(),
    const Center(child: Text('')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if(index == 3) {
          launchUrl(
            Uri.parse('http://pf.kakao.com/_Hkkxoxj'),
          );
      } else {
        _tappedIndex = index;
      }
    });
  }

  void _CheckUserAndMoveToLogin() async {
    if(await AuthService.userLoginedFa() == false && await AuthService.userLoginedKa() == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) { // 위젯 트리가 빌드된 후 실행
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      });
    }
  }

  Future<void> _getUserName() async {
    try{
      PatientModel? model = await PatientRepository.selectPatientByUid();
      setState(() {
        _userName = model!.name;
        _isAdmin = model.isAdmined;
      });
    } catch(e) {
      logger.e('[glucocare_log] Theres not exist user info. (_getUserName): $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _CheckUserAndMoveToLogin();
    _getUserName();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: (_user == null && AuthService.getCurUserId() == null)
        ? null
        : AppBar(
            backgroundColor: const Color(0xFFFFFFFF),
            shadowColor: Colors.transparent,
            toolbarHeight: 60,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(Icons.menu, size: 40,),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 130,
                                height: 40,
                                child: Image.asset('assets/images/logo_daol.png'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 1,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Text(
                        '$_userName 님',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    )
                ),
                ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('회원 정보', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const UserInfoPage()));
                        if(result) {
                          setState(() {
                            _getUserName();
                          });
                        }
                    }
                ),
                if(_isAdmin)
                ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('회원 검색', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientSearchPage()));
                    }
                ),
                if(_isAdmin)
                ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: const Text('위험 회원 관리', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientWorningPage()));
                    }
                ),
                if(_isAdmin)
                ListTile(
                    leading: const Icon(Icons.post_add),
                    title: const Text('공지 사항 입력', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticePostingPage()));
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('로그아웃', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      AuthService.signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage())
                      );
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.add_task),
                    title: const Text('메인 테스크 추가', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      FetchService.initConfigureBackgroundFetch();
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.add_task),
                    title: const Text('테스크 추가', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      FetchService.initScheduleBackgroundFetch('single_task');
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.stop),
                    title: const Text('테스크 삭제', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      FetchService.stopBackgroundFetchByTaskId('single_task');
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.multiple_stop),
                    title: const Text('테스크 일괄 삭제', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      FetchService.stopBackgroundFetch();
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('로컬 알림 테스트', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      NotificationService.showNotification();
                    }
                ),
              ],
            )
        ),
        body: _user == ''
            ? Container()
            : _tapPages.elementAt(_tappedIndex),
        bottomNavigationBar: _user == ''
            ? null
            : BottomNavigationBar(
                currentIndex: _tappedIndex,
                selectedItemColor: const Color(0xFF28C0CC),
                unselectedItemColor: Colors.grey,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                showUnselectedLabels: true,
                showSelectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem> [
                  BottomNavigationBarItem(
                      icon: _tappedIndex == 0
                          ? SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_home_b.png'),)
                          : SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_home_g.png'),) ,
                      label: '홈'
                  ),
                  BottomNavigationBarItem(
                      icon: _tappedIndex == 1
                          ? SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_bloodsugar_b.png'),)
                          : SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_bloodsugar_g.png'),) ,
                      label: '혈당'
                  ),
                  BottomNavigationBarItem(
                      icon: _tappedIndex == 2
                          ? SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_bloodpressure_b.png'),)
                          : SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_bloodpressure_g.png'),) ,
                      label: '혈압'
                  ),
                  BottomNavigationBarItem(
                      icon: _tappedIndex == 3
                          ? SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_counsel_b.png', color: Colors.orange,),)
                          : SizedBox(width: 25, height: 25, child: Image.asset('assets/images/icon_counsel_g.png', color: Colors.orange,),) ,
                      label: '상담'
                  ),
                ],
              ),
      );
  }
}