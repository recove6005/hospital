import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/danger_check.dart';
import 'package:glucocare/models/gluco_col_name_model.dart';
import 'package:glucocare/models/gluco_danger_model.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/repositories/gluco_danger_repository.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/fcm_service.dart';
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

  Color _backgroundColor = Colors.white;

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  int _checkTimeValue = 0;
  bool _btnToggle = true;

  bool _isSaving = false;

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

  int _diagnosisValue = -1;
  void _getDiagnosis(text) {
      if(_valueController.text == '') {
        setState(() {
          _diagnosisValue = -1;
        });
        return;
      }

      _value = int.parse(text);

      if(_value <= 70) {
        setState(() {
          _diagnosisValue = -2;
        });
        return;
      }

      if(_checkTimeName == '식후') {
        if(_value >= 200) {
          setState(() {
            _diagnosisValue = 2;
          });
          return;
        }
        else if(_value >= 110) {
          setState(() {
            _diagnosisValue = 1;
          });
          return;
        }
        else {
          setState(() {
            _diagnosisValue = 0;
          });
          return;
        }
      }
      else if(_checkTimeName == '식전') {
        if(_value >= 170) {
          setState(() {
            _diagnosisValue = 2;
          });
          return;
        }
        else if(_value >= 100) {
          setState(() {
            _diagnosisValue = 1;
          });
          return;
        }
        else {
          setState(() {
            _diagnosisValue = 0;
          });
          return;
        }
      }

      setState(() {
        _diagnosisValue = -1;
      });
    }


  void _setState() {
    _value = int.parse(_valueController.text);
    _state = _stateController.text;
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now().toLocal());
    _checkTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now().toLocal());
    _glucoDanger = DangerCheck.glucoDangerCheck(_value, _checkTimeName);

    logger.d("[glucocare_log] 현재 기기 시간: ${DateTime.now().toLocal()}, $_checkTime");
    logger.d("[glucocare_log] 현재 UTC 시간: ${DateTime.now().toUtc()}");
    logger.d("[glucocare_log] 현재 타임존 오프셋: ${DateTime.now().timeZoneOffset}");
  }

  Future<void> _onSaveButtonPressed() async {
    setState(() {
      _isSaving = true;
    });

    if(_valueController.text == '') {
      Fluttertoast.showToast(msg: '혈당 수치를 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
      setState(() {
        _isSaving = false;
      });
      return;
    }

    _setState();

    String? uid = '';
    if(await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      uid = await AuthService.getCurUserId();
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
        // fcm service
        String name = await UserRepository.getCurrentUserName();
        await FCMService.sendPushNotification(name, '혈당', _value.toString(), _checkDate, _checkTime);
        
        // 위험 단계 수치
        GlucoDangerModel model = GlucoDangerModel(
            uid: uid,
            value: _value,
            danger: _glucoDanger,
            checkTime: Timestamp.fromDate(DateTime.now().toUtc()),
            checkTimeName: _checkTimeName,
        );
        GlucoDangerRepository.insertDanger(model);
      }

      if(_checkTimeName.contains('식전')) {
        if(_value >= 170) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.dangerous, color: Color(0xFF22BED3),),
                      Text('경고: 당뇨병', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당이 높습니다. 운동 및 신체 활동량을 늘리시고 지속적인 혈당 상승 시 진료 바랍니다.', style: TextStyle(fontSize: 20),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    )
                  ]
              );
            },
          );
        } else if(_value >= 100) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF22BED3),),
                      Text('경고: 당뇨 주의', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당이 높습니다. 생활 습관 개선을 통한 관리가 필요합니다.', style: TextStyle(fontSize: 20),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    )
                  ]
              );
            },
          );
        } else if(_value >= 70) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.check, color: Color(0xFF22BED3),),
                      Text('정상 혈당', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당 수치가 정상 범위 내에 있습니다.', style: TextStyle(fontSize: 25),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    ),
                  ]
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF22BED3),),
                      Text('저혈당', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당 수치가 너무 낮습니다. 생활 습관 관리에 유의하시고, 의료진의 도움을 받으세요.', style: TextStyle(fontSize: 25),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    ),
                  ]
              );
            },
          );
        }
      }
      else if(_checkTimeName.contains('식후')) {
        if(_value >= 200) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.dangerous, color: Color(0xFF22BED3),),
                      Text('경고: 고혈당', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당이 높습니다. 운동 및 신체 활동량을 늘리시고 지속적인 혈당 상승 시 진료바랍니다.', style: TextStyle(fontSize: 25),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    )
                  ]
              );
            },
          );
        } else if(_value >= 110) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF22BED3),),
                      Text('경고: 혈당주의', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당이 높습니다. 생활 습관 개선을 통한 관리가 필요합니다.', style: TextStyle(fontSize: 25),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    )
                  ]
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.check, color: Color(0xFF22BED3),),
                      Text('정상 혈당', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),)
                    ],
                  ),
                  content: const Text('혈당 수치가 정상 범위 내에 있습니다.', style: TextStyle(fontSize: 25),),
                  actions: <Widget> [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF22BED3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    ),
                  ]
              );
            },
          );
        }
      }
    }
  }

  @override
  TextInputFormatter rangeTextInputFormatter(int min, int max) {
    return TextInputFormatter.withFunction(
          (TextEditingValue oldValue, TextEditingValue newValue) {
        if(newValue.text.isEmpty) {
          return newValue; // Allow empty input
        }

        final int? value = int.tryParse(newValue.text);
        if (value == null || value < min || value > max) {
          return oldValue; // Revert to previous value if out of range
        }

        return newValue; // Accept valid input
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkTimeValue = 0;
    _checkTimeName = '식전';
  }

  @override
  Widget build(BuildContext context) {
    if(_isSaving) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: AnimatedContainer(
          height: MediaQuery.of(context).size.height,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          color: _backgroundColor,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width-80,
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
                      width:  MediaQuery.of(context).size.width-80,
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
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                rangeTextInputFormatter(0, 300),
                              ],
                              onChanged: (text) {
                                _getDiagnosis(text);
                                _value = int.parse(text);
                                if(_checkTimeName == '식전') {
                                  if(_value >= 170) {
                                    setState(() {
                                      _backgroundColor = const Color(0xfffd6363);
                                    });
                                  }
                                  else if(_value >= 100) {
                                    setState(() {
                                      _backgroundColor = const Color(0xfff87c3c);
                                    });
                                  }
                                  else {
                                    setState(() {
                                      _backgroundColor = Colors.white;
                                    });
                                  }
                                }
                                if(_checkTimeName == '식후') {
                                  if(_value >= 200) {
                                    setState(() {
                                      _backgroundColor = const Color(0xfffd6363);
                                    });
                                  }
                                  else if(_value >= 110) {
                                    setState(() {
                                      _backgroundColor = const Color(0xfff87c3c);
                                    });
                                  }
                                  else {
                                    setState(() {
                                      _backgroundColor = Colors.white;
                                    });
                                  }
                                }
                              },
                              decoration: const InputDecoration(
                                counterText: '',
                              ),
                              style: const TextStyle(
                                fontSize: 35,
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
                                _checkTimeName = '식전';
                                if(_value >= 170) {
                                  setState(() {
                                    _backgroundColor = const Color(0xfffd6363);
                                  });
                                }
                                else if(_value >= 100) {
                                  setState(() {
                                    _backgroundColor = const Color(0xfff87c3c);
                                  });
                                }
                                else {
                                  setState(() {
                                    _backgroundColor = Colors.white;
                                  });
                                }
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
                                _checkTimeName = '식후';
                                if(_value >= 200) {
                                  setState(() {
                                    _backgroundColor = const Color(0xfffd6363);
                                  });
                                }
                                else if(_value >= 110) {
                                  setState(() {
                                    _backgroundColor = const Color(0xfff87c3c);
                                  });
                                }
                                else {
                                  setState(() {
                                    _backgroundColor = Colors.white;
                                  });
                                }
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
                    if(_diagnosisValue == 2)
                        Container(
                          width: MediaQuery.of(context).size.width-80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red[100],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.dangerous, color: Colors.redAccent,),
                              Text('고당뇨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),),
                            ],
                          ),
                        ),
                    if(_diagnosisValue == 1)
                        Container(
                          width: MediaQuery.of(context).size.width-80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepOrange[100],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, color: Colors.deepOrangeAccent,),
                              Text('혈당 주의', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),
                            ],
                          ),
                        ),
                    if(_diagnosisValue == 0)
                        Container(
                          width: MediaQuery.of(context).size.width-80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xfff4f4f4),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.grey,),
                              Text('정상 혈당', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                            ],
                          ),
                        ),
                    if(_diagnosisValue == -1)
                      Container(
                        width: MediaQuery.of(context).size.width-80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xfff4f4f4),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.grey,),
                            Text('혈당 측정값을 입력해 주세요.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                          ],
                        ),
                      ),
                    if(_diagnosisValue == -2)
                      Container(
                        width: MediaQuery.of(context).size.width-80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xfff4f4f4),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, color: Colors.grey,),
                            Text('저혈당', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                          ],
                        ),
                      ),
                    const SizedBox(height: 30,),
                    SizedBox(
                      width:  MediaQuery.of(context).size.width-80,
                      child: const Text('메모',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width:  MediaQuery.of(context).size.width-80,
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
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100,),
                  ]
              ),
            ),
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