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
        title: const Text('회원가입', style: TextStyle(color: Colors.white),),
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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('GLUCOCARE', style: TextStyle(fontSize: 40),),
            const SizedBox(height: 100,),
            Container(
                  width: 300,
                  height: 50,
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        label: Text('전화번호 (-없이 입력)'),
                        labelStyle: const TextStyle(fontSize: 15,),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            )
                        )
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
            SizedBox(height: 30,),
            Container(
              width: 300,
              height: 50,
              child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                  ),
                  child: const Text('가입하기',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white
                    ),
                  )
              ),
            )
          ]
      ),
    );
  }
}