import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/gluco_col_name_model.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/repositories/colname_repository.dart';
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

  String _formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  String _formattedTime = DateFormat('a hh시 mm분', 'ko_KR').format(DateTime.now());
  late Timer _timerTime;

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  static int _checkTimeValue = 0;

  String _checkTimeName = '기상 후';
  int _value = 0;
  String _state = '없음';
  String _checkTime = '';
  String _checkDate = '';

  String _getStateName(int index) {
    switch (index) {
      case 0: return '식전';
      case 1: return '식후';
    }

    return 'Err';
  }

  void _setState() {
    _checkTimeName = _getStateName(_checkTimeValue);
    _value = int.parse(_valueController.text);
    _state = _stateController.text;
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
    _checkTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
  }

  void _onSaveButtonPressed() {
    _setState();

    GlucoModel glucoModel = GlucoModel(
        checkTimeName: _checkTimeName,
        value: _value,
        state: _state,
        checkTime: _checkTime,
        checkDate: _checkDate
    );
    GlucoRepository.insertGlucoCheck(glucoModel);

    String uid = AuthService.getCurUserUid();
    GlucoColNameModel nameModel = GlucoColNameModel(uid: uid, date: _checkDate);
    GlucoColNameRepository.insertGlucoColName(nameModel);

    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();

    _checkTimeValue = 0;

    _timerTime = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
        _formattedTime = DateFormat('a hh시 mm분', 'ko_KR').format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10,),
            Text(
              _formattedDate,
              style: const TextStyle(
              fontSize: 25,
              color: Colors.black
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              _formattedTime,
              style: const TextStyle(
              fontSize: 22,
              color: Colors.black
              ),
            ),
            const SizedBox(height: 30,),
            Container(
              width: 350,
              height: 130,
              child: Column(
                children: [
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                      leading: Radio<int>(
                        value: 0,
                        groupValue: _checkTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _checkTimeValue = value!;
                          });
                        },
                      ),
                      title: const Text('식전', style: TextStyle(
                          fontSize: 17,
                          color: Colors.black),),
                      onTap: () {
                        setState(() {
                          _checkTimeValue = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 30,),
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                      leading: Radio<int>(
                        value: 1,
                        groupValue: _checkTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _checkTimeValue = value!;
                          });
                        },
                      ),
                      title: const Text('식후', style: TextStyle(
                          fontSize: 17,
                          color: Colors.black),),
                      onTap: () {
                        setState(() {
                          _checkTimeValue = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              width: 350,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.orange[200],
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('혈당', style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),),
                  const SizedBox(width: 50,),
                  SizedBox(
                    width: 80,
                    height: 70,
                    child: TextField(
                      controller: _valueController,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(fontSize: 40,color: Colors.grey),
                        counterText: '',
                      ),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  const Text('mmHg', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                  ),)
                ],
              ),
            ),
            const SizedBox(height: 30,),
            SizedBox(
              width: 350,
              height: 200,
              child: TextField(
                controller: _stateController,
                maxLength: 100,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '특이사항',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black
                ),
              ),
            )
          ]
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        height: 50,
        child: FloatingActionButton(
          onPressed: _onSaveButtonPressed,
          backgroundColor: Colors.orange[200],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}