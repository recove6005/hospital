import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/register_info_general.dart';
import 'package:glucocare/register_info_kakao.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인', style: TextStyle(color: Colors.white),),
      ),
      body: const LoginForm(),
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

  void _login() async {
    String phone = _idInputController.text;
    // AuthService.sendPhoneAuth(phone);

    // ====================
    // master account
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: phone,
      password: "112233",
    // ====================
    );

    User? user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }

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
            const Text('GLUCOCARE', style: TextStyle(fontSize: 40),),
            const SizedBox(height: 80,),
            SizedBox(
              width: 300,
              height: 50,
              child: TextField(
                controller: _idInputController,
                decoration: InputDecoration(
                  labelText: '전화번호 (-없이 입력)',
                  labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.red,
                      )
                  ),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30,),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                child: const Text('로그인', style: TextStyle(fontSize: 15, color: Colors.white),),
              ),
            ),
            const SizedBox(height: 5,),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()))
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                child: const Text('회원가입', style: TextStyle(fontSize: 15, color: Colors.white),),
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: 350,
              height: 50,
              child: GestureDetector(
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPageForKakao()))
                },
                child: Image.asset(
                  'assets/images/login/kakao_login_medium_wide.png',
                ),
              ),
            ),
          ],
        ),
      );
  }
}
