import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/pill_alarm_col_name_model.dart';
import 'package:glucocare/models/pill_alarm_model.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/repositories/colname_repository.dart';
import 'package:glucocare/repositories/pill_alarm_repository.dart';
import 'package:glucocare/repositories/pill_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../repositories/pill_colname_repository.dart';

class PillCheckPage extends StatelessWidget {
  const PillCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
      ),
      body: const PillCheckForm(),
    );
  }
}

class PillCheckForm extends StatefulWidget {
  const PillCheckForm({super.key});

  @override
  State<StatefulWidget> createState() => _PillCheckFormState();
}

class _PillCheckFormState extends State<PillCheckForm> {
  Logger logger = Logger();
  String uid = AuthService.getCurUserUid();

  int _alarmHourValue = 1;
  final List<int> _alarmHourOptions = List.generate(12, (index) => (index+=1));
  int? get previousHourOption => _alarmHourValue > 0 && _alarmHourValue != 1 ? _alarmHourValue - 1 : null;
  int? get nextHourOption => _alarmHourValue < _alarmHourOptions.length ? _alarmHourValue + 1 : null;

  int _alarmMinuteValue = 0;
  final List<String> _alarmMinuteOptions = List.generate(60, (index) => index.toString());
  String? get previousMinuteOption => _alarmMinuteValue > 0 ? _alarmMinuteOptions[_alarmMinuteValue - 1] : null;
  String? get nextMinuteOption => _alarmMinuteValue < _alarmMinuteOptions.length - 1 ? _alarmMinuteOptions[_alarmMinuteValue + 1] : null;

  String _alarmTimeAreaValue = '오전';
  final List<String> _alarmTimeAreaOptions = ['오전', '오후'];

  int _pillCategoryValue = 0;
  int _pillEatTimeValue = 0;
  String _pillCategory = '당뇨';
  String _eatTime = '';
  String _saveTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
  String _saveDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  Timestamp _alarmTime = Timestamp.fromDate(DateTime.now());

  String _getPillCategoryName(index) {
      switch (index) {
        case 0: return '당뇨';
        case 1: return '고혈압';
        case 2: return '고지혈증';
      }
      return 'Err';
  }

  String _getEatTimeName(index) {
    switch (index) {
      case 0: return '아침약';
      case 1: return '점심약';
      case 2: return '저녁약';
    }
    return 'Err';
  }

  void _setStates() {
    _pillCategory = _getPillCategoryName(_pillCategoryValue);
    _eatTime = _getEatTimeName(_pillEatTimeValue);
    _saveTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
    _saveDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());

