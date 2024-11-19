import 'package:flutter/material.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/taps/pages/gluco_check.dart';
import 'package:glucocare/taps/pages/pill_alarm_history.dart';
import 'package:glucocare/taps/pages/purse_check.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/gluco_model.dart';
import '../models/purse_model.dart';
import '../services/notification_service.dart';

class HomeTap extends StatelessWidget {
  const HomeTap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeTapForm(),
    );
  }
}

class HomeTapForm extends StatefulWidget {
  const HomeTapForm({super.key});

  @override
  State<StatefulWidget> createState() => _HomeTapForm();
}

class _HomeTapForm extends State<HomeTapForm> {
  Logger logger = Logger();
  bool _isLoadingGluco = true;
  bool _isLoadingPurse = true;
  bool _isLoadingpill = true;

  String colName = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  GlucoModel? _todayGlucoModel = null;
  PurseModel? _todayPurseModel = null;
  PillModel? _todayPillModel = null;

  Future<void> _getTodayGluco() async {
    try {
      GlucoModel? model = await GlucoRepository.selectGlucoByColName(colName);
      setState(() {
        _todayGlucoModel = model;
        _isLoadingGluco = false;
      });

    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco model $e');
      setState(() {
        _todayGlucoModel = null;
        _isLoadingGluco = false;
      });
    }
  }

  Future<void> _getTodayPurse() async {
    try {
      PurseModel? model = await PurseRepository.selectPurseByColName(colName);
      setState(() {
        _todayPurseModel = model;
        _isLoadingPurse = false;
      });
    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco model $e');
      setState(() {
        _todayGlucoModel = null;
        _isLoadingPurse = false;
      });
    }
  }

  // void _sendPushMsg() async {
  //   // notification testing
  //   NotificationService.sendForegroundMsg();
  //   NotificationService.sendBackgroundMsg();
  // }

  @override
  void initState() {
    super.initState();
    _getTodayGluco();
    _getTodayPurse();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoadingGluco || _isLoadingPurse) return const Center(child: CircularProgressIndicator(),);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 10,),
          SizedBox(
            width: 350,
            height: 35,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                ),
                side: const BorderSide(
                  width: 1,
                  color: Colors.redAccent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Text('진료예약일',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4E00),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Text(DateFormat('yy.MM.dd(E) a hh:mm', 'ko_KR').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),),
                    ],
                  ),
                  const SizedBox(
                    width: 39,
                    height: 39,
                    child: Icon(Icons.keyboard_arrow_right, color: Color(0xFFFF4E00),),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: 350,
            height: 160,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const GlucoCheckPage()));
                if(result == true) {
                  _todayGlucoModel = null;
                  _isLoadingGluco = true;
                  setState(() {
                    _getTodayGluco();
                  });
                }
                },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF8FFFF),
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF22BED3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: Image.asset('assets/images/icon_bloodsugar.png'),
                          ),
                          const SizedBox(width: 5,),
                          const SizedBox(
                            width: 70,
                            height: 50,
                            child: Text('혈당',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF22BED3),
                            ),),
                          ),
                        ],
                      ),
                      const SizedBox(
                        child: Text('방금 추가됨', style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF777777),
                        ),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD5EFEF),
                    ),
                  ),
                  if(_todayGlucoModel == null)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        child: Text(' -- ', style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),),
                      ),
                      SizedBox(
                        child: Text('mg/dL', style: TextStyle(
                          fontSize: 30,
                          color: Colors.black87,
                        ),),
                      ),
                    ],
                  ),
                  if(_todayGlucoModel != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Text('${_todayGlucoModel!.value}.0', style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),),
                        ),
                        const SizedBox(
                          child: Text('mg/dL', style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87,
                          ),),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            width: 350,
            height: 160,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PurseCheckPage()));
                _todayPurseModel = null;
                _isLoadingPurse = true;
                if(result == true) {
                  setState(() {
                    _getTodayPurse();
                  });
                }
                },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFAFA),
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFed4848),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: Image.asset('assets/images/icon_bloodpressure.png'),
                          ),
                          const SizedBox(width: 5,),
                          const SizedBox(
                            width: 70,
                            height: 50,
                            child: Text('혈압',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFed4848),
                              ),),
                          ),
                        ],
                      ),
                      const SizedBox(
                        child: Text('방금 추가됨', style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF777777),
                        ),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFedd6d6),
                    ),
                  ),
                  if(_todayPurseModel == null)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Text(' -- / --', style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),),
                        ),
                        SizedBox(
                          child: Text('mmHg', style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87,
                          ),),
                        ),
                      ],
                    ),
                  if(_todayPurseModel != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Text('${_todayPurseModel!.shrink} / ${_todayPurseModel!.relax}', style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),),
                        ),
                        const SizedBox(
                          child: Text('mmHg', style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87,
                          ),),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            width: 350,
            height: 160,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PillAlarmHistoryPage()));

                if(result == true) {
                  setState(() {

                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFAFFFC),
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF168E41),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: Image.asset('assets/images/icon_medicine.png'),
                          ),
                          const SizedBox(width: 5,),
                          const SizedBox(
                            width: 40,
                            height: 50,
                            child: Text('약',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF158D40),
                              ),),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 120,
                        height: 28,
                        child: Image.asset('assets/images/icon_add_alarm.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD6EDE1),
                    ),
                  ),
                  if(_todayPillModel == null)
                    const SizedBox(
                      width: 300,
                      child: Text(' -- : -- ',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  if(_todayPillModel != null)
                    const SizedBox(
                      width: 300,
                      child: Text('  ', // 알람시간 --------------------------------------------------------------------------
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30,),
          SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFF9F9F9),
                        ),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/images/icon_schedule.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Text('진료예약', style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),),
                  ],
                ),
                const SizedBox(width: 10,),
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFF9F9F9),
                        ),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/images/icon_reservation.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Text('진료일정', style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),),
                  ],
                ),
                const SizedBox(width: 10,),
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: EdgeInsets.zero,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFF9F9F9),
                        ),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/images/icon_notice.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Text('공지사항', style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}