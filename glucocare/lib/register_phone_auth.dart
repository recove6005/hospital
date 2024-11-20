import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class RegisterPhonePage extends StatelessWidget {
  final String name;
  final String gen;
  final Timestamp birthDate;

  const RegisterPhonePage(
        this.name,
        this.gen,
        this.birthDate,
        {super.key}
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: RegisterPhoneForm(
        name: name,
        gen: gen,
        birthDate: birthDate
      ),
    );
  }
}

class RegisterPhoneForm extends StatefulWidget {
  final String name;
  final String gen;
  final Timestamp birthDate;

  const RegisterPhoneForm({
    super.key,
    required this.name,
    required this.gen,
    required this.birthDate
  });

  @override
  State<RegisterPhoneForm> createState() => _RegisterPhoneFormState();
}

class _RegisterPhoneFormState extends State<RegisterPhoneForm> {
  Logger logger = Logger();

  static TextEditingController _phoneController = TextEditingController();

  Future<void> _register() async {
    // 전화번호 인증
    String phone = _phoneController.text;
    AuthService.sendPhoneAuth(phone);

    User? user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      // 인증 성공
      // 회원 등록
      PatientModel model = PatientModel(
          name: widget.name,
          gen: widget.gen,
          birthDate: widget.birthDate
      );
      PatientRepository.insertPatient(model);

      //화면 전환
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // 인증 실패 다이얼로그
      logger.d('glucocore_log : The Phonenumber authentification is failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFFF9F9F9),
              ),
              child: TextField(
                controller: _phoneController,
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
                style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 280,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28C2CE),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    )
                ),
                onPressed: _register,
                child: const Text(
                  '가입하기',
                  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]
      ),
    );
  }
}