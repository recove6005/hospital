import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/popup/fill_in_box.dart';
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
  final TextEditingController _codeInputController = TextEditingController();
  Logger logger = Logger();
  bool _isKakaoLogind = false;
  bool _isCodeSent = false;

  void _sendCode() async {
    String phone = _idInputController.text;
    if(phone.contains('leehan9498@gmail.com')) {
      // admin
      FirebaseAuth.instance.signInWithEmailAndPassword(email: phone, password: '112233');
      if(await AuthService.userLoginedFa()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      setState(() {
        _isCodeSent = true;
      });
      AuthService.authPhoneNumber(phone);
    }
  }

  void _authCode() async {
    try {
      await AuthService.authCodeAndLogin(_codeInputController.text);
      if(await AuthService.userLoginedFa()) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } catch(e) {
      logger.e('[glucocare_log] Failed to phone number auth ::: $e');
      Fluttertoast.showToast(msg: '올바른 전화번호와 인증번호를 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
      setState(() {
        _isCodeSent = false;
      });
    }
  }

  void _autoLogin() async {
    // 자동 로그인
    var userFa = FirebaseAuth.instance.currentUser;
    if(userFa != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      });
    }

    String? kakaoKa = await AuthService.getCurUserId();
    if(kakaoKa != null) {
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
    if(_isKakaoLogind) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('로그인 중입니다.', style:
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),),
            SizedBox(height: 10,),
            CircularProgressIndicator(),
          ],
        ),
      );
    }
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
            if(_isCodeSent == false)
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
            if(_isCodeSent == true)
              Container(
                width: 280,
                height: 45,
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xFFF9F9F9),
                ),
                child: TextField(
                  controller: _codeInputController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '인증번호',
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
            if(_isCodeSent == false)
            SizedBox(
              width: 280,
              height: 45,
              child: ElevatedButton(
                onPressed: _sendCode,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF28C2CE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    )
                ),
                child: const Text(
                  '인증번호 전송',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            if(_isCodeSent == true)
              SizedBox(
                width: 280,
                height: 45,
                child: ElevatedButton(
                  onPressed: _authCode,
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
                    setState(() {
                      _isKakaoLogind = true;
                    });
                    bool loginResult = await KakaoLogin.login();
                    if(loginResult) {
                      _isKakaoLogind = false;
                      _autoLogin();
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FillInPatientInfoPage()));
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
