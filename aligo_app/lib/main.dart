import 'package:aligo_app/services/auth_service.dart';
import 'package:aligo_app/tabs/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';

void main() async {
  // 비동기 작업
  WidgetsFlutterBinding.ensureInitialized();

  // firebase init
  await Firebase.initializeApp();

  // intl init
  await initializeDateFormatting('ko_KR', '');

  runApp(const AligoApp());
}

class AligoApp extends StatelessWidget {
  const AligoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Logger logger = Logger();

  final _emailController = TextEditingController();
  final _pwController = TextEditingController();

  // 자동 로그인
  Future<void> _autoLogin() async {
    bool result = await AuthService.checkLogin();
    if(result) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeTab()));
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _pwController.text.trim();
    final int result = await AuthService.login(email, password);
    if(result == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeTab()));
    }
    else if(result == -1) {
      Fluttertoast.showToast(msg: '비밀번호를 6자리 이상 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
    }
    else {
      Fluttertoast.showToast(msg: '이메일과 패스워드를 확인해 주세요.', toastLength: Toast.LENGTH_SHORT);
    }
  }

  void _initAsyncSatate() async {
    await _autoLogin();
  }

  @override
  void initState() {
    super.initState();
    _initAsyncSatate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/aligo_logo.png'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50,),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/images/home_banner.png'),
              ),
              const SizedBox(height: 50,),
              SizedBox(
                width: MediaQuery.of(context).size.width-100,
                child: const Text(
                  '로그인 및 회원가입을 위해 이메일과 패스워드를 입력해 주세요.',
                  style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40,),
              SizedBox(
                width: MediaQuery.of(context).size.width-100,
                height: 50,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: const TextStyle(color: Color(0xff00a99d), fontSize: 15),
                    hintText: 'example@gmail.com',
                    hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                    filled: true,
                    fillColor: const Color(0xfff4f4f4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              SizedBox(
                width: MediaQuery.of(context).size.width-100,
                height: 50,
                child: TextField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xff00a99d), fontSize: 15),
                    hintText: '***',
                    hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                    filled: true,
                    fillColor: const Color(0xfff4f4f4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: MediaQuery.of(context).size.width-100,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00a99d),
                  ),
                  onPressed: _login,
                  child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18),),
                ),
              ),
              const SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }
}