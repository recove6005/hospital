import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/purse_col_name_model.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../repositories/purse_colname_repository.dart';

class PurseCheckPage extends StatelessWidget {
  const PurseCheckPage({super.key});

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
            Text('혈압 입력', style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),),
          ],
        )
      ),
      body: const PurseCheckForm(),
    );
  }
}

class PurseCheckForm extends StatefulWidget {
  const PurseCheckForm({super.key});

  @override
  State<PurseCheckForm> createState() => _PurseCheckFormState();
}

class _PurseCheckFormState extends State<PurseCheckForm> {
  Logger logger = Logger();

  final TextEditingController _shrinkController = TextEditingController();
  final TextEditingController _relaxController = TextEditingController();
  final TextEditingController _purseController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  int _shrink = 0;
  int _relax = 0;
  int _purse = 0;
  String _state = '없음';
  String _checkTime = '';
  String _checkDate = '';

  void _setStates() {
    _shrink = int.parse(_shrinkController.text);
    _relax = int.parse(_relaxController.text);
    _purse = int.parse(_purseController.text);

    _state = _stateController.text;

    _checkTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  }

  void _onSaveButtonPressed() async {
    _setStates();

    PurseModel purseModel = PurseModel(
        shrink: _shrink,
        relax: _relax,
        purse: _purse,
        state: _state,
        checkTime: _checkTime,
        checkDate: _checkDate
    );
    PurseRepository.insertPurseCheck(purseModel);

    if(await AuthService.userLoginedFa()) {
      String? uid = AuthService.getCurUserUid();
      PurseColNameModel nameModel = PurseColNameModel(uid: uid!, date: _checkDate);
      PurseColNameRepository.insertPurseColName(nameModel);
    } else {
      String? kakaoId = await AuthService.getCurUserId();
      PurseColNameModel nameModel = PurseColNameModel(uid: kakaoId!, date: _checkDate);
      PurseColNameRepository.insertPurseColName(nameModel);
    }

    Navigator.pop(context, true);
  }

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

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
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
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 70,
                          height: 30,
                          child: Text(
                            '수축기',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        const SizedBox(width: 20,),
                        SizedBox(
                          width: 80,
                          height: 35,
                          child: TextField(
                            controller: _shrinkController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            decoration: const InputDecoration(
                                counterText: '',
                                hintStyle: TextStyle(color: Colors.black38)
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                            ),
                          ),
                        ),
                        const Text('mmHg', style: TextStyle(fontSize: 18),),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      width: 350,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 70,
                              height: 35,
                              child: Text('이완기', style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                            const SizedBox(width: 20,),
                            SizedBox(
                              width: 80,
                              height: 35,
                              child: TextField(
                                controller: _relaxController,
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                decoration: const InputDecoration(
                                    counterText: '',
                                    hintStyle: TextStyle(color: Colors.black38)
                                ),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Text('mmHg', style: TextStyle(fontSize: 18),),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      width: 350,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 70,
                              height: 35,
                              child: Text('맥박', style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),),
                            ),
                            const SizedBox(width: 20,),
                            SizedBox(
                              width: 80,
                              height: 35,
                              child: TextField(
                                  controller: _purseController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  decoration: const InputDecoration(
                                      counterText: '',
                                      hintStyle: TextStyle(color: Colors.black38)
                                  ),
                                  style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.black
                                  )
                              ),
                            ),
                            const Text('회/1분', style: TextStyle(fontSize: 18),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30,),
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
            Container(
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
