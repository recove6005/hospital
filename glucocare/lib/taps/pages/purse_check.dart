import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  String _formattedTime = DateFormat('a hh:mm', 'ko_KR').format(DateTime.now());
  late Timer _timerTime;

  final TextEditingController _shrinkController = TextEditingController();
  final TextEditingController _relaxController = TextEditingController();
  final TextEditingController _purseController = TextEditingController();

  static int _eatTimeValue = 1;
  
  @override
  void initState() {
    super.initState();
    _timerTime = Timer.periodic(const Duration(seconds: 5), (timer){
      setState(() {
        _formattedTime = DateFormat('a hh:mm', 'ko_KR').format(DateTime.now());
        _formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                padding: const EdgeInsets.all(0),
                children: [
                  SizedBox(
                    width: 350,
                    height: 30,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 1,
                        groupValue: _eatTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _eatTimeValue = value!;
                          });
                        },
                      ),
                      title: const Text('아침', style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 30,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 2,
                        groupValue: _eatTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _eatTimeValue = value!;
                          });
                        },
                      ),
                      title: const Text('점심', style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 30,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 3,
                        groupValue: _eatTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _eatTimeValue = value!;
                          });
                        },
                      ),
                      title: const Text('저녁', style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 30,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Radio<int> (
                        value: 4,
                        groupValue: _eatTimeValue,
                        onChanged: (int? value) {
                          setState(() {
                            _eatTimeValue = value!;
                          });
                        },
                      ),
                      title: const Text('복용 후', style: TextStyle(
                        fontSize: 15,
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
            )
          ],
        ),
    );
  }
}
