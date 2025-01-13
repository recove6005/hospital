import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/consent_personal_info.dart';
import 'package:glucocare/models/reservation_model.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/models/pill_model.dart';
import 'package:glucocare/popup/fill_in_box.dart';
import 'package:glucocare/repositories/alarm_repository.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/repositories/reservation_repository.dart';
import 'package:glucocare/services/background_fetch_service.dart';
import 'package:glucocare/taps/pages/clinic_schedule.dart';
import 'package:glucocare/taps/pages/notice_board.dart';
import 'package:glucocare/taps/pages/gluco_check.dart';
import 'package:glucocare/taps/pages/pill_check.dart';
import 'package:glucocare/taps/pages/purse_check.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gluco_model.dart';
import '../models/purse_model.dart';
import '../repositories/consent_repository.dart';

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
  bool _isLoadingPill = true;

  String colName = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(DateTime.now());
  GlucoModel? _lastGlucoModel;
  PurseModel? _lastPurseModel;
  PillModel? _lastPillModel;
  String _alarmTime = '';

  String _passedPurseTimer = '';
  String _passedGlucoTimer = '';

  void _showFillInBox() async {
    try {
      UserModel? model = await UserRepository.selectUserByUid();
      if (model != null) {
        if (model.isFilledIn == false) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => const FillInPatientInfoPage()));
        }
      } else {
        await UserRepository.insertInitUser();
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => const FillInPatientInfoPage()));
      }
    } catch (e) {
      logger.e('[glucocare_log] failed (_showFillInBox) : $e');
      await UserRepository.insertInitUser();
      if(mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => const FillInPatientInfoPage()));
      }
    }
  }

  String _nextSchedule = '다음 진료 일정이 없습니다';
  Future<void> _getNextSchedule() async {
    String nextSchedule = '다음 진료 일정이 없습니다';
    try {
      ReservationModel? model = await ReservationRepository.selectLastReservationByUid();
      if(model != null) {
        nextSchedule = DateFormat('MM월 dd일 (E) a hh:mm', 'ko_KR').format(model.reservationDate.toDate());
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed get next schedule. $e');
    }
    _nextSchedule = nextSchedule;
  }

  Future<void> _getLastPurseCheck() async {
    try {
      PurseModel? model = await PurseRepository.selectLastPurseCheck();
      if(model != null){
        setState(() {
          if(mounted) {
            _lastPurseModel = model;
            _isLoadingPurse = false;
            _getPursePassedTimer();
          }
        });
      } else {
        if(mounted) {
          setState(() {
            _isLoadingPurse = false;
          });
        }
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load purse model (_getLastPurseCheck) $e');
      if(mounted) {
        setState(() {
          _lastPurseModel = null;
          _isLoadingPurse = false;
        });
      }
    }
  }

  Future<void> _getLastGlucoCheck() async {
    try{
      GlucoModel? model = await GlucoRepository.selectLastGlucoCheck();
      if(model != null) {
        if(mounted) {
          setState(() {
            _lastGlucoModel = model;
            _isLoadingGluco = false;
            _getGlucoPassedTimer();
          });
        }
      } else {
        if(mounted) {
          setState(() {
            _isLoadingGluco = false;
          });
        }
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco model (_getLastGlucoCheck) $e');
      if(mounted) {
        setState(() {
          _lastGlucoModel = null;
          _isLoadingGluco = false;
        });
      }
    }
  }

  Future<void> _getSoonerPillAlarm() async {
    try {
      PillModel? model = await AlarmRepository.selectSoonerAlarm();
      if(model != null) {
        if(mounted) {
          setState(() {
            _lastPillModel = model;
            Timestamp alarm = model.alarmTime;
            _alarmTime = DateFormat('a hh:mm').format(alarm.toDate());
            _isLoadingPill = false;
          });
        }
      } else {
        if(mounted) {
          setState(() {
            _isLoadingPill = false;
          });
        }
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load pill model (_getSoonerPillAlarm) $e');
      if(mounted) {
        _lastPillModel = null;
        _alarmTime = '';
        _isLoadingPill = false;
      }
    }
  }
  
  // 마지막 측정 후 지난 시간 계산
  String _getPastTimer(String lastDate, String lastTime) {
    DateTime nowTime = DateTime.now();
    DateTime parsedCheckDateTime = _parseDateTime(lastDate, lastTime);
    
    Duration difference = nowTime.difference(parsedCheckDateTime);
    
    int days = difference.inDays;
    int hours = difference.inHours;
    int minutes = difference.inMinutes;
    int sec = difference.inSeconds;

    if(sec < 60) return '방금 추가됨';
    if(minutes < 60) return '$minutes분 전';
    if(hours <= 24) return '$hours시간 전';
    return '$days일 전';
  }
  
  DateTime _parseDateTime(String date, String time) {
    DateFormat dateFormat = DateFormat('yyyy년 MM월 dd일');
    DateTime parsedDate = dateFormat.parse(date);
    
    DateFormat timeFormat = DateFormat('a hh:mm', 'ko_KR');
    DateTime parsedTime = timeFormat.parse(time);
    
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime.hour,
      parsedTime.minute
    );
  }

  void _getPursePassedTimer() {
    _passedPurseTimer = _getPastTimer(_lastPurseModel!.checkDate, _lastPurseModel!.checkTime);
  }

  void _getGlucoPassedTimer() {
    _passedGlucoTimer  = _getPastTimer(_lastGlucoModel!.checkDate, _lastGlucoModel!.checkTime);
  }

  List<PillModel> _alarmModels = [];
  void _getAlarmTasks() async {
    _alarmModels = await AlarmRepository.selectAllAlarmByUid();
    for(PillModel model in _alarmModels) {
      String taskId = model.alarmTimeStr;
      FetchService.initScheduleBackgroundFetch(taskId);
    }
  }

  void _checkRevoke() async {
    if(!await ConsentRepository.checkCurUserConsent()) {
      // 미동의
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ConsentPersonalInfoPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    // 개인정보수집이용동의 확인
    _checkRevoke();

    // 개인정보 작성 확인
    _showFillInBox();

    _getNextSchedule();
    _getLastGlucoCheck();
    _getLastPurseCheck();
    _getSoonerPillAlarm();

    _getAlarmTasks();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoadingGluco || _isLoadingPurse || _isLoadingPill) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            SizedBox(
              width: MediaQuery.of(context).size.width-50,
              height: 35,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  side: const BorderSide(
                    width: 1,
                    color: Colors.redAccent,
                  ),
                ),
                child: SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('진료예약일',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4E00),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Text( _nextSchedule, style: const TextStyle(fontSize: 15, color: Colors.black,),),
                      // const Icon(Icons.keyboard_arrow_right, color: Color(0xFFFF4E00), size: 25,),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: MediaQuery.of(context).size.width-50,
              height: 160,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const GlucoCheckPage()));
                  if(result == true) {
                    setState(() {
                      _getLastGlucoCheck();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FFFF),
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
                        SizedBox(
                          child: Text(_passedGlucoTimer, style: const TextStyle(
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
                    if(_lastGlucoModel == null)
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
                    if(_lastGlucoModel != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            child: Text('${_lastGlucoModel!.value}.0', style: const TextStyle(
                              fontSize: 45,
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
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width-50,
              height: 160,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PurseCheckPage()));
                  if(result == true) {
                    setState(() {
                      _getLastPurseCheck();
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
                        SizedBox(
                          child: Text(_passedPurseTimer, style: const TextStyle(
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
                    if(_lastPurseModel == null)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            child: Text(' -- / --', style: TextStyle(
                              fontSize: 45,
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
                    if(_lastPurseModel != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            child: Text('${_lastPurseModel!.shrink}/${_lastPurseModel!.relax}', style: const TextStyle(
                              fontSize: 45,
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
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width-50,
              height: 160,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PillCheckPage()));
                  if(result == true) {
                    setState(() {
                      _getSoonerPillAlarm();
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
                    if(_lastPillModel == null)
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
                    if(_lastPillModel != null)
                      SizedBox(
                        width: 300,
                        child: Text(_alarmTime,
                          style: const TextStyle(
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
              width: MediaQuery.of(context).size.width/5*4,
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
                          onPressed: () {
                            launchUrl(
                              Uri.parse('https://booking.naver.com/booking/13/bizes/742389?area=pll'),
                            );
                          },
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
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ClinicSchedulePage()));
                          },
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
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticeBoardPage()));
                          },
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
      ),
    );
  }
}