    // _alarmTime
    int adjustedHour = _alarmHourValue;
    if(_alarmTimeAreaValue == '오후') adjustedHour += 12;
    if(_alarmTimeAreaValue == '오전' && _alarmHourValue == 12) adjustedHour = 0;
    _alarmTime = Timestamp.fromDate(
        DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            adjustedHour,
            _alarmMinuteValue
        ).toUtc()
    );
  }

  void _onSaveButtonPressed() {
    _setStates();
    PillModel pillModel = PillModel(pillCategory: _pillCategory, eatTime: _eatTime, saveDate: _saveDate, saveTime: _saveTime, alarmTime: _alarmTime);
    PillAlarmModel pillAlarmModel = PillAlarmModel(saveDate: _saveDate, saveTime: _saveTime, alarmTime: _alarmTime);
    PillAlarmColNameModel alarmNameModel = PillAlarmColNameModel(date: _saveDate, uid: uid);

    PillRepository.insertPillCheck(pillModel);
    PillAlarmRepository.insertPillAlarm(pillAlarmModel);
    PillColNameRepository.insertAlarmColName(alarmNameModel);

    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _pillEatTimeValue = 0;
    _pillCategoryValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50,),
          Container(
            width: 350,
            padding: EdgeInsets.only(left: 70),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('약품 분류'),
                  Container(
                    height: 40,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                          value: 0,
                          groupValue: _pillCategoryValue,
                          onChanged: (int? value) {
                            setState(() {
                              _pillCategoryValue = value!;
                            });
                          }),
                      title: const Text('당뇨', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                      onTap: () {
                        setState(() {
                          _pillCategoryValue = 0;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                          value: 1,
                          groupValue: _pillCategoryValue,
                          onChanged: (int? value) {
                            setState(() {
                              _pillCategoryValue = value!;
                            });
                          }),
                      title: const Text('고혈압', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                      onTap: () {
                        setState(() {
                          _pillCategoryValue = 1;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                          value: 2,
                          groupValue: _pillCategoryValue,
                          onChanged: (int? value) {
                            setState(() {
                              _pillCategoryValue = value!;
                            });
                          }),
                      title: const Text('고지혈증', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                      onTap: () {
                        setState(() {
                          _pillCategoryValue = 2;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 70,),
                  const Text('복약/투약 시간대'),
                  Container(
                    height: 40,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                          value: 0,
                          groupValue: _pillEatTimeValue,
                          onChanged: (int? value) {
                            setState(() {
                              _pillEatTimeValue = value!;
                            });
                          }),
                      title: const Text('아침약', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                      onTap: () {
                        setState(() {
                          _pillEatTimeValue = 0;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                          value: 1,
                          groupValue: _pillEatTimeValue,
                          onChanged: (int? value) {
                            setState(() {
                              _pillEatTimeValue = value!;
                            });
                          }),
                      title: const Text('점심약', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                      onTap: () {
                        setState(() {
                          _pillEatTimeValue = 1;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 40,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int>(
                          value: 2,
                          groupValue: _pillEatTimeValue,
                          onChanged: (int? value) {
                            setState(() {
                              _pillEatTimeValue = value!;
                            });
                          }),
                      title: const Text('저녁약',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _pillEatTimeValue = 2;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 70,),
          Container(
            width: 350,
            padding: const EdgeInsets.only(left: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('알림 시간'),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(_alarmTimeAreaValue == '오전') 
                            const Text(''),
                          if(_alarmTimeAreaValue == '오후')
                            const Text('오전', style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),),
                          CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _alarmTimeAreaValue = _alarmTimeAreaOptions[index];
                                });
                              },
                              children: _alarmTimeAreaOptions.map((item) => Center(
                                child: Text(item, style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),),
                              )).toList(),
                          ),
                          if(_alarmTimeAreaValue == '오후')
                            const Text(''),
                          if(_alarmTimeAreaValue == '오전')
                            const Text('오후', style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),),
                        ],
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(previousHourOption != null)
                            Text(previousHourOption.toString(), style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),),
                          if(previousHourOption == null)
                            const Text(''),
                          CupertinoPicker(
                              itemExtent: 50,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _alarmHourValue = index+1;
                                });
                              },
                              children: _alarmHourOptions.map((item) => Center(
                                child: Text(item.toString(), style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),),
                              )).toList(),
                          ),
                          if(nextHourOption != null)
                            Text(nextHourOption.toString(), style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),),
                          if(nextHourOption == null)
                            const Text(''),
                        ],
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(previousMinuteOption != null)
                            Text(previousMinuteOption!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),),
                          if(previousMinuteOption == null)
                            const Text('',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),),
                          CupertinoPicker(
                            itemExtent: 50,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _alarmMinuteValue = index;
                              });
                            },
                            children: _alarmMinuteOptions.map((item) => Center(
                              child: Text(item, style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                              ),),
                            )).toList(),
                          ),
                          if(nextMinuteOption != null)
                            Text(nextMinuteOption!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),),
                          if(nextMinuteOption == null)
                            const Text('',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        height: 50,
        child: FloatingActionButton(
          onPressed: _onSaveButtonPressed,
          backgroundColor: Colors.grey[350],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}