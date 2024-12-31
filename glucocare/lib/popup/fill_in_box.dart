import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/login.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:logger/logger.dart';

class FillInPatientInfoPage extends StatelessWidget {
  const FillInPatientInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: const FillInPatientInfoForm(),
    );
  }
}

class FillInPatientInfoForm extends StatefulWidget {
  const FillInPatientInfoForm({super.key});

  @override
  State<FillInPatientInfoForm> createState() => _FillInPatientInfoFormState();
}

class _FillInPatientInfoFormState extends State<FillInPatientInfoForm> {
  Logger logger = Logger();

  static final TextEditingController _nameController = TextEditingController();
  static final TextEditingController _phoneController = TextEditingController();
  static String _birthYear = '2024';
  static String _birthMonth = '1';
  static String _birthDay = '1';
  static String _dropdownValue = '남';

  Future<bool> _setInfos() async {
    String? uid = '';
    String? kakaoId = '';
    if(await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      kakaoId = await AuthService.getCurUserId();
    }
    String name = _nameController.text;
    Timestamp birthDate = Timestamp.fromDate(
        DateTime(int.parse(_birthYear), int.parse(_birthMonth), int.parse(_birthDay), 0, 0)
    );
    String gen = _dropdownValue;
    bool isFilledIn = true;
    String phone = _phoneController.text.trim();

    final regex = RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]');
    if(uid != '' || kakaoId != '') {
      if(name.length >= 2 && !regex.hasMatch(name)) {
        if(uid != null && kakaoId != null ) {
          UserModel model = UserModel(uid: uid, kakaoId: kakaoId, name: name, gen: gen, birthDate: birthDate, isFilledIn: isFilledIn, isAdmined: false, state: '없음', phone: phone);
          UserRepository.updateUserInfo(model);
        } else {
          Fluttertoast.showToast(msg: '다시 로그인 해주세요.', toastLength: Toast.LENGTH_SHORT);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false
          );
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        Fluttertoast.showToast(msg: '정확한 이름을 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
      }
    } else {
      Fluttertoast.showToast(msg: '회원 정보가 없습니다.', toastLength: Toast.LENGTH_SHORT);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
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
                    hintText: '연락처',
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB4B4B4),
                    ),
                  ),
                  style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
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
                      hint: const Text('1'),
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
                  onPressed: _setInfos,
                  child: const Text(
                    '입력',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
