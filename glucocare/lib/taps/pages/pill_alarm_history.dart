import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/repositories/pill_alarm_repository.dart';
import 'package:glucocare/repositories/pill_repository.dart';
import 'package:glucocare/taps/pages/pill_check.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../models/pill_alarm_model.dart';

class PillAlarmHistoryPage extends StatelessWidget {
  const PillAlarmHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
      ),
      body: const PillAlarmHistoryForm(),
    );
  }
}

class PillAlarmHistoryForm extends StatefulWidget {
  const PillAlarmHistoryForm({super.key});

  @override
  State<StatefulWidget> createState() => _PillAlarmHistoryFormState();
}

class _PillAlarmHistoryFormState extends State<PillAlarmHistoryForm> {
  Logger logger = Logger();
  bool _isLoading = true;

  List<PillModel> _pillModels = [];
  int _childCount = 0;

  void _setPillModels() async {
    // setState() 이전에 먼저 async-await 작업 후
    // setStete() 내에서 해당 데이터를 옮겨 줌
    try {
      List<PillModel> models = await PillRepository.selectAllPillModels();
      setState(() {
        _pillModels = models;
        _childCount = _pillModels.length;
        _isLoading = false;
      });
    } catch(e) {
      logger.e('[glucocare_log] Failed to load pill histories : $e');
    }
  }

  void _setPillAlarmModels() async {
    List<PillAlarmModel> models = await PillAlarmRepository.selectAllPillAlarm();

  }

  Future<void> _navigateToPillCheck() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => const PillCheckPage()),
    );

    if(result == true) {
      setState(() {
        _setPillModels();
      });
    }
  }

  String _getLocaleTime(Timestamp time) {
    DateTime utcTime = time.toDate();
    DateTime krTime = utcTime.toLocal();
    String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(krTime);

    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    _setPillModels();
    // _setPillAlarmModels();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pillModels.isEmpty) {
      return Scaffold(
          body: const Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 25,),
                Text('알림 내역',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 25,),
                Text('알림 내역이 없습니다.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
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
              onPressed: () {
                _navigateToPillCheck();
              },
              backgroundColor: Colors.grey[350],
              child: const Icon(Icons.add),
            ),
          ),
      );
    }
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 25,),
            const Text('알림 내역',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30,),
            // 리스트
            SizedBox(
              width: 350,
              height: 630,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: _childCount,
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_pillModels[index].saveDate}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 25,
                                                height: 25,
                                                child: Image.asset('assets/images/ic_clock.png'),
                                              ),
                                              const SizedBox(width: 10,),
                                              Text('${_getLocaleTime(_pillModels[index].alarmTime)}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),)
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5,),
                                        Container(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 25,
                                                height: 25,
                                                child: Image.asset('assets/images/ic_pill_check.png'),
                                              ),
                                              const SizedBox(width: 10,),
                                              Text(_pillModels[index].state,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
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
          onPressed: () {
            _navigateToPillCheck();
          },
          backgroundColor: Colors.grey[350],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}