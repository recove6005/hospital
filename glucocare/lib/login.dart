import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/register_info_general.dart';
import 'package:glucocare/register_info_kakao.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/kakao_login_service.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _idInputController = TextEditingController();
  Logger logger = Logger();

  void _login() async {
    String phone = _idInputController.text;
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: phone,
      password: "112233",
    );

    if(await AuthService.userLoginedFa()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  void _autoLogin() async {
    // 자동 로그인
    var user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      });
    }

    String? kakaoUser = await AuthService.getCurUserId();
    if(kakaoUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: Image.asset('assets/images/login_daol.png'),
            ),
            const SizedBox(height: 25,),
            Container(
              width: 280,
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color(0xFFF9F9F9),
              ),
              child: TextField(
                controller: _idInputController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '전화번호',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB4B4B4),
                  ),
                ),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: 280,
              height: 45,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF28C2CE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    )
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25,),
            Container(
              width: 280,
              height: 1,
              decoration: const BoxDecoration(
                color: Color(0xFFD1D1D1),
              ),
            ),
            const SizedBox(height: 25,),
            Container(
              width: 280,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                  onPressed: () async {
                    bool loginResult = await KakaoLogin.login();
                    if(loginResult) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFFFBE300),
                    shadowColor: Colors.transparent,
                  ),
                  child: Image.asset('assets/images/login/kakao_login_large_narrow.png'),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              width: 65,
              height: 20,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5C5C5C),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
  }
}
