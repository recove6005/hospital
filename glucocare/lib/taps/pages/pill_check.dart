import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

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

  final TextEditingController _pillNameController = TextEditingController();
  int _pillCategoryValue = 0;
  int _pillEatTimeValue = 0;

  String _pillName = '';
  String _pillCategory = '당뇨';
  String _eatTime = '';
  String _saveTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
  String _saveDate = DateFormat('yyyy년 MM월 dd일 (E)').format(DateTime.now());

  String _alarmTime = '';

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

  void _setState() {
    _pillName = _pillNameController.text;
    _pillCategory = _getPillCategoryName(_pillCategoryValue);
    _eatTime = _getEatTimeName(_pillEatTimeValue);
    _saveTime = DateFormat('a hh:mm:ss', 'ko_KR').format(DateTime.now());
    _saveDate = DateFormat('yyyy년 MM월 dd일 (E)').format(DateTime.now());

    // _alarmTime
  }

  void _onSaveButtonPressed() {
    _setState();


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
          const SizedBox(height: 30,),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: Center(
              child: Container(
                width: 350,
                height: 150,
                padding: EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: '약품명',
                        hintStyle: TextStyle(
                          fontSize: 35,
                          color: Colors.black45,
                        )
                    ),
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 0,),
          Container(
            width: 350,
            padding: EdgeInsets.all(20),
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
                  const SizedBox(height: 30,),
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
          Container(
            width: 350,
            height: 45,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('복약/투약 시간대'),
                TimePickerSpinner(
                  is24HourMode: false,
                  normalTextStyle: const TextStyle(
                    fontSize: 25,
                    color: Colors.grey,
                  ),
                  highlightedTextStyle: const TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                  itemHeight: 40,
                  spacing: 30,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      _saveTime = time as String;
                    });
                  },
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