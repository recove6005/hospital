import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/services/kakao_login_service.dart';
import 'package:logger/logger.dart';

class RegisterPageForKakao extends StatelessWidget {
  const RegisterPageForKakao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: const RegisterFormForKakao(),
    );
  }
}

class RegisterFormForKakao extends StatefulWidget {
  const RegisterFormForKakao({super.key});

  @override
  State<RegisterFormForKakao> createState() => _RegisterFormStateForKakao();
}

class _RegisterFormStateForKakao extends State<RegisterFormForKakao> {
  Logger logger = Logger();

  static final TextEditingController _nameController = TextEditingController();
  static String _birthYear = '2024';
  static String _birthMonth = '1';
  static String _birthDay = '1';
  static String _dropdownValue = '남';

  void _kakaoRegister() {
    String name = _nameController.text;
    Timestamp birthDate = Timestamp.fromDate(
        DateTime(int.parse(_birthYear), int.parse(_birthMonth), int.parse(_birthDay))
    );
    String gen = _dropdownValue;

    // 회원 등록

    // 카카오 로그인
    bool loginResult = KakaoLogin.login() as bool;
    if(loginResult) {
      User? user = FirebaseAuth.instance.currentUser;
      logger.d('glucocare_log user: $user');
      if(user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
        );
      }
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
            SizedBox(
              width: 280,
              child: Image.asset('assets/images/login_daol.png'),
            ),
            const SizedBox(height: 40,),
            Container(
              width: 280,
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color(0xFFF9F9F9),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: '이름',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB4B4B4),
                  ),
                ),
                style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              width: 280,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFFF9F9F9),
              ),
              child: DropdownButtonFormField(
                value: _dropdownValue,
                icon: Container(
                  child: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.black,),
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 115,),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                items: ['남', '여'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _dropdownValue = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: 280,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    '생년월일',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  DropdownButton(
                    value: _birthYear,
                    hint: const Text('2024'),
                    onChanged: (newValue) {
                      setState(() {
                        _birthYear = newValue!;
                      });
                    },
                    items: [
                      for(int i = 2024; i > 1900; i--)
                        DropdownMenuItem<String>(
                          value: '$i',
                          child: Text('$i'),
                        )
                    ],
                  ),
                  DropdownButton(
                    value: _birthMonth,
                    hint: const Text('1'),
                    onChanged: (newValue) {
                      setState(() {
                        _birthMonth = newValue!;
                      });
                    },
                    items: [
                      for(int i = 1; i < 13; i++)
                        DropdownMenuItem<String>(
                          value: '$i',
                          child: Text('$i'),
                        )
                    ],
                  ),
                  DropdownButton(
                    value: _birthDay,
                    hint: const Text('01'),
                    onChanged: (newValue) {
                      setState(() {
                        _birthDay = newValue!;
                      });
                    },
                    items: [
                      for(int i = 1; i < 32; i++)
                        DropdownMenuItem(
                          value: '$i',
                          child: Text('$i'),
                        )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40,),
            Container(
              width: 280,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF28C2CE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    )
                ),
                onPressed: _kakaoRegister,
                child: const Text(
                  '다음',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        )
    );
  }
}
