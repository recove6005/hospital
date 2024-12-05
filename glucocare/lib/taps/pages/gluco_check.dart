import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/danger_check.dart';
import 'package:glucocare/models/gluco_col_name_model.dart';
import 'package:glucocare/models/gluco_danger_model.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/repositories/gluco_danger_repository.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../repositories/gluco_colname_repository.dart';

class GlucoCheckPage extends StatelessWidget {
  const GlucoCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
          leadingWidth: 300,
          leading: const Row(
            children: [
              BackButton(
                color: Colors.black,
              ),
              Text('혈당 입력', style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),),
            ],
          ),
      ),
      body: const GlucoCheckForm(),
    );
  }
}

class GlucoCheckForm extends StatefulWidget {
  const GlucoCheckForm({super.key});

  @override
  State<GlucoCheckForm> createState() => _GlucoCheckFormState();
}

class _GlucoCheckFormState extends State<GlucoCheckForm> {
  Logger logger = Logger();

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  int _checkTimeValue = 0;
  bool _btnToggle = true;

  String _checkTimeName = '식전';
  int _value = 0;
  String _state = '없음';
  String _checkTime = '';
  String _checkDate = '';
  bool _glucoDanger = false;

  String krTime = '';
  String _getKrTime() {
    krTime = DateFormat('hh:mm', 'ko_KR').format(DateTime.now());
    if(DateFormat('a').format(DateTime.now()) == 'AM') {
      krTime = '오전 $krTime';
    } else {
      krTime = '오후 $krTime';
    }
    return krTime;
  }

  void _setState() {
    _checkTimeName = _checkTimeName;
    _value = int.parse(_valueController.text);
    _glucoDanger = DangerCheck.glucoDangerCheck(_value);
    _state = _stateController.text;
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
    _checkTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
    _glucoDanger = DangerCheck.glucoDangerCheck(_value);
  }

  Future<void> _onSaveButtonPressed() async {
    _setState();

    String? uid = '';
    if(await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      uid = await AuthService.getCurUserId();
    }

    if(uid != null) {
      GlucoModel glucoModel = GlucoModel(
        checkTimeName: _checkTimeName,
        value: _value,
        state: _state,
        checkTime: _checkTime,
        checkDate: _checkDate,
      );
      GlucoRepository.insertGlucoCheck(glucoModel);

      if(_glucoDanger) {
        GlucoDangerModel model = GlucoDangerModel(
            uid: uid,
            value: _value,
            danger: _glucoDanger,
            checkTime: Timestamp.fromDate(DateTime.now()),
        );
        GlucoDangerRepository.insertDanger(model);
      }
    }

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      logger.d('[glucocare_log] user fa: $uid');
      GlucoColNameModel nameModel = GlucoColNameModel(uid: uid, date: _checkDate);
      GlucoColNameRepository.insertGlucoColName(nameModel);
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      logger.d('[glucocare_log] user ka : $kakaoId');
      GlucoColNameModel nameModel = GlucoColNameModel(uid: kakaoId, date: _checkDate);
      GlucoColNameRepository.insertGlucoColName(nameModel);
    }
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _checkTimeValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            SizedBox(
              width: 350,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MM월 dd일 E요일', 'ko_KR').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
                  Text(_getKrTime(),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              width: 350,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 40,
                    child: Text('혈당', style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 30,),
                  SizedBox(
                    width: 90,
                    height: 50,
                    child: TextField(
                      controller: _valueController,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        counterText: '',
                      ),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                    child: Text('mg/dL', style: TextStyle(
                        fontSize: 25,
                        color: Colors.black87
                    ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              ),
            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFF9F9F9),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: _btnToggle
                          ? const Color(0xFFDCF9F9)
                          : const Color(0xFFF9F9F9),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: _btnToggle
                            ? const BorderSide(color: Color(0xFF28C2CE), width: 2,)
                            : const BorderSide(color: Color(0xFFB7B7B7), width: 2,),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _btnToggle = true;
                      });
                    },
                    child: const Text(
                      '식전',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 50,),
                Container(
                  width: 100,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFF9F9F9),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: !_btnToggle
                          ? const Color(0xFFDCF9F9)
                          : const Color(0xFFF9F9F9),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: !_btnToggle
                            ? const BorderSide(color: Color(0xFF28C2CE), width: 2,)
                            : const BorderSide(color: Color(0xFFB7B7B7), width: 2,),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _btnToggle = false;
                      });
                    },
                    child: const Text(
                      '식후',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50,),
            const SizedBox(
              width: 350,
              child: Text('메모',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: 350,
              child: TextField(
                controller: _stateController,
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  hintText: '메모를 입력하세요',
                  hintStyle: const TextStyle(fontSize: 20),
                ),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
          ]
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        height: 50,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: _onSaveButtonPressed,
          backgroundColor: const Color(0xFF28C2CE),
          child: const Text('저장하기',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}