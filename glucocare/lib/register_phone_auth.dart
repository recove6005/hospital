import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glucocare/services/sms_services.dart';
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
        title: const Text('Sing up', style: TextStyle(color: Colors.white),),
      ),
      body: const RegisterPhoneForm(),
    );
  }
}

class RegisterPhoneForm extends StatefulWidget {
  const RegisterPhoneForm({super.key});

  @override
  State<RegisterPhoneForm> createState() => _RegisterPhoneFormState();
}

class _RegisterPhoneFormState extends State<RegisterPhoneForm> {
  Logger logger = Logger();

  static TextEditingController _phoneController = TextEditingController();
  static TextEditingController _authNumberController = TextEditingController();
  String code = "reset";

  static String _createAuthCode() {
    final Random random = Random();
    String randomNumber = '';
    for(int i = 0; i < 6; i++) {
      randomNumber += random.nextInt(10).toString();
    }
    return randomNumber;
  }

  void _sendSMSCode() {
    code = _createAuthCode();
    SMSService.sendPhoneAuthNumber(code);
  }

  bool _checkPhoneAuthCode() {
    String userCode = _phoneController.text;

    if(code == userCode) {
      code = "reset";
      return true;
    }

    return false;
  }

  Future<void> _register() async {
    if(_checkPhoneAuthCode()) {
      // 인증 성공


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
            const SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 190,
                  height: 50,
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                        label: Text('전화번호'),
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
                SizedBox(width: 10,),
                Container(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: _sendSMSCode,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                      child: const Text('인증번호',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white
                        ),
                      ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Container(
              width: 300,
              height: 50,
              child: TextField(
              controller: _authNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  label: Text('인증번호'),
                  labelStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.red,
                      )
                  ),
                ),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 100),
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