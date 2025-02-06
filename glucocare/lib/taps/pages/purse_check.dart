import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/danger_check.dart';
import 'package:glucocare/models/purse_col_name_model.dart';
import 'package:glucocare/models/purse_danger_model.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/repositories/purse_danger_repository.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:glucocare/services/fcm_service.dart';
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
  bool _isSaving = false;
  Color _backgroundColor = Colors.white;

  final TextEditingController _shrinkController = TextEditingController();
  final TextEditingController _relaxController = TextEditingController();
  // final TextEditingController _purseController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  int _shrink = 0;
  int _relax = 0;
  int _purse = 0;
  String _state = '없음';
  String _checkTime = '';
  String _checkDate = '';
  bool _shrinkDanger = false;
  bool _relaxDanger = false;

  void _setStates() {
    _shrink = int.parse(_shrinkController.text);
    _relax = int.parse(_relaxController.text);
    _purse = 0;
    _shrinkDanger = DangerCheck.purseShrinkDangerCheck(_shrink);
    _relaxDanger = DangerCheck.purseRelaxDangerCheck(_relax);

    _state = _stateController.text;

    _checkTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now().toLocal());
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now().toLocal());

    logger.d("[glucocare_log] 현재 기기 시간: ${DateTime.now().toLocal()}, $_checkTime");
    logger.d("[glucocare_log] 현재 UTC 시간: ${DateTime.now().toUtc()}");
    logger.d("[glucocare_log] 현재 타임존 오프셋: ${DateTime.now().timeZoneOffset}");
  }

  void _onSaveButtonPressed() async {
    setState(() {
      _isSaving = true;
    });

    if(_shrinkController.text == '') {
      Fluttertoast.showToast(msg: '수축기 수치를 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
      setState(() {
        _isSaving = false;
      });
      return;
    }
    
    if(_relaxController.text == '') {
      Fluttertoast.showToast(msg: '이완기 수치를 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
      setState(() {
        _isSaving = false;
      });
      return;
    }
    
    _setStates();


    String? uid = '';
    if (await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      uid = await AuthService.getCurUserId();
    }

    if (uid != null) {
      PurseModel purseModel = PurseModel(
        shrink: _shrink,
        relax: _relax,
        purse: _purse,
        state: _state,
        checkTime: _checkTime,
        checkDate: _checkDate,
      );
      await PurseRepository.insertPurseCheck(purseModel);

      if (await AuthService.userLoginedFa()) {
        String? uid = AuthService.getCurUserUid();
        PurseColNameModel nameModel = PurseColNameModel(
            uid: uid!, date: _checkDate);
        PurseColNameRepository.insertPurseColName(nameModel);
      } else {
        String? kakaoId = await AuthService.getCurUserId();
        PurseColNameModel nameModel = PurseColNameModel(
            uid: kakaoId!, date: _checkDate);
        PurseColNameRepository.insertPurseColName(nameModel);
      }

      if (_shrinkDanger || _relaxDanger) {
        // fcm service
        String name = await UserRepository.getCurrentUserName();
        await FCMService.sendPushNotification(name, '혈압', '${_shrink}/${_relax}', _checkDate, _checkTime);

        // 위험 단계 수치
        PurseDangerModel dangerModel = PurseDangerModel(
          uid: uid,
          shrink: _shrink,
          relax: _relax,
          shrinkDanger: _shrinkDanger,
          relaxDanger: _relaxDanger,
          checkTime: Timestamp.fromDate(DateTime.now().toUtc()),
        );
        PurseDangerRepository.insertDanger(dangerModel);
      }

      if (_shrink.toInt() >= 200 || _relax.toInt() >= 200) {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.dangerous, color: Color(0xFF22BED3),),
                      Text('경고: 고혈압 위험', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),
                      ),
                    ],
                  ),
                  content: const Text('혈압이 위험 수준입니다. 안정을 취하시고 즉시 진료 받으시기 바랍니다.', style: TextStyle(fontSize: 25),),
                  actions: <Widget>[
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
                          ),
                      ),
                      child: const Text('확인', style: TextStyle(fontSize: 20, color: Colors.white),),
                    )
                  ]
              );
            }
        );
      } else if (_shrink.toInt() >= 160 || _relax.toInt() >= 120) {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF22BED3),),
                      Text('경고: 고혈압 주의', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),),
                    ],
                  ),
                  content: const Text('안정 후 재측정 하시고 지속적으로 혈압이 높을 경우 진료 바랍니다.', style: TextStyle(fontSize: 25),),
                  actions: <Widget>[
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
            }
        );
      } else if (_shrink.toInt() >= 140 || _relax.toInt() >= 90) {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF22BED3)),
                      Text('경고: 고혈압 주의', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22BED3),),),
                    ],
                  ),
                  content: const Text(
                    '고혈압 전단계 입니다. 식단 및 운동 관리를 하시어 건강에 유의하시기 바랍니다.',
                    style: TextStyle(fontSize: 25),),
                  actions: <Widget>[
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
            }
        );
      }
      else if(_shrink.toInt() >= 90 || _relax.toInt() >= 60) {
          showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.check, color: Color(0xFF22BED3),),
                        Text('정상 혈압', style: TextStyle(
                            fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),),
                      ],
                    ),
                    content: const Text('혈압이 정상 범위 내에 있습니다.', style: TextStyle(fontSize: 25),),
                    actions: <Widget>[
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
              }
          );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFF22BED3),),
                      Text('저혈압', style: TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF22BED3)),),
                    ],
                  ),
                  content: const Text('혈압이 너무 낮습니다. 생활 습관 관리에 유의하시고 의료진의 도움을 받으세요.', style: TextStyle(fontSize: 25),),
                  actions: <Widget>[
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
            }
        );
      };
    }
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

  int _diagnosisValue = -1;
  void _getDiagnosis(textShrink, textRelex) {
    if (_shrinkController.text.isEmpty || _relaxController.text.isEmpty) {
      setState(() {
        _diagnosisValue = (_shrinkController.text.isEmpty && _relaxController.text.isEmpty)
            ? -1
            : (_shrinkController.text.isEmpty ? -2 : -3);
      });
      return;
    }

    _shrink = int.parse(textShrink);
    _relax = int.parse(textRelex);

    logger.d('glucocare_log ${_shrink}, ${_relax}');

    // 고혈압 3
    // 고혈압 주의2단계 2
    // 고혈압 주의1단계 1
    // 정상 혈압 0
    // 저혈압 -4
    if(_shrink < 90 || _relax < 60) {
      setState(() {
        _diagnosisValue = -4;
      });
      return;
    }

    if(_shrink >= 200 || _relax >= 200) {
      setState(() {
        _diagnosisValue = 3;
      });
      return;
    }
    else if(_shrink >= 160 || _relax >= 120) {
      setState(() {
        _diagnosisValue = 2;
      });
      return;
    }
    else if(_shrink >= 140 || _relax >= 90) {
      setState(() {
        _diagnosisValue = 1;
      });
      return;
    } else {
      setState(() {
        _diagnosisValue = 0;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(_isSaving) return const Center(child: CircularProgressIndicator(),);
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
                  SizedBox(
                    width:  MediaQuery.of(context).size.width-80,
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
                    width:  MediaQuery.of(context).size.width-50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Center(
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 90,
                                  height: 40,
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
                                SizedBox(
                                  width: 70,
                                  height: 40,
                                  child: TextField(
                                    controller: _shrinkController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      rangeTextInputFormatter(0, 300),
                                    ],
                                    onChanged: (text) {
                                      setState(() {
                                        _getDiagnosis(text, _relaxController.text);
                                        logger.d('glucocare_log  shrink value: ${_diagnosisValue}');

                                        if(text == '')  _backgroundColor = Colors.white;

                                        _shrink = int.parse(text);

                                        if(_shrink >= 200 || _relax >= 200) {
                                          _backgroundColor = const Color(0xfffd6363);
                                        }
                                        else if((_shrink < 200 && _shrink >= 160) || (_relax < 200 && _relax >= 120)) {
                                          _backgroundColor = const Color(0xfff87c3c);
                                        }
                                        else if((_shrink < 160 && _shrink >= 140) || (_relax < 120 && _relax >= 90)) {
                                          _backgroundColor = const Color(0xFFFFF2D1);
                                        }
                                        else {
                                          _backgroundColor = Colors.white;
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        counterText: '',
                                        hintStyle: TextStyle(color: Colors.black38)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                const Text('mmHg', style: TextStyle(fontSize: 18),),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15,),
                        SizedBox(
                          width: 300,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 90,
                                  height: 40,
                                  child: Text('이완기', style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 40,
                                  child: TextField(
                                    controller: _relaxController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      rangeTextInputFormatter(0, 300),
                                    ],
                                    onChanged: (text) {
                                      _getDiagnosis(_shrinkController.text, text);
                                      logger.d('glucocare_log relex value: ${_diagnosisValue}');

                                      setState(() {
                                        _relax = int.parse(text);

                                        if(text == '')  _backgroundColor = Colors.white;

                                        if(_shrink >= 200 || _relax >= 200) {
                                          _backgroundColor = const Color(0xfffd6363);
                                        }
                                        else if((_shrink < 200 && _shrink >= 160) || (_relax < 200 && _relax >= 120)) {
                                          _backgroundColor = const Color(0xfff87c3c);
                                        }
                                        else if((_shrink < 160 && _shrink >= 140) || (_relax < 120 && _relax >= 90)) {
                                          _backgroundColor = const Color(0xFFFFF2D1);
                                        }
                                        else {
                                          _backgroundColor = Colors.white;
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                        counterText: '',
                                        hintStyle: TextStyle(color: Colors.black38)
                                    ),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Text('mmHg', style: TextStyle(fontSize: 18),),
                              ],
                            ),
                          ),
                        ),
                        // const SizedBox(height: 15,),
                        // SizedBox(
                        //   width: 300,
                        //   child: Center(
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.end,
                        //       children: [
                        //         const SizedBox(
                        //           width: 90,
                        //           height: 40,
                        //           child: Text('맥박', style: TextStyle(
                        //               fontSize: 25,
                        //               fontWeight: FontWeight.bold,
                        //               color: Colors.black
                        //           ),),
                        //         ),
                        //         SizedBox(
                        //           width: 70,
                        //           height: 40,
                        //           child: TextField(
                        //               controller: _purseController,
                        //               keyboardType: TextInputType.number,
                        //               maxLength: 3,
                        //               inputFormatters: [
                        //                 FilteringTextInputFormatter.digitsOnly,
                        //                 rangeTextInputFormatter(0, 200),
                        //               ],
                        //               decoration: const InputDecoration(
                        //                   counterText: '',
                        //                   hintStyle: TextStyle(color: Colors.black38)
                        //               ),
                        //               style: const TextStyle(
                        //                   fontSize: 25,
                        //                   color: Colors.black
                        //               )
                        //           ),
                        //         ),
                        //         const Text('회/1분', style: TextStyle(fontSize: 18),),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30,),
                  if(_diagnosisValue == 3)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
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
                          Text('고혈압 위험', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == 2)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
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
                          Text('고혈압 주의', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == 1)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amber[100],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, color: Colors.orange,),
                          Text('고혈압 주의', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == 0)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xfff4f4f4),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.grey,),
                          Text('정상 혈압', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == -1)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xfff4f4f4),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.grey,),
                          Text('혈압 측정 수치를 입력해 주세요.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == -2)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xfff4f4f4),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.grey,),
                          Text('수축기 수치를 입력해 주세요.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == -3)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xfff4f4f4),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.grey,),
                          Text('이완기 수치를 입력해 주세요.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                        ],
                      ),
                    ),
                  if(_diagnosisValue == -4)
                    Container(
                      width: MediaQuery.of(context).size.width - 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xfff4f4f4),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, color: Colors.grey,),
                          Text('저혈압', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width-80,
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
                    width: MediaQuery.of(context).size.width-50,
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
