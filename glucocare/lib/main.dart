import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:glucocare/drawer/master_admin_check.dart';
import 'package:glucocare/drawer/notice_posting.dart';
import 'package:glucocare/drawer/patient_search.dart';
import 'package:glucocare/drawer/patient_worning.dart';
import 'package:glucocare/login.dart';
import 'package:glucocare/drawer/my_info.dart';
import 'package:glucocare/models/user_model.dart';
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
import 'drawer/admin_request_info.dart';
import 'firebase_options.dart';

Logger logger = Logger();
bool _isLogined = false;
Logger rlogger = Logger();

Future<void> main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

  // 터치 영역 디버깅 활성화
  debugPaintPointersEnabled = false;

  // locale init - 기본 지역 설정
  await initializeDateFormatting('ko_KR', null);
  Intl.defaultLocale = 'ko_KR';
  rlogger.d('[glucocare_log] locale init');


  // kakotalk api init
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'],
    loggingEnabled: true,
  );
  rlogger.d('[glucocare_log] kakao init');


  // firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  rlogger.d('[glucocare_log] firebase init');

  // notification service init
  NotificationService.initNotification();
  rlogger.d('[glucocare_log] notification init');

  // Background Fetch Headless Init
  FetchService.headlessInit();
  rlogger.d('[glucocare_log] headlessInit');

  if(await AuthService.userLoginedFa() == false && await AuthService.userLoginedKa() == false) _isLogined = false;
  else _isLogined = true;
  rlogger.d('[glucocare_log] login check init');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DaolCare',
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
      home: _isLogined ? const HomePage() : const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Future<void> _getUserName() async {
    try{
      UserModel? model = await UserRepository.selectUserByUid();
      setState(() {
        _userName = model!.name;
        _isAdmin = model.isAdmined;
      });
    } catch(e) {
      logger.e('[glucocare_log] Theres not exist user info. (_getUserName): $e');
    }
  }

  bool _isMaster = false;
  void _checkIsMaster() async {
    if(await AuthService.isMasterUser()) {
      setState(() {
        _isMaster = true;
      });
    }
  }

  Future<void> _widthrawal() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('회원 탈퇴'),
            content: const Text('계정을 삭제하시겠습니까? 삭제한 계정은 복원할 수 없습니다.'),
            actions:<Widget> [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소', style: TextStyle(color: Colors.black),),
              ),
              TextButton(
                  onPressed: () {
                    FetchService.stopAllBackgroundFetch();
                    AuthService.deleteAuth();
                    Navigator.pop(context);
                  },
                  child: const Text('확인', style: TextStyle(color: Colors.black),),
              ),
            ],
          );
        },
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserName();
    _checkIsMaster();
    FetchService.initConfigureBackgroundFetch();
    logger.d('[glucocare_log] main init state.');
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: (_user == null && AuthService.getCurUserId() == null)
        ? null
        : AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            elevation: 0,
            toolbarHeight: 60,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width-50,
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
                          width: MediaQuery.of(context).size.width-120,
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
                    title: const Text('내 정보', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const MyInfoPage()));
                    }
                ),
                if(_isAdmin)
                ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('환자 관리', style: TextStyle(
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
                    title: const Text('위험 환자 관리', style: TextStyle(
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
                if(!_isAdmin)
                ListTile(
                    leading: const Icon(Icons.supervisor_account_outlined),
                    title: const Text('관라자 계정 신청', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRequestInfoPage()));
                    }
                ),
                if(_isMaster)
                    ListTile(
                        leading: const Icon(Icons.switch_access_shortcut),
                        title: const Text('어드민 등록', style: TextStyle(
                            fontSize: 20,
                            color: Colors.black
                        ),),
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MasterAdminCheckPage()));
                        }
                    ),
                ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('로그아웃', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async { // logout logic
                      FetchService.stopAllBackgroundFetch();
                      AuthService.signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage())
                      );
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: const Text('회원탈퇴', style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    onTap: () async {
                      await _widthrawal();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    },
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