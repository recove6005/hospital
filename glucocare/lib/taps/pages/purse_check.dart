import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/purse_col_name_model.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/colname_repository.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PurseCheckPage extends StatelessWidget {
  const PurseCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
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

  String _formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  String _formattedTime = DateFormat('a hh시 mm분', 'ko_KR').format(DateTime.now());
  late Timer _timerTime;

  final TextEditingController _shrinkController = TextEditingController();
  final TextEditingController _relaxController = TextEditingController();
  final TextEditingController _purseController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  static int _checkTimeValue = 0;
  static List<bool> _stateValue = List.generate(11, (index) => false);

  String _checkTimeName = '아침';
  int _shrink = 0;
  int _relax = 0;
  int _purse = 0;
  String _state = '없음';
  String _checkTime = '';
  String _checkDate = '';

  String _getEattimeName(int index) {
    switch (index) {
      case 0: return '아침';
      case 1: return '점심';
      case 2: return '저녁';
      case 3: return '복용 후';
    }
    return 'Err';
  }

  String _getStateName(int index) {
      switch (index) {
        case 0: return '두통';
        case 1: return '어지러움';
        case 2: return '가슴통증';
        case 3: return '식은땀';
        case 4: return '피로감';
        case 5: return '숨 가쁨';
        case 6: return '메스꺼움';
        case 7: return '시야흐림';
      }
      return 'Err';
  }

  void _setStates() {
    _checkTimeName = _getEattimeName(_checkTimeValue);
    _shrink = int.parse(_shrinkController.text);
    _relax = int.parse(_relaxController.text);
    _purse = int.parse(_purseController.text);

    _stateValue.asMap().forEach((index, item) {
        if(item) {
          if(index == 0) _state = '${_getStateName(index)}';
          else _state = '$_state, ${_getStateName(index)}';
        }
      }
    );
    _state = '$_state, ${_stateController.text}';

    _checkTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
    _checkDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  }

  void _onSaveButtonPressed() {
    _setStates();

    PurseModel purseModel = PurseModel(
        checkTimeName: _checkTimeName,
        shrink: _shrink,
        relax: _relax,
        purse: _purse,
        state: _state,
        checkTime: _checkTime,
        checkDate: _checkDate
    );
    PurseRepository.insertPurseCheck(purseModel);

    String uid = AuthService.getCurUserUid();
    PurseColNameModel nameModel = PurseColNameModel(uid: uid, date: _checkDate);
    ColNameRepository.insertPurseColName(nameModel);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    _checkTimeValue = 0;

    _stateValue = List.generate(11, (index) => false);

    _timerTime = Timer.periodic(const Duration(seconds: 5), (timer){
      setState(() {
        _formattedTime = DateFormat('a hh시 mm분', 'ko_KR').format(DateTime.now());
        _formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
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
            const SizedBox(height: 5,),
            Container(
              width: 300,
              height: 120,
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  SizedBox(
                    width: 350,
                    height: 35,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 0,
                        groupValue: _checkTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _checkTimeValue = value!;
                            logger.d('[glucocare_log] $value');
                          });
                        },
                      ),
                      title: const Text('아침', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 35,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 1,
                        groupValue: _checkTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _checkTimeValue = value!;
                            logger.d('[glucocare_log] $value');
                          });
                        },
                      ),
                      title: const Text('점심', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 35,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 2,
                        groupValue: _checkTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _checkTimeValue = value!;
                            logger.d('[glucocare_log] $value');
                          });
                        },
                      ),
                      title: const Text('저녁', style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            Container(
              width: 350,
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.red[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('수축기', style: TextStyle(
                        fontSize: 25,
                        color: Colors.black
                    ),),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextField(
                        controller: _shrinkController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(
                            counterText: '',
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.black38)
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    const Text('mmHg'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15,),
            Container(
              width: 350,
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.red[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('이완기', style: TextStyle(
                        fontSize: 25,
                        color: Colors.black
                    ),),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextField(
                        controller: _relaxController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: const InputDecoration(
                            counterText: '',
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.black38)
                        ),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    const Text('mmHg'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15,),
            Container(
              width: 350,
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('맥박', style: TextStyle(
                        fontSize: 25,
                        color: Colors.black
                    ),),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: TextField(
                          controller: _purseController,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          decoration: const InputDecoration(
                              counterText: '',
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.black38)
                          ),
                          style: const TextStyle(
                              fontSize: 40,
                              color: Colors.black
                          )
                      ),
                    ),
                    const SizedBox(width: 10,),
                    const Text('회/1분'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15,),
            Container(
              width: 360,
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  childAspectRatio: 3.5,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container (
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 100,
                          child: CheckboxListTile(
                            value: _stateValue[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _stateValue[index] = value ?? false;
                              });
                            },
                            title: Text(
                              _getStateName(index),
                              style: const TextStyle(
                                  fontSize: 16
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            visualDensity: VisualDensity(horizontal: -4),
                            contentPadding: const EdgeInsets.all(0),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5,),
            Container(
              width: 350,
              height: 120,
              child: TextField(
                controller: _stateController,
                maxLength: 50,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  border: OutlineInputBorder(),
                  hintText: '특이 사항',
                  hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.grey
                  ),
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        height: 50,
        child: FloatingActionButton(
          onPressed: _onSaveButtonPressed,
          backgroundColor: Colors.red[300],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
