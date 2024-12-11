import 'package:flutter/material.dart';
import 'package:glucocare/drawer/pages/doctor_reservation.dart';
import 'package:glucocare/drawer/pages/patient_gluco_info.dart';
import 'package:glucocare/drawer/pages/patient_purse_info.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';

class PatientInfoPage extends StatelessWidget {
  final UserModel model;
  const PatientInfoPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 정보', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: PatientInfoForm(model: model),
    );
  }
}

class PatientInfoForm extends StatefulWidget {
  final UserModel model;
  const PatientInfoForm({super.key, required this.model});

  @override
  State<PatientInfoForm> createState() => _PatientInfoFormState(model: model);
}

class _PatientInfoFormState extends State<PatientInfoForm> {
  UserModel model;
  _PatientInfoFormState({required this.model});

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  final TextEditingController _stateController = TextEditingController();

  String _name = '';
  String _gen = '';
  String _birthDate = '';
  String _state = '없음';
  String _phone = '';

  Future<void> _getModel() async {
    setState(() {
      _name = model.name;
      _gen = model.gen;
      _birthDate = DateFormat('yyyy년 MM월 dd일').format(model.birthDate.toDate());
      _state = model.state;
      _stateController.text = model.state;
      _phone = model.phone;
    });
    }

  void _savePatientRepo(UserModel newModel) async {
    await UserRepository.updateUserInfoBySpecificUid(newModel);
  }

  Widget _getStateChild() {
    if(!_isFocused) {
      return SingleChildScrollView(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.topLeft
          ),
          onPressed: () {
            setState(() {
              _isFocused = true;
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('특이사항 입력', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
              const SizedBox(height: 5,),
              Text(model.state, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('특이사항 입력', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
            const SizedBox(height: 5,),
            Row(
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _stateController,
                    maxLines: null,
                    maxLength: 200,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _state = _stateController.text;
                        UserModel newModel = UserModel(
                          uid: model.uid,
                          kakaoId: model.kakaoId,
                          name: model.name,
                          gen: model.gen,
                          birthDate: model.birthDate,
                          isFilledIn: model.isFilledIn,
                          isAdmined: model.isAdmined,
                          state: _state,
                          phone: model.phone,
                        );
                        _savePatientRepo(newModel);
                        model = newModel;
                        _isFocused = false;
                      });
                    },
                    child: const Icon(Icons.save, size: 40, color: Colors.black,),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  void initState() {
    super.initState();
    _getModel();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // 메모리 누수 방지를 위해 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return false;
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              SizedBox(
                width: 350,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$_name 님', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30,),
                    const Text('성별 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 30,),
                    Text(_gen, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.normal, color: Colors.black),),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30,),
                    const Text('생일 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 30,),
                    Text(_birthDate, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.normal, color: Colors.black),),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30,),
                    const Text('연락처 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black,),),
                    const SizedBox(width: 30,),
                    TextButton(
                      onPressed: () {
                        String phoneNum = '+82${_phone.substring(1)}';
                        _makePhoneCall(phoneNum);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        _phone,
                        style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.normal,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _getStateChild(),
                ),
              const SizedBox(height: 40,),
              Container(
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xfff9f9f9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xff565656)),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      )
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PatientGlucoInfoPage(model: model)));
                  },
                  child: const Text('혈당 내역', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff565656)),),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xfff9f9f9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xff565656)),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      )
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PatientPurseInfoPage(model: model)));
                  },
                  child: const Text('혈압 내역', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff565656)),),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xfff9f9f9),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xff565656)),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      )
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorReservationPage(model: model)));
                  },
                  child: const Text('진료 예약', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff565656)),),
                ),
              ),
              const SizedBox(height: 50,),
            ],
          ),
        ),
      ),
    );

  }
}