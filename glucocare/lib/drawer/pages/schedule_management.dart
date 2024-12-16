import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/drawer/pages/schedul_update.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/reservation_model.dart';
import '../../repositories/reservation_repository.dart';

class ScheduleManagementPage extends StatelessWidget {
  final UserModel model;
  const ScheduleManagementPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("환자 예약 관리", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: ScheduleManagementForm(model: model,),
    );
  }
}

class ScheduleManagementForm extends StatefulWidget {
  final UserModel model;
  const ScheduleManagementForm({super.key, required this.model});

  @override
  State<ScheduleManagementForm> createState() => _ScheduleManagementFormState(model: model);
}

class _ScheduleManagementFormState extends State<ScheduleManagementForm> {
  final UserModel model;
  _ScheduleManagementFormState({required this.model});

  Logger logger = Logger();
  bool _isLoading = true;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool _isDayEnabled(DateTime day) {
    return !day.isBefore(DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ));
  }

  List<String> _reservationDateStrs = [];
  List<String> _timeStrs = [];
  List<ReservationModel> _reservations = [];
  List<String> _details = [];
  List<String> _subjects = [];
  Future<void> _getCurReservations() async {
    List<ReservationModel> templist = [];
    if(model.uid != '')  templist = await ReservationRepository.selectAllReservationsBySpecificUid(model.uid);
    else templist = await ReservationRepository.selectAllReservationsBySpecificUid(model.kakaoId);
    List<String> tempStrs = [];
    List<String> tempTimeStrs = [];
    List<String> tempDetails = [];
    List<String> tempSubjects = [];
    for(ReservationModel model in templist) {
      String dateStr = DateFormat('yyyyMMdd').format(model.reservationDate.toDate());
      String timeStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}${DateFormat('a hh:mm').format(model.reservationDate.toDate())}';
      String detailsStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}${model.details}';
      String subjectsStr = '${DateFormat('yyyyMMdd').format(model.reservationDate.toDate())}${model.subject}';
      tempStrs.add(dateStr);
      tempTimeStrs.add(timeStr);
      tempDetails.add(detailsStr);
      tempSubjects.add(subjectsStr);
    }
    setState(() {
      _reservations = templist;
      _reservationDateStrs = tempStrs;
      _timeStrs = tempTimeStrs;
      _details = tempDetails;
      _subjects = tempSubjects;
      _isLoading = false;

      _getFocusedDaysReservationTimes();
    });
  }

  bool _isReserved(DateTime day) {
    String focustedDateStr = DateFormat('yyyyMMdd').format(day);
    if(_reservationDateStrs.contains(focustedDateStr)) return true;
    return false;
  }

  List<String> _focusedDayReservationTimes = [];
  List<String> _focusedDayDetails = [];
  List<String> _focusedDaySubjects = [];
  void _getFocusedDaysReservationTimes() {
    List<String> templist = [];
    String dateStr = DateFormat('yyyyMMdd').format(_focusedDay);
    for(String time in _timeStrs) {
      if(time.contains(dateStr)){
        String timeStr = time.substring(8);
        templist.add(timeStr);
      }
    }
    List<String> tempdetails = [];
    for(String detailStrs in _details) {
      if(detailStrs.contains(dateStr)) {
        String detailStr = detailStrs.substring(8);
        tempdetails.add(detailStr);
      }
    }
    List<String> tempSubjects = [];
    for(String subjectStrs in _subjects) {
      if(subjectStrs.contains(dateStr)) {
        String subjectStr = subjectStrs.substring(8);
        tempSubjects.add(subjectStr);
      }
    }

    setState(() {
      _focusedDayReservationTimes = templist;
      _focusedDayDetails = tempdetails;
      _focusedDaySubjects = tempSubjects;
    });
  }

  Future<void> _deleteReservation(Timestamp reservationTimestamp) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('진료 일정 삭제'),
            content: const Text('설정한 일정을 삭제하시겠습니까?'),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey, width: 1),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소', style: TextStyle(fontSize: 18, color: Colors.black),),
              ),
              TextButton(
                onPressed: () async {
                  String uid = model.uid;
                  await ReservationRepository.deleteReservationBySpecificUid(uid, reservationTimestamp);
                  setState(() {
                    _getCurReservations();
                  });
                  Navigator.pop(context);
                },
                child: const Text('확인', style: TextStyle(fontSize: 18, color: Colors.black),),
              ),
            ],
          );
        },
    );
  }

  Future<void> _updateReservation(Timestamp postTimestamp) async {
    ReservationModel? reservationModel = null;
    if(model.uid != '') reservationModel = await ReservationRepository.selectReservationsBySpecificUid(model.uid, postTimestamp);
    else reservationModel = await ReservationRepository.selectReservationsBySpecificUid(model.kakaoId, postTimestamp);

    if(reservationModel != null) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationEditPage(
        model: reservationModel!,
        postTimestamp: postTimestamp,
      )));

      if(result) {
        _getCurReservations();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurReservations();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                todayBuilder: (context, day, focusedDay) {
                  if(_isReserved(day)) {
                    return Center(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.red, size: 15,),
                            Text('${day.day}', style: const TextStyle(color: Colors.lightBlueAccent),)
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Container(
                      width: 80,
                      height: 60,
                      child: Center(
                          child: Text('${day.day}', style: const TextStyle(color: Colors.lightBlueAccent),)
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, day, focusedDay) {
                  if(_isReserved(day)) {
                    return Center(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.red, size: 15,),
                            Text('${day.day}', style: const TextStyle(color: Colors
                                .black),)
                          ],
                        ),
                      ),
                    );
                  }
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
                  if(_isReserved(day)) {
                    return Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.white, size: 15,),
                            Text('${day.day}', style: const TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
                    );
                  } else {
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
                }
            ),
            pageAnimationEnabled: true,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _getFocusedDaysReservationTimes();
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _getFocusedDaysReservationTimes();
              });
            },
            enabledDayPredicate: _isDayEnabled,
          ),
          const SizedBox(height: 30,),
          Container(
            padding: const EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_focusedDay.year}년 ${_focusedDay.month}월 ${_focusedDay.day}일', style: const TextStyle(fontSize: 20),),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('진료 일정', style: TextStyle(fontSize: 18),),
            ),
          ),
          const SizedBox(height: 20,),
          Container(
            width: MediaQuery.of(context).size.width - 30,
            height: 300,
            padding: const EdgeInsets.only(left: 30),
            child: Center(
              child:_focusedDayReservationTimes.isEmpty
                  ? const Text('예약된 진료 일정이 없습니다.')
                  : ListView.builder(
                itemCount: _focusedDayReservationTimes.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.transparent),
                      ),
                    ),
                    child: Card(
                      color: const Color(0xfff9f9f9),
                      child: GestureDetector(
                        onTap : () {
                          int hour = 0;
                          int minute = 0;
                          if(_focusedDayReservationTimes[index].substring(0,2) == '오전') {
                            hour = int.parse(_focusedDayReservationTimes[index].substring(3,5));
                            if(hour == 12) hour = 0;
                          } else {
                            hour = int.parse(_focusedDayReservationTimes[index].substring(3,5))+12;
                          }
                          minute = int.parse(_focusedDayReservationTimes[index].substring(6));

                          DateTime reservation = DateTime(
                            _focusedDay.year,
                            _focusedDay.month,
                            _focusedDay.day,
                            hour,
                            minute,
                            0,
                          );
                          Timestamp reservationTimestamp = Timestamp.fromDate(reservation);
                          _deleteReservation(reservationTimestamp);
                        },
                        // 예약 수정
                        // onTap: () async {
                        //   int hour = 0;
                        //   int minute = 0;
                        //   if(_focusedDayReservationTimes[index].substring(0,2) == '오전') {
                        //     hour = int.parse(_focusedDayReservationTimes[index].substring(3,5));
                        //     if(hour == 12) hour = 0;
                        //   } else {
                        //     hour = int.parse(_focusedDayReservationTimes[index].substring(3,5))+12;
                        //   }
                        //   minute = int.parse(_focusedDayReservationTimes[index].substring(6));
                        //
                        //   DateTime reservation = DateTime(
                        //     _focusedDay.year,
                        //     _focusedDay.month,
                        //     _focusedDay.day,
                        //     hour,
                        //     minute,
                        //     0,
                        //   );
                        //
                        //   Timestamp reservationTimestamp = Timestamp.fromDate(reservation);
                        //   await _updateReservation(reservationTimestamp);
                        // },
                        child:  ListTile(
                          title: Align(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_hospital,),
                                const SizedBox(width: 5,),
                                Text(
                                  '[${_focusedDaySubjects[index]}]',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _focusedDayReservationTimes[index],
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(
                                _focusedDayDetails[index],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          //subtitle:
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 50,),
        ],
      ),
    );
  }
}

