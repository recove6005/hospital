import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/models/reservation_model.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:glucocare/repositories/reservation_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorReservationPage extends StatelessWidget {
  final UserModel model;
  const DoctorReservationPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 진료 예약', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: DoctorReservationForm(model: model),
    );
  }
}

class DoctorReservationForm extends StatefulWidget {
  final UserModel model;
  const DoctorReservationForm({super.key, required this.model});

  @override
  State<DoctorReservationForm> createState() => _DoctorReservationFormState(model: model);
}

class _DoctorReservationFormState extends State<DoctorReservationForm> {
  final UserModel model;
  _DoctorReservationFormState({required this.model});

  Logger logger = Logger();
  bool _isLoading = true;

  List<String> _subjects = [
    '통증센터',
    '뇌신경센터',
    '내과센터',
    '초음파센터',
    '도수치료센터',
    '예방접종센터',
  ];
  int _subjectIndex = 0;
  final TextEditingController _detailsController = TextEditingController();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Timestamp _reservationDate = Timestamp.now();
  int _reservationHour = 0;
  int _reservationMinute = 0;
  String _buttonClicked = '00:00';

  List<DateTime> _reservedDatetimes = [];
  List<String> _reservedTimes = [];

  bool _isDayEnabled(DateTime day) {
    return !day.isBefore(DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ));
  }

  Future<void> _getReservedDates() async {
    List<ReservationModel> tempList = await ReservationRepository.selectAllReservations();
    List<DateTime> tempDatetimes = [];

    List<String> tempDaytimes = [];

    for(ReservationModel model in tempList) {
      DateTime tdt = model.reservationDate.toDate();
      tempDatetimes.add(tdt);

      String daytime = '${DateFormat('HH:mm').format(tdt)}${DateFormat('yyyyMMdd').format(tdt)}';
      tempDaytimes.add(daytime);
    }
    setState(() {
      _reservedDatetimes = tempDatetimes;
      _reservedTimes = tempDaytimes;
      _isLoading = false;
    });
  }

  bool _checkReservedDateTime(String time) {
    for(DateTime date in _reservedDatetimes) {
      List<String> tempTimeList = [];
      // date check
      if(
        _focusedDay.year == date.year &&
        _focusedDay.month == date.month &&
        _focusedDay.day == date.day
      ) {
        String dateStr = DateFormat('yyyyMMdd').format(date);
        for(String timeStr in _reservedTimes) {
          if(timeStr.contains(dateStr)) tempTimeList.add(timeStr.substring(0,5));
        }

        if(tempTimeList.contains(time)) return true;
      }
    }
    return false;
  }

  DateTime _getReservationDateTime() {
    DateTime reservationDateTime = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
      _reservationHour,
      _reservationMinute,
    );
    setState(() {
      _reservationDate = Timestamp.fromDate(reservationDateTime);
    });
    return reservationDateTime;
  }

  Future<void> _reservation() async {
    String uid = model.uid;
    if(uid == '') uid = model.kakaoId;

    String? admin = await AuthService.getCurUserUid();
    if(admin == '') admin = await AuthService.getCurUserId();

    ReservationModel reservationModel = ReservationModel(
        uid: uid,
        reservationDate: _reservationDate,
        subject: _subjects[_subjectIndex],
        details: _detailsController.text,
        admin: admin!,
    );
    await ReservationRepository.insertReservationBySpecificUid(reservationModel);
    setState(() {
      _getReservedDates();
      _getReservationDateTime();
    });
    Fluttertoast.showToast(msg: '예약이 완료되었습니다.', toastLength: Toast.LENGTH_SHORT);

    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _reservationDate = Timestamp.now();
    _reservationHour = 0;
    _reservationMinute = 0;
    _buttonClicked = '00:00';
    _subjectIndex = 0;
  }

  @override
  void initState() {
    super.initState();
    _getReservedDates();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TableCalendar(
            locale: 'ko_KR',
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 12, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              todayTextStyle: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 80,
                    height: 60,
                    child: Center(
                        child: Text('${day.day}', style: const TextStyle(color: Colors.black),)
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text('${day.day}', style: const TextStyle(color: Colors.white),)
                  ),
                );
              }
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            enabledDayPredicate: _isDayEnabled,
          ),
          const SizedBox(height: 20,),
          Center(
            child: Column(
              children: [
                const Text('시간 선택', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),),
                const SizedBox(height: 15,),
                const Text('오전', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),),
                const SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '08:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('08:00') ? null : () {
                            setState(() {
                              _buttonClicked = '08:00';
                              _reservationHour = 8;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('08:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '08:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('08:30') ? null : () {
                            setState(() {
                              _buttonClicked = '08:30';
                              _reservationHour = 8;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('08:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '09:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('09:00') ? null : () {
                            setState(() {
                              _buttonClicked = '09:00';
                              _reservationHour = 9;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('09:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '09:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('09:30') ? null : () {
                            setState(() {
                              _buttonClicked = '09:30';
                              _reservationHour = 9;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('09:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '10:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('10:00') ? null : () {
                            setState(() {
                              _buttonClicked = '10:00';
                              _reservationHour = 10;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('10:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '10:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('10:30') ? null : () {
                            setState(() {
                              _buttonClicked = '10:30';
                              _reservationHour = 10;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('10:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '11:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed:_checkReservedDateTime('11:00') ? null : () {
                            setState(() {
                              _buttonClicked = '11:00';
                              _reservationHour = 11;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('11:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '11:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('11:30') ? null : () {
                            setState(() {
                              _buttonClicked = '11:30';
                              _reservationHour = 11;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('11:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                const Text('오후', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),),
                const SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '12:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('12:00') ? null : () {
                            setState(() {
                              _buttonClicked = '12:00';
                              _reservationHour = 12;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('12:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '12:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('12:30') ? null : () {
                            setState(() {
                              _buttonClicked = '12:30';
                              _reservationHour = 12;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('12:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '13:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('13:00') ? null : () {
                            setState(() {
                              _buttonClicked = '13:00';
                              _reservationHour = 13;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('13:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '13:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('13:30') ? null : () {
                            setState(() {
                              _buttonClicked = '13:30';
                              _reservationHour = 13;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('13:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '14:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('14:00') ? null : () {
                            setState(() {
                              _buttonClicked = '14:00';
                              _reservationHour = 14;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('14:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '14:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('14:30') ? null : () {
                            setState(() {
                              _buttonClicked = '14:30';
                              _reservationHour = 14;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('14:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '15:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('15:00') ? null : () {
                            setState(() {
                              _buttonClicked = '15:00';
                              _reservationHour = 15;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('15:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '15:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('15:30') ? null : () {
                            setState(() {
                              _buttonClicked = '15:30';
                              _reservationHour = 15;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('15:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '16:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('16:00') ? null : () {
                            setState(() {
                              _buttonClicked = '16:00';
                              _reservationHour = 16;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('16:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '16:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('16:30') ? null : () {
                            setState(() {
                              _buttonClicked = '16:30';
                              _reservationHour = 16;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('16:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '17:00' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('17:00') ? null : () {
                            setState(() {
                              _buttonClicked = '17:00';
                              _reservationHour = 17;
                              _reservationMinute = 0;
                            });
                          },
                          child: const Text('17:00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                    const SizedBox(width: 15,),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: _buttonClicked == '17:30' ? Colors.grey : const Color(0xfff9f9f9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              )
                          ),
                          onPressed: _checkReservedDateTime('17:30') ? null : () {
                            setState(() {
                              _buttonClicked = '17:30';
                              _reservationHour = 17;
                              _reservationMinute = 30;
                            });
                          },
                          child: const Text('17:30', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50,),
                Column(
                  children: [
                    const Text('진료과목 선택', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: _subjectIndex == 0 ? Colors.grey : const Color(0xfff9f9f9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjectIndex = 0;
                                });
                              },
                              child: const Text('통증센터', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: _subjectIndex == 1 ? Colors.grey : const Color(0xfff9f9f9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjectIndex = 1;
                                });
                              },
                              child: const Text('뇌신경센터', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: _subjectIndex == 2 ? Colors.grey : const Color(0xfff9f9f9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjectIndex = 2;
                                });
                              },
                              child: const Text('내과센터', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: _subjectIndex == 3 ? Colors.grey : const Color(0xfff9f9f9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjectIndex = 3;
                                });
                              },
                              child: const Text('초음파센터', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: _subjectIndex == 4 ? Colors.grey : const Color(0xfff9f9f9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjectIndex = 4;
                                });
                              },
                              child: const Text('도수치료센터', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 110,
                          height: 40,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: _subjectIndex == 5 ? Colors.grey : const Color(0xfff9f9f9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(color: Colors.grey, width: 1),
                                  )
                              ),
                              onPressed: () {
                                setState(() {
                                  _subjectIndex = 5;
                                });
                              },
                              child: const Text('예방접종센터', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black,),)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _detailsController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: '진료 내용..',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xfff9f9f9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          '최종 예약 시간',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),),
                        const SizedBox(width: 10,),
                        Text(
                          DateFormat('yyyy-MM-dd (E요일) HH:mm', 'ko_KR').format(_getReservationDateTime()),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: _reservation,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xfff9f9f9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      child: const Text('예약하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),)
                  ),
                ),
                const SizedBox(height: 50,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

